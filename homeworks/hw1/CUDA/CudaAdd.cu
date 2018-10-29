#include "cuda_runtime.h"
#include <stdio.h>
#include <stdlib.h>

struct vec3 {
	float x, y, z;
};

__global__ void vectorAdd(struct vec3 *v1, struct vec3 *v2, struct vec3 *result) {
	int tid = threadIdx.x;
	/*	  1-1. write vector addition function						*/

	result->x = v1->x + v2->x;
	result->y = v1->y + v2->y;
	result->z = v1->z + v2->z;
}


int main( void )
{
	/*	  2-1. Check whether a proper device is mounted 			*/
    cudaError_t cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stdout, "cudaSetDevice failed! Do you have a CUDA-capable GPU installed?");
    }
    
	/*	  2-2. Declare Host and Device pointer variables			*/
    struct vec3 *a, *b, *c;
    struct vec3 *dev_a, *dev_b, *dev_c;

	/*    2-3. Allocate Host memory									*/
	a = (struct vec3*)malloc(sizeof(struct vec3));
	b = (struct vec3*)malloc(sizeof(struct vec3));
	c = (struct vec3*)malloc(sizeof(struct vec3));
    
	/*    2-4. Allocate Device memory								*/
	cudaStatus = cudaMalloc((void**) &dev_a, sizeof(struct vec3));
	cudaStatus = cudaMalloc((void**) &dev_b, sizeof(struct vec3));
	cudaStatus = cudaMalloc((void**) &dev_c, sizeof(struct vec3));
    
	/*    2-5. Check that memory is allocated well on Device		*/
	if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
    }
    
	/*    2-6. Setup Input values to host array						*/
	a->x = 1;
	a->y = 2;
	a->z = 3;
	b->x = 10;
	b->y = 20;
	b->z = 30;

	/*    2-7. Copy memory for Input array from Host to Device		*/
    cudaStatus = cudaMemcpy(dev_a, a, sizeof(struct vec3), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpyHostToDevice a failed!");
	}
	
	cudaStatus = cudaMemcpy(dev_b, b, sizeof(struct vec3), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpyHostToDevice b failed!");
    }

	/*	  2-8. Call Kernel Function with <<<1, 1>>>					*/
	vectorAdd<<<1,1>>>(dev_a, dev_b, dev_c);

	/*    2-9. Copy memory for Result from Device to Host			*/
	cudaStatus = cudaMemcpy(c, dev_c, sizeof(struct vec3), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpyDeviceToHost failed!");
	}
	
	/*    2-10. Print Results										*/
	fprintf(stdout, "a: {x=%f, y=%f, z=%f}\n", a->x, a->y, a->z);
	fprintf(stdout, "b: {x=%f, y=%f, z=%f}\n", b->x, b->y, b->z);
	fprintf(stdout, "sum: {x=%f, y=%f, z=%f}\n", c->x, c->y, c->z);

	/*    2-11. Release Host and Device memory						*/
	free(a);
	free(b);
	free(c);
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);

	return 0;

}

// nvcc [fileName] -o [outName]