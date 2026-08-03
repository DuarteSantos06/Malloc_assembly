/* Syscall numbers*/
.equ SYS_EXIT, 93
.equ SYS_MMAP, 222

/* status codes */
.equ SUCCESS, 0
.equ error_args_value, 1



/*
  struct block{
    size_t size,
    int is_occ,
    block *next
  }
*/

.equ size, 0          /* the first 8 bytes represent the size of the block*/
.equ is_occ, 8        /* represents if the block is occupied, 1 if it is occupied, 0 if it is free*/
.equ prev, 16
.equ next, 24         /* this points to the next block in the list*/
.equ size_block, 32   /* this is the size of the metadata block, its useful in the free */

/* [  x19 |   x20  |  x21 |      ]
   [ size | is_occ | next | data ]  */


.bss
  head_ptr: .space 8


.global alloc
.global free
.global init

.text

init:
  B asks_for_memory

asks_for_memory:
  mov x8,#SYS_MMAP
  mov x0, #0        /* we let kernel choose the address he want to assign */
  mov x1, #4096     /* Remove this line, this line is here only because the argument in x1 is a string and should be converted using an atoi funcion*/
  mov x2, #3        /* PROT_READ | PROT_WRITE */
  mov x3, #34       /* MAP_PRIVATE | MAP_ANONYMOUS*/
  mov x4, #-1       /* fd is zero because we put the MAP_ANONYMOUS flag*/
  mov x5, #0        
  SVC #0

initiate_metadata_block:
  ldr x1, =head_ptr
  str x0, [x1]

  mov x9, #4072        /* the metadata block size doen't count*/
  str x9, [x0, #size]    /* store the value in x19 register (size) in the memory address of x0 + size */

  mov x10, #0             /* it is set to 0  because there is no data there */
  str x10, [x0, #is_occ]  /* store the value in x20 register (is_occ) in the memory addres of x0 + is_occ */

  mov x11, #0             /* it is 0/null because it's the only block we have right now */
  str x11, [x0, #next]    /* store the value in x21 register (next) in the memory address of x0 + next */

  ret

alloc:
  mov x4,x0               /* x0 has the first and only argument */
  ldr x1, =head_ptr
  ldr x2, [x1]            /* x2 points to the begin of the block */

alloc_loop:
  cmp x2, #0
  BEQ not_found

see_if_size_is_enough:
  ldr x3, [x2, #size]     /* we load the value in x2 + size */ 
  cmp x3, x4              /* if the size asked is bigger than the size we have we go to dont fit */
  BLT dont_fit

  ldr x3, [x2, #is_occ]   /* we load the value in x2 + is_occ */
  cmp x3, #1              /* if it is 1 it is occupied so we go to branch occupied */
  BEQ occupied

see_if_size_to_allocate_is_much_less_than_the_size_of_the_block:
  ldr x3, [x2, #size]     /* x3 has the size of the block we found */

  mov x5, x3              
  sub x5, x5, #size_block /* x5 has the size of the block minus the metadata size, which means */

  sub x5, x5 , x4         /* we take from x5, the size we want to allocate,it is on x4 */     

  /* if size we want to allocate is 50 and the size of the block is 100 x5 will be 26 at the end, our rule is that no block should be 
   * smaller than 16 so we have to check it 
   */
  
  cmp x5, #16
  BLT exact_fit

separate_the_block: 
  mov x6, x3                  /* x6 has the original size of the block */
  add x15, x4, #size_block
  add x7, x2, x4              /* x7 now points to the end of the new block */

  mov x15, #1
  str x15, [x2, #is_occ]      /* we set the block to occupied */

  mov x15, x4
  str x15, [x2, #size]  /* we set the size block to the size we want */

  str x5, [x7, #size]         /* the size of the new block is the rest we didn't allocate */  

  mov x15, #0 
  str x15, [x7, #is_occ]      /* we set the block to not occupied */  

  ldr x15, [x2, #next]
  str x15, [x7, #next]        /* the previous next block is now the next of the next block */ 

  str x7, [x2, #next]         /* the previous block now points to the metadata of the next */

  str x2, [x7, #prev]

  add x0, x2, #size_block
  ret

free:
  sub x1, x0 , #size_block    /* x0 is the pointer to the begining of the data file, so now x1 points to the begining of the metadata file */

check_left:
  ldr x3,[x1, #prev]          /* x3 points to he begining of the metadata of the previous block */
  cmp x3, #0
  BEQ check_right

  ldr x4,[x3, #is_occ]        /* load the value on offset is_occ */

  cmp x4, #0                  /* if it is not occupied we coalesc the blocks */
  BEQ coalesc_left

check_right:
  ldr x3, [x1, #next]         /* x3 points to he begining of the metadata of the next block */
  cmp x3, #0
  BEQ end_free

  ldr x4, [x3, #is_occ]       /* load the value on offset is_occ */

  cmp x4, #0                  /* if it is not occupied we coalesc the blocks */
  BEQ coalesc_right

end_free:
  mov x2, #0    
  str x2, [x1, #is_occ]

  ret


exact_fit:
  mov x15, #1
  str x15, [x2, #is_occ]
  add x0, x2, #size_block
  ret
  
/* x2 is the previous block, x1 is the current */
coalesc_left:
  ldr x4, [x3,#size]          /* x3 has the size of the previous block */
  ldr x5, [x1, #size]
  add x5, x5, x4              /* we sum the two block sizes */
  add x5, x5, #size_block

  str x5, [x3, #size]         /* we store the new block size */

  ldr x4, [x1, #next]         /* x4 has the next pointer block */
  cmp x4, #0
  BEQ skip_prev_update

  str x4, [x3, #next]         /* the next of the prev now is the next of the current freeing block */
  str x3, [x4, #prev]  
  ret 

skip_prev_update:
  ret


coalesc_right:
  ldr x4, [x3, #size]       /* x3 has the size of the next block */
  ldr x5, [x1, #size]       
  add x5, x5, x4            /* sum of the two block sizes */
  add x5, x5, #size_block

  str x5, [x1, #size]

  ldr x4, [x3, #next]
  str x4, [x1, #next]
  cmp x4, #0                
  BEQ skip_prev_update

  str x1, [x4, #prev]
  ret
  
  


dont_fit:
  ldr x2, [x2, #next]
  B alloc_loop


occupied:
  ldr x2, [x2, #next]
  B alloc_loop


not_found:
  mov x0, #0
  ret
