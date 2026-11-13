#include <stdio.h>
#define N 10
#define DIM 1000
#define M (DIM * DIM)


__global__ void multiply_matrix(int *m_a, int *m_b, int *m_c) {
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;

	if (row < DIM && col < DIM) {
		int sum = 0;

		for (int k = 0; k < DIM; k++) {
			sum += m_a[row * DIM + k] * m_b[k * DIM + col];
		}
		m_c[row * DIM + col] = sum;
	}
} 

int main() {
	
	int *matrix_a = (int*)malloc(M * sizeof(int));
	int *matrix_b = (int*)malloc(M * sizeof(int));
	int *matrix_c = (int*)malloc(M * sizeof(int));
	int *dev_a, *dev_b, *dev_c;
	
	cudaMalloc((void**)&dev_a, M * sizeof(int));
	cudaMalloc((void**)&dev_b, M * sizeof(int));
	cudaMalloc((void**)&dev_c, M * sizeof(int));	
	
	for (int i = 0; i < M; i++) {
		if (i % 2 == 0) {
			matrix_a[i] = 2;
			matrix_b[i] = 4;
		} else {
			matrix_a[i] = 3;
			matrix_b[i] = 5;
		}
	}

	cudaMemcpy(dev_a, matrix_a, M * sizeof(int), cudaMemcpyHostToDevice);			
	cudaMemcpy(dev_b, matrix_b, M * sizeof(int), cudaMemcpyHostToDevice);	
			

	dim3 block(16, 16);
	dim3 grid((DIM + block.x -1) / block.x,
			  (DIM + block.y - 1) / block.y);

	multiply_matrix<<<grid, block>>>(dev_a, dev_b, dev_c);
	
	cudaError_t err = cudaGetLastError();

	if (err != cudaSuccess) {
		printf("Erro no kernel %s:", cudaGetErrorString(err));
		return 1;
	}

	cudaMemcpy(matrix_c, dev_c, M * sizeof(int), cudaMemcpyDeviceToHost);
	
	for (int i = 0; i < DIM; i++) {
		printf("%d ", matrix_c[i]);
	}
	
	cudaFree(dev_a); cudaFree(dev_b); cudaFree(dev_c);
	free(matrix_a); free(matrix_b); free(matrix_c);

	return 0;
}
