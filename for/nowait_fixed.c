//programa para mostrar sentencia nowait y atomic
// se soluciona para mas de 1 hilo

#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define	SIZE	1000000000

void iteration1(double *a, long n)
{
	int i;
	for (i=1; i<n; i++){
		*a = *a + i;
	}
	printf("\niter 1"); fflush(stdout);
}

void iteration2(double *b, long m)
{
	int i;
	for (i=1; i<m; i++){
		*b = *b + i;
	}
	printf("\niter 2"); fflush(stdout);	
}

void nowait_example(long n, long m, double *a, double *b)
{ 	 int i, id;

	 #pragma omp parallel sections//private(id)
	 {	
		#pragma omp section
			iteration1(a, n);
		
		#pragma omp section
			iteration2(b, m);

	}
}

int main()
{
	double *a, *b;
	a = malloc(sizeof(double));
	b = malloc(sizeof(double));

	omp_set_num_threads(4);		
	*a = 0.0;
 	*b = 0.0; 	
	nowait_example(SIZE, SIZE, a, b);
	printf("\n Total a: %f  b: %f...", *a, *b); fflush(stdout);

	free(a);
	free(b);	

}
