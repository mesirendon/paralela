#include "omp.h"
#include "stdio.h"

void main(){
  #pragma omp parallel //inicio de region paralela
  {
    int ID = omp_get_thread_num();
    printf("hello (%d)", ID);
    printf(" world (%d) \n", ID);
  } //fin de region paralela
}
