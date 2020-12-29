#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>

#define THREADS 30
#define BLOCKS 200
#define SIZE 6000

__device__ float d_A[SIZE][SIZE];
__device__ float d_B[SIZE][SIZE];
__device__ float d_C[SIZE][SIZE];
__device__ float d_D[SIZE][SIZE];
__device__ float d_V[SIZE];
__device__ float d_VET[SIZE];
__device__ float ESCALAR = 1.25;

__global__ void load()
{
    for(int i = 0; i < SIZE; i++)
    {
        for(int j = 0; j < SIZE; j++) 
        {
            d_A[i][j] = i + j;
            d_B[i][j] = i + j;
            d_C[i][j] = 0;
            d_D[i][j] = 0;
        }

        d_V[i] = i;
        d_VET[i] = 0;
    }
}

__global__ void sumA_B()
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if(i < SIZE && j < SIZE)
        d_C[i][j] = d_A[i][j] + d_B[i][j];
}

__global__ void mulA_B()
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if(i < SIZE && j < SIZE)
    {
        for(int k = 0; k < SIZE; k++) 
            d_D[i][j] += d_A[i][k] * d_B[k][j];
    }
}

__global__ void mulA_ESCALAR()
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if(i < SIZE && j < SIZE)
        d_A[i][j] *= ESCALAR;
}

__global__ void mulB_V()
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if(i < SIZE)
    {
        for(int j = 0; j < SIZE; j++)
            d_VET[i] += d_B[i][j] * d_V[j];
    }
}

int main()
{  
    clock_t begin, end;

    cudaSetDevice(0);  
    load<<<1, 1>>>();
    cudaDeviceSynchronize();
    
    printf("Somar A e B e armazenar em C.\n");
    begin = clock();
    sumA_B<<<dim3(BLOCKS, BLOCKS), dim3(THREADS, THREADS)>>>();
    cudaDeviceSynchronize();
    end = clock();
    printf("Feito em %.3f segundos.\n", double(end - begin) / CLOCKS_PER_SEC);

    printf("Multiplicar A e B e armazenar em D.\n");
    begin = clock();
    mulA_B<<<dim3(BLOCKS, BLOCKS), dim3(THREADS, THREADS)>>>();
    cudaDeviceSynchronize();
    end = clock();
    printf("Feito em %.3f segundos.\n", double(end - begin) / CLOCKS_PER_SEC);

    printf("Multiplicar A e ESCALAR e armazenar em A.\n");
    begin = clock();
    mulA_ESCALAR<<<dim3(BLOCKS, BLOCKS), dim3(THREADS, THREADS)>>>();
    cudaDeviceSynchronize();
    end = clock();
    printf("Feito em %.3f segundos.\n", double(end - begin) / CLOCKS_PER_SEC);
    
    printf("Multiplicar B e V e armazenar em VET.\n");
    begin = clock();
    mulB_V<<<BLOCKS, THREADS>>>();    
    cudaDeviceSynchronize();
    end = clock();
    printf("Feito em %.3f segundos.\n", double(end - begin) / CLOCKS_PER_SEC);
}