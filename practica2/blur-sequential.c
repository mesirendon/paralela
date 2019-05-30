#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <errno.h>

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

int blur(char* input, char *output, int kernel) {

  //variable dec:
  FILE *fp, *out;
  bitmap_header* hp;
  int n, x, xx, y, yy, ile, avgR, avgB, avgG, B, G, R;
  unsigned char *data;
  int blurSize = kernel;


  //Open input file:
  fp = fopen(input, "r");
  if(fp == NULL){
    //cleanup
  }

  //Read the input file headers:
  hp = (bitmap_header*) malloc(sizeof(bitmap_header));
  if(hp == NULL)
    return 3;

  n = fread(hp, sizeof(bitmap_header), 1, fp);
  if(n < 1){
    //cleanup
  }
  //Read the data of the image:
  data = (char*) malloc(sizeof(char) * hp->bitmapsize);
  if(data == NULL){
    //cleanup
  }

  fseek(fp, sizeof(char) * hp->fileheader.dataoffset, SEEK_SET);
  n = fread(data, sizeof(char), hp->bitmapsize, fp);
  if(n < 1){
    //cleanup
  }

  for(xx = 0; xx < hp->width; xx++)
  {
    for(yy = 0; yy < hp->height; yy++)
    {
      avgB = avgG = avgR = 0;
      ile = 0;

      for(x = xx; x < hp->width && x < xx + blurSize; x++)
      {


        for(y = yy; y < hp->height && y < yy + blurSize; y++)
        {
          avgB += data[x*3 + y*hp->width*3 + 0];
          avgG += data[x*3 + y*hp->width*3 + 1];
          avgR += data[x*3 + y*hp->width*3 + 2];
          ile++;
        }
      }

      avgB = avgB / ile;
      avgG = avgG / ile;
      avgR = avgR / ile;

      data[xx*3 + yy*hp->width*3 + 0] = avgB;
      data[xx*3 + yy*hp->width*3 + 1] = avgG;
      data[xx*3 + yy*hp->width*3 + 2] = avgR;
    }
  }

  //Open output file:
  out = fopen(output, "wb");
  if(out == NULL){
    //cleanup
  }

  n = fwrite(hp, sizeof(char), sizeof(bitmap_header), out);
  if(n < 1){
    //cleanup
  }
  fseek(out, sizeof(char) * hp->fileheader.dataoffset, SEEK_SET);
  n = fwrite(data, sizeof(char), hp->bitmapsize, out);
  if(n < 1){
    //cleanup
  }

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
    int r = clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tstart);

    if (r == -1) {
      printf("The clock_gettime() function failed: %s\n", strerror(errno));
      return 1;
    }

    blur(original, modified, kernel);

    r = clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tend);
    if (r == -1) {
      printf("The clock_gettime() function failed: %s\n", strerror(errno));
      return 1;
    }

    double delta = time_spec_seconds(&tend) - time_spec_seconds(&tstart);

    printf("%d\t%d\t%.4f\n", kernel, threads, delta);
  }
}
