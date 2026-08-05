#include <stdio.h>


extern void* alloc(size_t size);
extern void free(void* ptr);
extern void init();

struct block {
    size_t size;
    int is_occ;
    struct block *prev;
    struct block *next;
};

/*
* This function will test the coalesc, ptr2 will have the same addres as ptr,
* you can add a lot more alloc and malloc to test the coalesc function, but this is a simple test to see if the coalesc function is working correctly.
*/
void coalesc(void *ptr1, void *ptr2)
{
   struct block *b1 = (struct block *)((char *)ptr1 - sizeof(struct block));
   struct block *b2 = (struct block *)((char *)ptr2 - sizeof(struct block));
   free(ptr2);
   printf("is_occ ptr1: %d\n", b2->is_occ);
   free(ptr1);
   printf("is_occ ptr: %d\n", b1->is_occ);
   printf("ptr1: %p\n", b1->next);       /* it is expected to be nill as we have only one block, there is no next*/
}

int main ()
{
    init();
    void *ptr1 = alloc(2000);
    if (ptr1 == NULL) {
        printf("Memory allocation failed\n");
        return 1;
    }

    void *ptr2= alloc(1000);
    printf("ptr1: %p, ptr2: %p\n", ptr1, ptr2);
    int diff= ptr2-ptr1;
    printf ( "%d\n",diff);          /* can see that the diff is 2032, which is exactly the 2000 bytes allocated on the first request plus the 32 metadata block that we skip on ptr1*/
    struct block *b1 = (struct block *)((char *)ptr1 - sizeof(struct block));
    struct block *b2 = (struct block *)((char *)ptr2 - sizeof(struct block));
    printf("%p,%p\n",b1->next,b2->prev);
    printf("%ld\n", b2->size);
    coalesc(ptr1,ptr2);
    return 0;
}
