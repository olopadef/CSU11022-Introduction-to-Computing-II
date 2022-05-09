  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global   quicksort
  .global   partition
  .global   swap

@ quicksort subroutine
@ Sort an array of words using Hoare's quicksort algorithm
@ https://en.wikipedia.org/wiki/Quicksort 
@
@ Parameters:
@   R0: Array start address
@   R1: lo index of portion of array to sort
@   R2: hi index of portion of array to sort
@
@ Return:
@   none
quicksort:
  PUSH    {R4-R7, LR}                      @ add any registers R4...R12 that you use

  @ *** PSEUDOCODE ***
  MOV R4, R0                               @ startAdd = testArray
  MOV R5, R1                               @ lo = loIndex
  MOV R6, R2                               @ hi = hiIndex
  
  .LIfQ:                                    @ if (lo < hi) { // !!! You must use signed comparison (e.g. BGE) here !!!
    CMP R5, R6   
    BGE .LEndIfQ  
    MOV R0, R4                             @  arrayStart = startAdd
    MOV R1, R5                             @  loIndex = lo
    MOV R2, R6                             @  hiIndex = hi
    BL partition                           @  p = partition(array, lo, hi);
    MOV R7, R0                             @  cpyPivot = pivot
    MOV R0, R4                             @  testArray = startAdd
    MOV R1, R5                             @  lo = loIndex
    SUB R2, R7, #1                         @  hi = cpyPivot - 1 (p -1)
    BL quicksort                           @  quicksort(array, lo, p - 1);
    MOV R0, R4                             @  testArray = startAdd
    ADD R1, R7, #1                         @  lo = cpyPivot + 1
    MOV R2, R6                             @  hiIndex = hi
    BL quicksort                           @  quicksort(array, p + 1, hi);
  .LEndIfQ:                                 @ }

  POP     {R4-R7, PC}                      @ add any registers R4...R12 that you use


@ partition subroutine
@ Partition an array of words into two parts such that all elements before some
@   element in the array that is chosen as a 'pivot' are less than the pivot
@   and all elements after the pivot are greater than the pivot.
@
@ Based on Lomuto's partition scheme (https://en.wikipedia.org/wiki/Quicksort)
@
@ Parameters:
@   R0: array start address
@   R1: lo index of partition to sort
@   R2: hi index of partition to sort
@
@ Return:
@   R0: pivot - the index of the chosen pivot value
partition:
  PUSH    {R4-R9, LR}                      @ add any registers R4...R12 that you use

  @ *** PSEUDOCODE ***
  MOV R4, R0                               @ start = testArray
  MOV R5, R2                               @ hi = hiIndex                    
  LDR R6, [R4, R5, LSL #2]                 @ pivot = array[hi];
  MOV R7, R1                               @ i = lo   
  MOV R8, R7                               @ j = lo
  .LForPart:                               @ for (j = lo; j <= hi; j++) {
    CMP R8, R5       
    BGT .LEndForPart       
    .LIf:                                  @   if (array[j] < pivot) { 
      LDR R9, [R4, R8, LSL #2]             @     array[j]
      CMP R9, R6         
      BGE .LEndIf        
      MOV R0, R4                           @     arrayStart = start
      MOV R1, R7                           @     a = i
      MOV R2, R8                           @     b = j
      BL swap                              @     swap (array, i, j)
      ADD R7, R7, #1                       @     i = i + 1
    .LEndIf:                               @   }   
    ADD R8, R8, #1                         @ j++  
    B .LForPart          
  .LEndForPart:                            @ }
  MOV R0, R4                               @ arrayStart = start
  MOV R1, R7                               @ a = i
  MOV R2, R5                               @ b = hi
  BL swap                                  @ swap(array, i, hi);
  MOV R0, R7                               @ return i;

  @
  @ your implementation goes here
  @

  POP     {R4-R9, PC}                      @ add any registers R4...R12 that you use



@ swap subroutine
@ Swap the elements at two specified indices in an array of words.
@
@ Parameters:
@   R0: array - start address of an array of words
@   R1: a - index of first element to be swapped
@   R2: b - index of second element to be swapped
@
@ Return:
@   none
swap:
  PUSH    {R4-R6, LR}
  LDR R4, [R0, R1, LSL #2]                 @ a = array[index1]
  LDR R5, [R0, R2, LSL #2]                 @ b = array[index2]
  STR R5, [R0, R1, LSL #2]                 @ b = a
  STR R4, [R0, R2, LSL #2]                 @ a = b
  @
  @ your implementation goes here
  @

  POP     {R4-R6, PC}


.end