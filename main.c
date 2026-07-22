#include <stdio.h>


extern void* alloc(size_t size);
extern void free(void* ptr);
extern void init();

int main ()
{
    init();
    void *ptr = alloc(2000);
    if (ptr == NULL) {
        printf("Memory allocation failed\n");
        return 1;
    }

    void *ptr1= alloc(100);
    printf("ptr1: %p, ptr2: %p\n", ptr, ptr1);
    int diff= ptr1-ptr;
    printf ( "%d\n",diff);
    free(ptr);
    ptr=alloc(2000);
    printf("ptr1: %p, ptr2: %p\n",ptr,ptr1);
    return 0;
}
