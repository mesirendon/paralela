#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#define N 3

typedef struct _thread_data_t {
  int tid;
  int *data_p;
  int avg;
} thread_data_t;

void *average(void *dat) {
  thread_data_t *data = (thread_data_t *)dat;
  int min = 10 / N * data->tid;
  int max = 10 / N * (data->tid + 1);
  int res = 0;
  for(int i = min; i < max; i++) {
    printf("%d", data->data_p[i]);
    res += data->data_p[i];
  }
  printf("\n");
  data->avg = res / (max - min);
}

void main() {
  pthread_t threads[N];
  thread_data_t dat[N];
  int i, rc;

  int data[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  int *data_p = (int *) &data;

  for(i = 0; i < N; i++) {
    dat[i].tid = i;
    dat[i].data_p = data_p;
    if((rc = pthread_create(&threads[i], NULL, average, &dat[i]))) {
      fprintf(stderr, "error: pthread_create, rc: %d\n", rc);
    }
  }

  for (i = 0; i < N; ++i) {
    pthread_join(threads[i], NULL);
  }

  int avg = 0;

  for(i = 0; i < N; i++)
    avg += dat[i].avg;

  avg /= N;

  printf("Average: %d\n", avg);
}
