#include "stdio.h"
#include "omp.h"
#define N 4
#define t 4000000000 // iteraciones

void main()
{
    double pi = 0.0;
    int sig = -1;
    long long i;
    #pragma omp parallel for private(sig, i) reduction (+: pi)
    for(i = 1; i < t; i = i + 2){
      sig *= -1;
      pi += sig * 4.0 / i;
    }
    printf("Pi = %.20f\n", pi);	
}
