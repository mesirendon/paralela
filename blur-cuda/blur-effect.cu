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

typedef struct _thread_data {
  int xmin;
  int xmax;
  int ymin;
  int ymax;
  unsigned char *data;
  bitmap_header * hp;
  int blurSize;
} thread_data;

void *parallel(void *thrdata) {
  thread_data *info = (thread_data *)thrdata;
  int xx, yy, avgB, avgG, avgR, ile;
  int xmin = info->xmin;
  int xmax = info->xmax;
  int ymin = info->ymin;
  int ymax = info->ymax;
  int blurSize = info->blurSize;
  unsigned char *data = info->data;
  bitmap_header *hp = info->hp;
  int x, y;

  for(xx = xmin; xx < xmax; xx++) {
    for(yy = ymin; yy < ymax; yy++) {
      avgB = avgG = avgR = ile = 0;

      for(x = xx; x < hp->width && x < xx + blurSize; x++) {
        for(y = yy; y < hp->height && y < yy + blurSize; y++) {
          avgB += data[x * 3 + y * hp->width * 3 + 0];
          avgG += data[x * 3 + y * hp->width * 3 + 1];
          avgR += data[x * 3 + y * hp->width * 3 + 2];
          ile++;
        }
      }

      avgB /= ile;
      avgG /= ile;
      avgR /= ile;

      data[xx * 3 + yy * hp->width * 3 + 0] = avgB;
      data[xx * 3 + yy * hp->width * 3 + 1] = avgG;
      data[xx * 3 + yy * hp->width * 3 + 2] = avgR;
    }
  }
}

int blur(char* input, char *output, int kernel, int threads) {
  int dev = 0;
  cudaSetDevice(dev);
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, dev);

  int threadsPerBlock = _ConvertSMVer2Cores(deviceProp.major, deviceProp.minor);
  int blocksPerGrid = deviceProp.multiProcessorCount;

  FILE *fp, *out;
  bitmap_header* hp;
  int n, x, xx, y, yy, ile, avgR, avgB, avgG, B, G, R;
  unsigned char *data;
  int rc, i, blurSize = kernel;

  int N = threads;
  thread_data thrdata[threads];

  fp = fopen(input, "r");

  hp = (bitmap_header*) malloc(sizeof(bitmap_header));
  if(hp == NULL)
    return 3;

  n = fread(hp, sizeof(bitmap_header), 1, fp);
  data = (char*) malloc(sizeof(char) * hp->bitmapsize);

  fseek(fp, sizeof(char) * hp->fileheader.dataoffset, SEEK_SET);
  n = fread(data, sizeof(char), hp->bitmapsize, fp);

  // Uso de OpenMP
  #pragma omp parallel num_threads(threads)
  {
    int thr = omp_get_thread_num();
    for(int i = 0; i < thr; i++) {
      thrdata[i].xmin = hp->width / thr * i;
      thrdata[i].xmax = hp->width / thr * (i + 1);
      thrdata[i].ymin = 0;
      thrdata[i].ymax = hp->height;
      thrdata[i].data = data;
      thrdata[i].blurSize = blurSize;
      thrdata[i].hp = hp;
      parallel(thrdata);
    }
  } // Fin de region paralela

  out = fopen(output, "wb");

  n = fwrite(hp, sizeof(char), sizeof(bitmap_header), out);
  fseek(out, sizeof(char) * hp->fileheader.dataoffset, SEEK_SET);
  n = fwrite(data, sizeof(char), hp->bitmapsize, out);

  fclose(fp);
  fclose(out);
  free(hp);
  free(data);
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
  int threads = atoi(argv[4]);

  if (kernel < 3 || kernel > 15)
    printf("Invalid kernel value. Must be between [3, 15]");
  else {
    int r = clock_gettime(CLOCK_MONOTONIC, &tstart);

    if (r == -1) {
      printf("The clock_gettime() function failed: %s\n", strerror(errno));
      return 1;
    }

    blur(original, modified, kernel, threads);

    r = clock_gettime(CLOCK_MONOTONIC, &tend);
    if (r == -1) {
      printf("The clock_gettime() function failed: %s\n", strerror(errno));
      return 1;
    }

    double delta = time_spec_seconds(&tend) - time_spec_seconds(&tstart);

    printf("%d\t%d\t%.4f\n", kernel, threads, delta);
  }
}
