  .syntax unified
  .cpu cortex-m4
  .thumb

  .global arrdel


@
@ arrdell: deletes element at specified index in array of words
@
@ parameters:
@   R0: start address of array
@   R1: index of element to be deleted
@   R2: length of array(in elements)

arrdel:
@
PUSH {R4-R8, LR}                 @ push()

MOV R4, R0                    @ startAdd = testArray
MOV R5, R1                    @ indexDel = index
MOV R6, R2                    @ arrayLen = length

ADD R5, R5, #1                @ indexDel ++ (loading element after one to be deleted)
.LWhile:                      @ while(indexDel < arrayLen){
  CMP R5, R6
  BGE .LEndWhile
  SUB R7, R5, #1              @   indexBefore = indexDel - 1 (to be used to store element one postion to the left)
  LDR R8, [R4, R5, LSL #2]    @   elem = startAdd + (indexDel * 4)
  STR R8, [R4, R7, LSL #2]    @   startAdd +(indexBefore * 4) = elem 
  ADD R5, R5, #1
  B .LWhile
.LEndWhile:                   @ }

POP {R4-R8, PC}                 @ pop()
@

  .end