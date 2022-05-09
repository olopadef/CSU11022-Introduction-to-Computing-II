  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  .global  Main

Main:

  @
 LDR R5, [R0, R1, LSL #2]         @ valueAtOldIndex = array[oldIndex]
 If:
  CMP R1, R2                      @ if (oldIndex > arraynewIndex) {
  BLT Else
  SUB R3, R1, #1                  @ valueBeforeOldIndex = oldIndex - 1
  WhileGreaterThan:               @ while(oldIndex >  newIndex)          {
    CMP R1, R2
    BLE EndWhileGreaterThan
    LDR R4, [R0, R3, LSL #2]      @ valueBeforeOldIndex = array[oldIndex - 1]
    STR R4, [R0, R1, LSL #2 ]     @ oldIndex = valueBeforeOldIndex 
    SUB R3, R3, #1                @ valueBeforeOldIndex--
    SUB R1, R1, #1                @ oldIndex --
    B WhileGreaterThan  
  EndWhileGreaterThan:            @  }
  STR R5, [R0, R2, LSL #2]        @ valueAtOldIndex = array[newIndex]
 EndIf:                           @     }

 Else:                            @ else {
  ADD R3, R1, #1                  @ valueAfterOldIndex = oldIndex + 1
  WhileLessThan:                  @ while(oldIndex < newIndex)  {
    CMP R1, R2
    BGE EndWhileLessThan
    LDR R4, [R0, R3, LSL #2]      @ valueAfterOldIndex = array[oldIndex + 1]
    STR R4, [R0, R1, LSL #2]      @ oldIndex = valueAfterOldIndex
    ADD R3, R3, #1                @ valueAfterIndex ++
    ADD R1, R1, #1                @ oldIndex++ 
    B WhileLessThan
  EndWhileLessThan:               @ }    
  STR R5, [R0, R2, LSL #2]        @ valueAtOldIndex = array[newIndex]      
 EndElse:                         @      }
  @ End of program ... check your result

End_Main:
  BX    lr

