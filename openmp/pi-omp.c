#include "stdio.h"
#include "omp.h"
#define N 4
#define t 4000000000 // iteraciones

double parcialPi[N];

double calcPi(long long k) {
  long long max = t*(k+1)/N;
  long long min = t*k/N;
  double x = 0.0;
  int sig = -1;
  long long i;
  for(i=min+1; i<max; i=i+2){
    sig *= -1;
    x += sig*4.0/i;
  }
  return x;
}

double valorPi(){
  int i; 
  double pi = 0.0;
  for (i=0; i<N; i++){
    pi += parcialPi[i];
  }
  return pi;
}

void valoresParcialesPi(){
  int i;
  for(i=0; i<N; i++){
    printf("parcialPi[%d] = %.20f\n", i, parcialPi[i]);
  }
}

void main()
{
    #pragma omp parallel num_threads(N)
    {
        int k = omp_get_thread_num();
	parcialPi[k] = calcPi(k);
        //printf(" hello(%d)", ID);
        //printf(" world(%d)\n", ID);
    } //fin de region paralela
    valoresParcialesPi();
    printf("Pi = %.20f\n", valorPi());	
}