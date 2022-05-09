  .syntax unified
  .cpu cortex-m4
  .thumb
  .global  power

@
@ power subroutine
@ Computes x^n
@
@ Parameters:
@   R0:  x
@   R1:  n
@
@ Return:
@   R0:  x^n
@
power:
  PUSH  {R4-R6,LR}      @ save registers
  MOV   R4, R0          @ Move parameters to local registers
  MOV   R5, R1          @  Doing this makes managing registers in subroutines
                        @  *much* simpler. When we call a subroutine from the
                        @  body of this subroutine, the parameter registers
                        @  (R0-R3) will already be free for us to use because
                        @  we have moved the original patameters to other
                        @  registers.

  CMP   R5, #0          @ if (n == 0) {
  BNE   .LpowerNe0
  
  MOV   R0, #1          @   result = 1;
  
  B     .LpowerEndIf    @ }
.LpowerNe0:
  CMP   R5, #1          @ else if (n == 1) {
  BNE   .LpowerNe1
  
  MOV   R0, R4          @   result = x;
  
  B     .LpowerEndIf    @ }
.LpowerNe1:
  AND   R6, R5, #1      @ else if (n & 1 == 0) { // n is even
  CMP   R6, #0
  BNE   .LpowerNeEven

  MUL   R0, R4, R4      @   result = power (x * x, n >> 1);
  MOV   R1, R5, LSR #1  @   // using LSR by 1 bit to implement division by 2
  BL    power
  
  B     .LpowerEndIf    @ }
.LpowerNeEven:

                        @ else {
  MUL   R0, R4, R4      @   result = x * power (x * x, n >> 1);
  MOV   R1, R5, LSR #1
  BL    power
  MUL   R0, R4, R0

.LpowerEndIf:           @ }

  POP   {R4-R6, PC}     @ return result;

  .end