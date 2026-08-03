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
    void *next_pointer = (char *)ptr + diff;
    printf("%p\n",next_pointer);
    printf("ptr1: %p, ptr2: %p\n", b->next, b1->prev);
    printf("ptr1: %ld, ptr2: %ld\n", b->size, b1->size);
    return 0;
}
