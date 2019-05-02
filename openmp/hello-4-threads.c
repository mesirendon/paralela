#include "omp.h"
#include "stdio.h"

void main(){
  #pragma omp parallel num_threads(4)
  {
    int ID = omp_get_thread_num();
    printf("hello (%d)", ID);
    printf(" world (%d) \n", ID);
  } //fin de region paralela
}
