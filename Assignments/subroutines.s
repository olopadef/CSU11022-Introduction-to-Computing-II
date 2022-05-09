  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global  get9x9
  .global  set9x9
  .global  average9x9
  .global  blur9x9


@ get9x9 subroutine
@ Retrieve the element at row r, column c of a 9x9 2D array
@   of word-size values stored using row-major ordering.
@
@ Parameters:
@   R0: address - array start address
@   R1: r - row number
@   R2: c - column number
@
@ Return:
@   R0: element at row r, column c
get9x9:
  PUSH    {R4-R7, LR}                      @ add any registers R4...R12 that you use

  @
  @ your implementation goes here
  MOV R4, R0                               @ startAdd = origArray
  MOV R5, #9                               @ sizeArray = 9
  .LIfValid:                               @ if(rowNumber < sizeArray && colNumber < sizeArray && rowNumber >= 0 && colNumber >= 0){
    CMP R1, R5           
    BGT .LEndIfValid           
    CMP R2, R5           
    BGT .LEndIfValid           
    CMP R1, #0           
    BLT .LEndIfValid           
    CMP R2, #0           
    BLT .LEndIfValid           
    MOV R6, R1                             @    offset = rowNumber
    MUL R6, R6, R5                         @    offset *= sizeArray
    ADD R6, R6, R2                         @    offset += colNumber
    LDR R7, [R4, R6, LSL #2]               @    elem = array[rowNumber][colNumber]     
    MOV R0, R7                             @ 
  .LEndIfValid:
  @

  POP     {R4-R7, PC}                      @ add any registers R4...R12 that you use



@ set9x9 subroutine
@ Set the value of the element at row r, column c of a 9x9
@   2D array of word-size values stored using row-major
@   ordering.
@
@ Parameters:
@   R0: address - array start address
@   R1: r - row number
@   R2: c - column number
@   R3: value - new word-size value for array[r][c]
@
@ Return:
@   none
set9x9:
  PUSH    {R4-R7, LR}                      @ add any registers R4...R12 that you use

  @
  @ your implementation goes here
  MOV R4, R0                               @ startAdd = origArray
  MOV R5, #9                               @ sizeArray = 9
  .LIfValid2:                              @ if(rowNumber < sizeArray && colNumber < sizeArray && rowNumber >= 0 && colNumber >= 0){
    CMP R1, R5           
    BGT .LEndIfValid2          
    CMP R2, R5           
    BGT .LEndIfValid2          
    CMP R1, #0           
    BLT .LEndIfValid2          
    CMP R2, #0           
    BLT .LEndIfValid2          
    MOV R6, R1                             @    offset = rowNumber
    MUL R6, R6, R5                         @    offset *= sizeArray
    ADD R6, R6, R2                         @    offset += colNumber
    LDR R7, [R4, R6, LSL #2]               @    elem = array[rowNumber][colNumber]     
    STR R3, [R4, R6, LSL #2]               @    array[rowNumber][colNumber] = value
  .LEndIfValid2:           
  @          

  POP     {R4-R7, PC}                      @ add any registers R4...R12 that you use



@ average9x9 subroutine
@ Calculate the average value of the elements up to a distance of
@   n rows and n columns from the element at row r, column c in
@   a 9x9 2D array of word-size values. The average should include
@   the element at row r, column c.
@
@ Parameters:
@   R0: address - array start address
@   R1: r - row number
@   R2: c - column number
@   R3: n - element radius
@
@ Return:
@   R0: average value of elements
average9x9:
  PUSH    {R4-R11,LR}               @ add any registers R4...R12 that you use
  MOV R4, R0                        @ startAdd = origArray
  MOV R5, #0                        @ row = 0
  MOV R6, #0                        @ col = 0
  MOV R7, #0                        @ sum = 0
  MOV R8, #0                        @ noOfElements = 0
  ADD R9, R1, R3                    @ rWidth = r + radius

  .LIfWithin:                       @ if(rWidth >= 9){
    CMP R9, #9
    BLT .LEndIfWithin
    MOV R9, #8                      @   rWidth = 8
  .LEndIfWithin:                    @ }

  ADD R10, R2, R3                   @   cWidth = c + radius 

  .LIfWithin2:                      @ (cWidth >= 9){
    CMP R10, #9
    BLT .LEndIfWithin2
    MOV R10, #8                     @   cWidth = 8
  .LEndIfWithin2:                   @ }

  .LIfSet:                          @ if(r < radius){
    CMP R1, R3
    BGE .LGreater
    MOV R5, #0                      @  row = 0
    B .LEndIfSet
    .LGreater:
    SUB R5, R1, R3                  @     row = r - radius
  .LEndIfSet:                       @ } 

  .LIfSet2:                         @ (c < radius){
    CMP R2, R3                      
    BGE .LGreater2
    MOV R6, #0                      @   col = 0
    B .LEndIfSet2
    .LGreater2:                   
    SUB R6, R2, R3                  @   col = c - radius 
  .LEndIfSet2:                      @ }

  MOV R11, R6                       @ currentCol = col
  .LWhileRow:                       @ while( row <= rWidth){
    CMP R5, R9      
    BGT .LEndWhileRow
    MOV R6, R11                     @   col = currentCol
    .LWhileCol:                     @   while( col <= cWidth){
      CMP R6, R10                   
      BGT .LEndWhileCol
      MOV R2, R6                    @     columnNumber = col
      MOV R1, R5                    @     rowNumber = row
      MOV R0, R4                    @     origArray = startAdd
      BL get9x9                     @     get9x9(row, col, start)
      ADD R7, R7, R0                @     sum+= elem[rowNumber][columNumber]
      ADD R8, R8, #1                @     noOfElements++
      ADD R6, R6, #1                @     col++
      B .LWhileCol
    .LEndWhileCol:                  @ }   
    ADD R5, R5, #1                  @   row++
    B .LWhileRow
  .LEndWhileRow:                    @   }
  UDIV R0, R7, R8                   @ average = sum / noOfElements
  @
  @ your implementation goes here
  @

  POP     {R4-R11,PC}                      @ add any registers R4...R12 that you use



@ blur9x9 subroutine
@ Create a new 9x9 2D array in memory where each element of the new
@ array is the average value the elements, up to a distance of n
@ rows and n columns, surrounding the corresponding element in an
@ original array, also stored in memory.
@
@ Parameters:
@   R0: addressA - start address of original array
@   R1: addressB - start address of new array
@   R2: n - radius
@
@ Return:
@   none
blur9x9:
  PUSH    {R4-R7,LR}                      @ add any registers R4...R12 that you use
  MOV R4, R0                        @ startAdd = origArray
  MOV R5, R1                        @ startAddN = newArray
  MOV R6, R2                        @ radius = n
  MOV R7, #0                        @ r = 0
  .LWhileBlurRow:                   @ while(r<9) {
    CMP R7, #9
    BGE .LEndWhileBlurRow
    MOV R8, #0                      @   c = 0
    .LWhileBlurCol:                 @   while(c<9){
      CMP R8, #9
      BGE .LEndWhileBlurCol
      MOV R0, R4                    @     origArray = startAdd
      MOV R1, R7                    @     row = r
      MOV R2, R8                    @     col = c
      MOV R3, R6                    @     n = radius
      BL average9x9
      MOV R3, R0                    @     value = origArray
      MOV R1, R7                    @     row = r
      MOV R2, R8                    @     col = c
      MOV R0, R5                    @     origArray = startAddN
      BL set9x9
      ADD R8, R8, #1                @     c++
      B .LWhileBlurCol
    .LEndWhileBlurCol:              @   }
    ADD R7, R7, #1                  @ r++
    B .LWhileBlurRow
  .LEndWhileBlurRow:                @ }  
  @
  @ your implementation goes here
  @

  POP     {R4-R7,PC}                      @ add any registers R4...R12 that you use

.end