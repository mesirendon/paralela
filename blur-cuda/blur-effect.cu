#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <cuda.h>
#include <helper_cuda.h>
#include <cuda_runtime.h>

#pragma pack(push,1)
typedef struct {
  char         filetype[2];   /* magic - always 'B' 'M' */
  unsigned int filesize;
  short        reserved1;
  short        reserved2;
  unsigned int dataoffset;    /* offset in bytes to actual bitmap data */
} file_header;

typedef struct {
  file_header  fileheader;
  unsigned int headersize;
  int          width;
  int          height;
  short        planes;
  short        bitsperpixel;  /* we only support the value 24 here */
  unsigned int compression;   /* we do not support compression */
  unsigned int bitmapsize;
  int          horizontalres;
  int          verticalres;
  unsigned int numcolors;
  unsigned int importantcolors;
} bitmap_header;
#pragma pack(pop)

typedef struct _bitmap_metadata {
  int width;
  int height;
  int threads;
  int blurSize;
} bitmap_metadata;

__global__ void d_blur(unsigned char* d_data, bitmap_metadata* d_bitmap_metadata) {
  int thread = (blockDim.x * blockIdx.x) + threadIdx.x;
  int x, y, xx, yy, avgB, avgG, avgR, ile;
  int xmin = d_bitmap_metadata->width / d_bitmap_metadata->threads * thread;
  int xmax = d_bitmap_metadata->width / d_bitmap_metadata->threads * (thread + 1);
  int ymin = 0;
  int ymax = d_bitmap_metadata->height;

  if(thread < d_bitmap_metadata->width)
    for(xx = xmin; xx < xmax; xx++) {
      for(yy = ymin; yy < ymax; yy++) {
        avgB = avgG = avgR = ile = 0;

        for(x = xx; x < d_bitmap_metadata->width && x < xx + d_bitmap_metadata->blurSize; x++) {
          for(y = yy; y < d_bitmap_metadata->height && y < yy + d_bitmap_metadata->blurSize; y++) {
            avgB += d_data[x * 3 + y * d_bitmap_metadata->width * 3 + 0];
            avgG += d_data[x * 3 + y * d_bitmap_metadata->width * 3 + 1];
            avgR += d_data[x * 3 + y * d_bitmap_metadata->width * 3 + 2];
            ile++;
          }
        }

        avgB /= ile;
        avgG /= ile;
        avgR /= ile;

        d_data[xx * 3 + yy * d_bitmap_metadata->width * 3 + 0] = avgB;
        d_data[xx * 3 + yy * d_bitmap_metadata->width * 3 + 1] = avgG;
        d_data[xx * 3 + yy * d_bitmap_metadata->width * 3 + 2] = avgR;
      }
    }
}

int blur(char* input, char *output, int kernel) {
  int dev = 0;
  cudaError_t error = cudaSuccess;
  cudaSetDevice(dev);
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, dev);

  int threadsPerBlock, threads;
  int blocksPerGrid = deviceProp.multiProcessorCount;

  FILE *fp, *out;
  bitmap_header* hp;
  int n, blurSize = kernel;
  unsigned char *data, *d_data;
  bitmap_metadata *d_bitmap_metadata, *h_bitmap_metadata;

  fp = fopen(input, "r");

  hp = (bitmap_header*) malloc(sizeof(bitmap_header));
  if(hp == NULL)
    return 3;

  n = fread(hp, sizeof(bitmap_header), 1, fp);
  if(n != 1)
    printf("Error reading file\n");
  data = (unsigned char*) malloc(sizeof(unsigned char) * hp->bitmapsize);

  fseek(fp, sizeof(char) * hp->fileheader.dataoffset, SEEK_SET);
  n = fread(data, sizeof(char), hp->bitmapsize, fp);

  h_bitmap_metadata = (bitmap_metadata*) malloc(sizeof(bitmap_metadata));

  threads = hp->width;
  threadsPerBlock = threads / blocksPerGrid;

  h_bitmap_metadata->width = hp->width;
  h_bitmap_metadata->height = hp->height;
  h_bitmap_metadata->threads = threads;
  h_bitmap_metadata->blurSize = blurSize;

  error = cudaMalloc(&d_data, sizeof(unsigned char) * hp->bitmapsize);
  if(error != cudaSuccess) printf("Error alocating memory\n");
  error = cudaMalloc(&d_bitmap_metadata, sizeof(bitmap_metadata));
  if(error != cudaSuccess) printf("Error alocating memory\n");

  error = cudaMemcpy(d_data, data, sizeof(unsigned char) * hp->bitmapsize, cudaMemcpyHostToDevice);
  if(error != cudaSuccess) printf("Error transferring data from host to device\n");
  error = cudaMemcpy(d_bitmap_metadata, h_bitmap_metadata, sizeof(bitmap_metadata), cudaMemcpyHostToDevice);
  if(error != cudaSuccess) printf("Error transferring data from host to device\n");

  d_blur<<<blocksPerGrid, threadsPerBlock>>>(d_data, d_bitmap_metadata);
  error = cudaGetLastError();
  if(error != cudaSuccess) {
    printf("Kernel d_blur function error: %s\n", cudaGetErrorString(error));
  }

  error = cudaMemcpy(data, d_data, sizeof(unsigned char) * hp->bitmapsize, cudaMemcpyDeviceToHost);
  if(error != cudaSuccess) {
    printf("Error transferring data from device to host\n");
    printf("Error: %s\n", cudaGetErrorString(error));
  }

  out = fopen(output, "wb");

  n = fwrite(hp, sizeof(char), sizeof(bitmap_header), out);
  fseek(out, sizeof(char) * hp->fileheader.dataoffset, SEEK_SET);
  n = fwrite(data, sizeof(char), hp->bitmapsize, out);

  fclose(fp);
  fclose(out);
  free(hp);
  free(data);
  cudaFree(d_data);
  cudaFree(d_bitmap_metadata);
  return 0;
}

double time_spec_seconds(struct timespec* ts) {
  return (double) ts->tv_sec + (double) ts->tv_nsec * 1.0e-9;
}

int main(int argc, char **argv) {
  struct timespec tstart = {0,0}, tend = {0,0};
  char* original = argv[1];
  char* modified = argv[2];
  int kernel =  atoi(argv[3]);

  if (kernel < 3 || kernel > 15)
    printf("Invalid kernel value. Must be between [3, 15]");
  else {
    int r = clock_gettime(CLOCK_MONOTONIC, &tstart);

    if (r == -1) {
      printf("The clock_gettime() function failed: %s\n", strerror(errno));
      return 1;
    }

    blur(original, modified, kernel);

    r = clock_gettime(CLOCK_MONOTONIC, &tend);
    if (r == -1) {
      printf("The clock_gettime() function failed: %s\n", strerror(errno));
      return 1;
    }

    double delta = time_spec_seconds(&tend) - time_spec_seconds(&tstart);

    printf("%d\t%.4f\n", kernel, delta);
  }
}
