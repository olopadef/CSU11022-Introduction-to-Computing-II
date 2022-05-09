  .syntax unified
  .cpu cortex-m4
  .thumb
  .global  Main

@
@ bubblesort exercise
@ See the Exercises discussion board on Blackboard
@

Main:

@

Do:                              @ do { 
  MOV R3, #0                       @swapped = false;
  MOV R4, #1                       @ index = 1
  For:                           @for (index = 1; index < N; index++) {
    CMP R4, R2
    BGE While
    MOV R5, R4                   @ tmpi
    SUB R5, R5, #1               @ index - 1
    If:                          @if (array[i−1] > array[index]) {
      LDR R6, [R1, R5, LSL #2]   @ array[index - 1] 
      LDR R7, [R1, R4, LSL #2]   @ array[index]
      CMP R6, R7
      BLE EndIf
      MOV R8, R6                   @tmpswap = array[i−1];
      STR R7, [R1, R5, LSL #2]     @array[i−1] = array[index];
      STR R8, [R1, R4, LSL #2]      @array[index] = tmpswap;
      MOV R3, #1                    @swapped = true ;
    EndIf:                        @         }
    ADD R4, R4, #1
    B For
  EndFor:                       @     }

While:                            @} while ( swapped );
  CMP R3, #1
  BEQ Do

EndDoWhile:

@

End_Main:
  BX      LR

  .end