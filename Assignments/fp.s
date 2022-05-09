  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global   fp_exp
  .global   fp_frac
  .global   fp_enc



@ fp_exp subroutine
@ Obtain the exponent of an IEEE-754 (single precision) number as a signed
@   integer (2's complement)
@
@ Parameters:
@   R0: IEEE-754 number
@
@ Return:
@   R0: exponent (signed integer using 2's complement)
fp_exp:
  PUSH    {R4- R5, LR}                   @ add any registers R4...R12 that you use
  MOV R4, R0                             @ num = IEEE-754 number
  LDR R5, =0x7F800000                    @ mask (1s in pos f and s)
  AND R4, R4, R5                         @ apply mask to f and s
  MOV R4, R4, LSR #23                    @ isolating e
  SUB R0, R4, #127                       @ e + 127

  POP     {R4- R5, PC}                   @ add any registers R4...R12 that you use



@ fp_frac subroutine
@ Obtain the fraction of an IEEE-754 (single precision) number.
@
@ The returned fraction will include the 'hidden' bit to the left
@   of the radix point (at bit 23). The radix point should be considered to be
@   between bits 22 and 23.
@
@ The returned fraction will be in 2's complement form, reflecting the sign
@   (sign bit) of the original IEEE-754 number.
@
@ Parameters:
@   R0: IEEE-754 number
@
@ Return:
@   R0: fraction (signed fraction, including the 'hidden' bit, in 2's
@         complement form)
fp_frac:
  PUSH    {R4-R9, LR}                    @ add any registers R4...R12 that you use
  MOV R4, R0                             @ num = IEEE-754 number
  MOV R5, #0                             @ neg = false
  MOV R6, R0                             @ numCpy = IEEE-754 number
  .LIf:                                  @  if(){
    MOVS R4, R4, LSL #1                  @    shift num to left by 1
    BCC .LEndIf                          @    branch if carry clear
    MOV R5, #1                           @    neg = true
  .LEndIf:                               @ }
  LDR R7, =0x7FFFFF                      @ mask to clear bits
  AND R6, R6, R7                         @ isolating fraction by clearing bits 23-31
  LDR R8, =0x800000                      @ mask to set bit 
  ORR R6, R6, R8                         @ setting hidden bit by settng bit 23
  .LIfNeg:                               @  if(neg){
    CMP R5, #1                              
    BNE .LEndIfNeg
    NEG R6, R6                           @    negating fraction if signed bit was 1  
  .LEndIfNeg:                            @ }
  MOV R0, R6

  POP     {R4-R9, PC}                    @ add any registers R4...R12 that you use



@ fp_enc subroutine
@ Encode an IEEE-754 (single precision) floating point number given the
@   fraction (in 2's complement form) and the exponent (also in 2's
@   complement form).
@
@ Fractions that are not normalised will be normalised by the subroutine,
@   with a corresponding adjustment made to the exponent.
@
@ Parameters:
@   R0: fraction (in 2's complement form)
@   R1: exponent (in 2's complement form)
@
@ Return:
@   R0: IEEE-754 single precision floating point number
fp_enc:
  PUSH    {R4-R12, LR}              @ add any registers R4...R12 that you use

  MOV R4, R0                        @ frac = fraction
  MOV R5, R1                        @ exp = exponent
  MOV R6, #8
  MOV R7, #0                        @ sign = 0
  MOV R8, R0                        @ fracCpy = fraction
  .LIfNegative:                     @ if(){
    MOVS R4, R4, LSL #1
    BCC .LEndIfNegative
    LDR R7, =0x80000000             @ if fraction is negative setting signed bit to one and negating fraction
    NEG R8, R8                 
  .LEndIfNegative:
   
  @ reference: ARM v8-M Architecture Reference Manual (ARM ARM) C2.4.37
  .LIfZeros:                        @ if(zeros!=8 || < 8 || >8)
    CLZ R9, R8                      @ count of leading zeros
    CMP R9, R6                       
    BEQ .LIfNorm
    CMP R9, R6
    BGT .LIfGreater
    RSB R9, R9, R6                  @   zeros = 8 - zeros
    MOV R8, R8, LSR R9              @   fracCpy = fracCpyy >>> zeros
    ADD R5, R9                      @   exp += zeros
    B .LIfNorm
  .LEndIfZeros:                     @ }
  .LIfGreater:                      @ else{
    SUB R9, R9, R6                  @   zeros -= 8     
    MOV R8, R8, LSL R9              @   fracCpy = fracCpy <<< zeros
    SUB R5, R9                      @   exp -= zeros
  .LEndIfGreater:                   @ }
  .LIfNorm: 	                      @ if(normalised){
    LDR R10, =0x00800000            @   mask to hide hidden bit
    BIC R8, R8, R10                 @ clear hidden bit
    ADD R5, #127                    @ exp += 127(bias)
    MOV R5, R5, LSL #23             @ exp <<< 23
    ADD R11, R8, R5                 @ fpn = frac + exp
    ADD R12, R11, R7                @ floatingPointNum = fpn + sign
    MOV R0, R12

  POP     {R4-R12, PC}              @ add any registers R4...R12 that you use


.end