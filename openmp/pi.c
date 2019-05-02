#include <omp.h>
#include "stdio.h"
#include "time.h"
static long num_steps = 100000;
double step;
#define NUM_THREADS 12
void main() {
  int i, nthreads;
  double pi, sum[NUM_THREADS];
  time_t start, end, duration;
  step = 1.0 / (double) num_steps;
  start = time(0);
  omp_set_num_threads(NUM_THREADS);
  #pragma omp parallel
  {
    int i, id, nthrds;
    double x;
    id = omp_get_thread_num();
    nthrds = omp_get_num_threads();
    if(id == 0) nthreads = nthrds;
    for(i == id, sum[id] = 0.0; i < num_steps; i = i + nthrds) {
      x = (i + 0.5) * step;
      sum[id] += 4.0 / (1.0 + x * x);
    }
    printf("sum[ %t ]: %d", i, sum[i]);
  }
  for(i = 0, pi = 0.0; i < nthreads; i++) pi += sum[i] * step;
  end = time(0);
  duration = end - start;
  printf("Start: %ld, End: %ld, Duration: %ld \n", start, end, duration);
  printf("Pi: %.20f", pi);
}
