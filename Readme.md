# Custom Memory Allocator in ARM64 Assembly

A basic memory manager where you can allocate and free memory. It supports block splitting: if the free block has enough space for the requested size, plus the new metadata size, and still leaves a usable remainder (at least 16 bytes), it will divide the block in two to minimize internal fragmentation.

## How to use it

There's a C file (main.c) where you can see how to use all the functionalities so you can test and add new things if you want.

## How to compile 

Make sure you have gcc installed and are in a Linux environment

## Compile the code
```shell
gcc -g -o malloc main.c malloc.s
```

## After that you can just do:
```shell
./malloc
```

## And you are going to see something like this output:

```text
ptr1: 0xfffface93018, ptr2: 0xfffface93800
2024
ptr1: 0xfffface93018, ptr2: 0xfffface93800
