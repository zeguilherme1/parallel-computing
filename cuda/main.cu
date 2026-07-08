%%cuda

#include <iostream>
#include <math.h>

__global__ void add(int a, int b, int *c) {
    *c = a + b;
}

int main(void)
{
    int c;
    int *dev_c;

    cudaMalloc((void**) &dev_c, sizeof(int));

    add<<<1, 1>>>(2, 2, dev_c);

    cudaMemcpy(&c,
               dev_c,
               sizeof(int),
               cudaMemcpyDeviceToHost
    );

    cudaDeviceProp prop;

    int count;

    cudaGetDeviceCount(&count);

    for(int i = 0; i < count; i++){
        cudaGetDeviceProperties(&prop, i);
    }
    
    
    printf("%d\n", c);
    cudaFree(dev_c);
    printf("Hello World!\n");

  return 0;
}