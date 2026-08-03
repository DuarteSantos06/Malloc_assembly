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

void coalesc(void *ptr, void *ptr1)
{
   struct block *b = (struct block *)((char *)ptr - sizeof(struct block));
   struct block *b1 = (struct block *)((char *)ptr1 - sizeof(struct block));
   printf("ptr1: %p\n", ptr);
   free(ptr);
   printf("herer\n");
   free(ptr1);
   printf("here\n");
   void *ptr2 = alloc(3000);
  printf("ptr2: %p\n", ptr2);
}

int main ()
{
    init();
    void *ptr = alloc(2000);
    if (ptr == NULL) {
        printf("Memory allocation failed\n");
        return 1;
    }

    void *ptr1= alloc(1000);
    printf("ptr1: %p, ptr2: %p\n", ptr, ptr1);
    int diff= ptr1-ptr;
    printf ( "%d\n",diff);
    void *next_pointer = (char *)ptr + diff;
    struct block *b = (struct block *)((char *)ptr - sizeof(struct block));
    struct block *b1 = (struct block *)((char *)ptr1 - sizeof(struct block));
    printf("%p\n",next_pointer);
    printf("ptr1: %p, ptr2: %p\n", b->next, b1->prev);
    printf("ptr1: %ld, ptr2: %ld\n", b->size, b1->size);
    coalesc(ptr,ptr1);
    return 0;
}
