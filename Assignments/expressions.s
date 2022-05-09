  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  .global  Main

Main:

  @
  LDRB R2,[R1], #1              @ ch = Byte[adr++]
  MOV R3, #0                    @ value = 0
  MOV R4, #10                   @ digitPos = 10
  MOV R9, #0                    @ isLastSign = FALSE
  While1:                       @ while(ch!= NULL){
    CMP R2, #0
    BEQ EndWhile1
    While:                      @ while(ch >= '0' && ch <= '9'){
      CMP R2, #'0'
      BLT EndWhile
      CMP R2, #'9'
      BGT EndWhile
      MUL R3, R3, R4            @   value = value * digitPos
      SUB R5, R2, #'0'          @   ch - '0'
      ADD R3, R3, R5            @   value = value + (ch - '0')
      LDRB R2, [R1], #1         @   ch = Byte[adr++]
      B While
    EndWhile:                   @ }
    IfNull:                     @ if(ch!= NULL){
      CMP R2, #0
      BEQ EndIfNull
      If:                       @   if(ch == ' '){
        CMP R2, #' '
        BNE Else
        IfSign:                 @     if(!isLastSign){
          CMP R9, #0
          BNE EndIfSign
          PUSH {R3}             @       push(value)
          MOV R3, #0            @       value = 0
        EndIfSign:              @     }
        MOV R9, #0              @     isLastSign = FALSE
        B EndElse
      Else:                     @    else{
        POP {R6, R7}            @     pop(value1, value2)
        IfAdd:                  @     if(ch == '+'){
          CMP R2, #'+'
          BNE EndIfAdd
          ADD R8, R7, R6        @       result = value1 + value2
          MOV R9, #1            @       isLastSign = TRUE
          PUSH {R8}             @       push(result)
        EndIfAdd:               @     }
        IfSub:                  @     if(ch == '-'){
          CMP R2, #'-'
          BNE EndIfSub
          SUB R8, R7, R6        @       result = value1 - value2
          MOV R9, #1            @       isLastSign = TRUE
          PUSH {R8}             @       push(result)
        EndIfSub:               @     }
        IfMul:                  @     if(ch == '*'){
          CMP R2, #'*'
          BNE EndIfMul
          MUL R8, R6, R7        @       result = value1 * value2
          MOV R9, #1            @       isLastSign = FALSE
          PUSH {R8}             @       push(result)
        EndIfMul:               @     }
      EndElse:                  @   }
      LDRB R2, [R1], #1         @ ch = Byte[adr++]
    EndIfNull:
    B While1
  EndWhile1:                    @ }
  IfValue:                      @ if(value!=0){
    CMP R3, #0
    BEQ ElseValue
    MOV R0, R3	                @   result = value
    B EndElseValue            
  EndIfValue:                   @ }
  ElseValue:                    @ else{
    POP {R0}                    @   pop(result)
  EndElseValue:                 @ }

  @

  @
  @ You can use either
  @
  @   The System stack (R13/SP) with PUSH and POP operations
  @
  @   or
  @
  @   A user stack (R12 has been initialised for this purpose)
  @


  @ End of program ... check your result

End_Main:
  BX    lr

