  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global   isMagic
  


@ isMagic
@ Determine whether a square 2D array of word-size values stored in memory
@   (RAM) is a magic square, where each row, column and diagonal sum to the
@   same value and the array contains the positive integers from 1 to N^2.
@
@ Parameters:
@   R0: start address of NxN square 2D array
@   R1: number of rows/columns (N)
@ Return:
@   R0: 0 if the 2D array is not a magic square
@       1 if the 2D array is a magic square
isMagic:
  PUSH  {R4-R10, LR}

  MOV R4, R0                        @ startCpy = startAdd
  MOV R5, R1                        @ N = N

  MOV R0, R4
  MOV R1, R5
  BL sumTBLR                        @ sumTBLR (startCpy, N)
  MOV R6, R0                        @ sumTBLR = retun

  MOV R0, R4
  MOV R1, R5
  BL sumTLBR                        @ sumTLBR (startCpy, N)
  MOV R7, R0                        @ sumTLBR = return
  
  .LIf:                             @ if(sumTLBR == sumTRBL){
    CMP R6, R7
    BNE .LEndIf

    MOV R0, R4
    MOV R1, R5
    BL rowTotal                     @ rowTotal (startCpy, N)
    MOV R8, R0                      @ rowTotal = retun

    MOV R0, R4
    MOV R1, R5
    BL colTotal                     @ colTotal (startCpy, N)
    MOV R9, R0                      @ colTotal = return
    
    .LIf2:                          @  if(rowTotal != colTotal || colTotal != sumTLBR){
      CMP R8, R9
      BNE .LEndIf
      CMP R9, R7
      BNE .LEndIf
      MOV R10, #1                   @   isMagic = true
      B .LEnd
    .LEndIf2:                       @  }
  .LEndIf:                          @ }
  MOV R10, #0                       @ isMagic = false

  .LEnd: 

  MOV R0, R10

  POP   {R4-R10, PC}

@ colTotal subroutine
@ calculates sum of columns in 2D array of word size values
@ Parameters:
@   R0: start address of NxN square 2D array
@   R1: number of rows/columns (N)
@ Return:
@   R0: colTotal

colTotal:

PUSH {R4-R10, LR}

MOV R4, R0
MOV R5, R1

MOV R6, #0                      @ colTotal = 0
MOV R7, #0                      @ row = 0
MOV R8, #0                      @ col = 0

.LWhCol:                        @ while(row < N){
  CMP R7, R5
  BGE .LEndWhCol

  .LWhCol2:                     @  while(col < N){
   CMP R8, R5
   BGE .LEndWhCol2

   MOV R0, R8
   MOV R1, R5
   MOV R2, R7
   BL convert2Dto1D             @   convert2Dto1D(col, N, row)

   MOV R9, R0                   @   index = return

   LDR R10, [R4, R9, LSL #2]    @   value = array[row][col]
   ADD R6, R6, R10              @   colTotal += value

   ADD R7, R7, #1               @   row++
   B .LWhCol2
  .LEndWhCol2:                  @  }
  ADD R8, R8, #1                @   col++
  B .LWhCol
.LEndWhCol:                     @ }

MOV R0, R6

POP {R4-R10, PC}

@ rowTotal subroutine
@ calculates sum of rows in 2D array of word size values
@ Parameters:
@   R0: start address of NxN square 2D array
@   R1: number of rows/columns (N)
@ Return:
@   R0: rowTotal

rowTotal:
  PUSH {R4-R10, LR}

MOV R4, R0
MOV R5, R1

MOV R6, #0                      @ rowTotal = 0
MOV R7, #0                      @ row = 0
MOV R8, #0                      @ col = 0

.LWhRow:                        @ while(row < N){
  CMP R7, R5
  BGE .LEndWhRow
  .LWhRow2:                     @  while(col < N){
    CMP R8, R5
    BGE .LEndWhRow2

    MOV R0, R7
    MOV R1, R5
    MOV R2, R8
    BL convert2Dto1D            @   convert2Dto1D(row, N, col)

    MOV R9, R0                  @   index = return
    LDR R10, [R4, R9, LSL #2]   @   value = array[row][col]
    ADD R6, R6, R10             @   rowTotal += value
  
    ADD R7, R7, #1              @   row++
    B .LWhRow2
  .LEndWhRow2:                  @  }
  ADD R8, R8, #1                @   col++
  B .LWhRow
.LEndWhRow:                     @ }

MOV R0, R6

POP {R4-R10, PC}

@ sumTLBR subroutine
@ calculates sum of diagonal TLBR in 2D array of word size values
@ Parameters:
@   R0: start address of NxN square 2D array
@   R1: number of rows/columns (N)
@ Return:
@   R0: sumTLBR

sumTLBR: 
PUSH {R4-R9, LR}

MOV R4, R0                          @ startCpy = startAdd
MOV R5, R1                          @ N = N
MOV R6, #0                          @ sumTLBR = 0
MOV R7, #0                          @ row = 0

.LWhSum1:                           @ while(row < N){
    CMP R7, R5          
    BGE .LEndWhSum1        

    MOV R0, R7                      @   parameters for subroutine
    MOV R1, R5           
    MOV R2, R7           
    BL convert2Dto1D                @   convert2Dto1D(row, N, row)
 
    MOV R8, R0                      @   index = return
 
    LDR R9, [R4, R8, LSL #2]        @   value = array[row][row]
    ADD R6, R6, R9                  @   sumTLBR += value 

    ADD R7, R7, #1                  @   row++
    B .LWhSum1
  .LEndWhSum1:                      @ }

  MOV R0, R6

  POP {R4-R9, PC}

@ sumTBLR subroutine
@ calculates sum of diagonal TBLR in 2D array of word size values
@ Parameters:
@   R0: start address of NxN square 2D array
@   R1: number of rows/columns (N)
@ Return:
@   R0: sumTBLR
  sumTBLR:                                             

  PUSH {R4-R11, LR}

  MOV R4, R0                          @ startCpy = startAdd
  MOV R5, R1                          @ N = N
  MOV R6, #0                          @ sumTLBR = 0
  MOV R7, #0                          @ row = 0
  MOV R8, #0                          @ col = 0
  MOV R9, #0                          @ sumTBLR = 0

  .LWhSum2:                           @ while(row < N){
    CMP R7, R5          
    BGE .LEndWhSum2

    SUB R8, R5, #1                    @   col = N--
    SUB R8, R8, R7                    @   col -= row
 
    MOV R0, R7                        @   parameters for subroutine
    MOV R1, R5           
    MOV R2, R8           
    BL convert2Dto1D                  @   convert2Dto1D(row, N, col)
 
    MOV R10, R0                       @   index = return
 
    LDR R11, [R4, R10, LSL #2]        @   value = array[row][col]
    ADD R9, R9, R11                   @   sumTRBL += value

    ADD R7, R7, #1                    @   row++
    B .LWhSum2
  .LEndWhSum2:                        @ }

  MOV R0, R9

  POP {R4-R11, PC}

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

@
@ Use the following watch expression to inspect the 2D array as you debug 
@   your program. Adjust the dimensions [3][3] appropriately:
@
@ (int [3][3])testSquare
@



.end