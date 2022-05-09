  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global   makeMagic


@ makeMagic
@ Generate an NxN 2D array that is a magic square, using the Siamese method.
@
@ Parameters:
@   R0: start address in memory where the magic square will be stored
@   R1: number of rows/columns (N) (must be odd)
@ Return:
@   none
makeMagic:
  PUSH    {LR}  

  MOV R4, R0                    @ startCpy = startStr
  MOV R5, R1                    @ N = N
  MOV R8, #2                    @ divisor

  MOV R0, R5              
  BL oddOrEven                  @ oddOrEven(N)

  MOV R6, R0                    @ result = return

  CMP R6, #1                    @ if(result ==1){
  BNE .LEven              

  MUL R6, R5, R5                @  maxSize = N^2
  UDIV R7, R5, R8               @  col = N/2

  MOV R9, #0                    @  count
  MOV R10, #0                   @  row = 0

  .LWh:                         @  while(count < maxSize) {
    ADD R9, R9, #1              @   count++
    CMP R9, R6        
    BGE .LEndWh       

    MOV R0, R10       
    MOV R1, R5        
    MOV R2, R7        
    BL convert2Dto1D            @   convert2Dto1D (row, N, col)
    MOV R11, R0                 @   result = return

    STR R9, [R4, R11, LSL #2]   @   array[row][col] = count

    CMP R10, #0                 @   if(row == 0) {
    BNE .LElse  

    MOV R0, R5  
    BL nMinusOne                @     nMinusOne(N)

    MOV R11, R0                 @     result = return

    CMP R7, R11                 @     if(col == result){
    BNE .LElse2 
    ADD R10, R10, #1            @      row++
    B .LEndIf 

    .LElse2:  
      MOV R0, R5  
      BL nMinusOne              @     nMinusOne(N)
      MOV R10, R0 
      ADD R7, R7, #1            @     col++
      B .LEndIf 

    .LElse: 

    MOV R0, R5  
    BL nMinusOne                @     nMinusOne(N)

    MOV R11, R0                 @     result = return

    CMP R7, R11                 @     if(col == result){
    BNE .LElse3 
    SUB R10, R10, #1            @      row--
    MOV R7, #0                  @      col = 0
    B .LEndIf 

    .LElse3:  

    SUB R11, R10, #1            @      row --
    ADD R12, R7, #1             @      col++

    MOV R0, R11 
    MOV R1, R5  
    MOV R2, R12 
    BL convert2Dto1D            @      convert2Dto1D(row, N, col)

    MOV R11, R0                 @      result = return

    LDR R12, [R4, R11, LSL #1]  @     val = array[row][col]
    CMP R12, #0                 @     if(val == 0){
    BNE .LElse4

    SUB R10, R10, #1            @       row--
    ADD R7, R7, #1              @       col++
    B .LEndIf

    .LElse4:
    ADD R10, R10, #1            @       row++

    .LEndIf:
    B .LWh
  .LEndWh:


  

  .LEven: 
  POP     {PC}

@ convert2Dto1D subroutine
@ calculates 1D index of 2D array
@ Parameters:
@   R0: row number
@   R1: row size (no of columns)
@   R2: column number
@ Return:
@   R0: index

convert2Dto1D: 

PUSH {R4-R7, LR}        @ registers used in subroutine

MOV R4, R0              @ r = rowNumber
MOV R5, R1              @ rS = rowSize
MOV R6, R2              @ c = columnNumber

MUL R7, R4, R5          @ index = r x rS
ADD R7, R7, R6          @ index += c

MOV R0, R7              @ return = index

POP {R4-R7, PC}

@ oddOrEven subroutine
@ determines whether the number of rows/cols in a 2D array of words is even/odd
@ Parameters:
@   R0: number of rows/ col (N)
@ Return:
@   R0: 0 if even, 1 if odd

oddOrEven:
PUSH {R4-R7, LR}

MOV R4, R0            @ number 
MOV R7, #2            @ divisor/ multiplier
UDIV R5, R4, R7       @ quotient = number/2 
MUL R5, R5, R7        @ result = quotient x 2
SUB R6, R4, R5        @ remainder = number - result

CMP R6, #1            @ if(remainder == 1){
BEQ .LOdd
MOV R0, #0
B .LEnd

.LOdd:
MOV R0, #1

.LEnd:

POP {R4-R7, PC}

@ nMinusOne subroutine
@ computes N - 1 
@ Parameters:
@   R0: N
@ Return:
@   R0: N -1
nMinusOne:

PUSH {R4, LR}

MOV R4, R0          @ N     

SUB R4, R4, #1      @ N--

MOV R0, R4          @ result

POP {R4, PC}


@
@ Use the following watch expression to inspect your new magic
@   square as you debug your program. Adjust dimensions [5][5] appropriately:
@
@ (int [5][5])newSquare
@


.end