 .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  .global  Main

Main:           

  @           
SUB R4, R1, R3                        @ aLim = NA - NB
MOV R5, #0                            @ isSub = FALSE
MOV R6, #0                            @ rMain = 0
While:                                @ while(isSub == FAlSE && rMain <= aLim) {
  CMP R5, #0                  
  BNE EndWhile                  
  CMP R6, R4                  
  BGT EndWhile                  
  MOV R7, #0                          @   cMain = 0

  While2:                             @   while(isSub == FALSE && cMain <= aLim) {
    CMP R5, #0                  
    BNE EndWhile2                 
    CMP R7, R4                  
    BGT EndWhile2                 
    MOV R5, #1                        @     isSub = TRUE
    MOV R8, #0                        @     rSub = 0

    While3:                           @       while(isSub == TRUE && rSub < NB){
      CMP R5, #1                  
      BNE EndWhile3                 
      CMP R8, R3                  
      BGE EndWhile3                 
      MOV R9, #0                      @         cSub = 0

      While4:                         @           while(isSub == TRUE && cSub < NB ){
        CMP R5, #1      
        BNE EndWhile4     
        CMP R9, R3      
        BGE EndWhile4     
        MOV R10, R6                   @             offsetA = rMain            
        ADD R10, R10, R8              @             offsetA += rSub
        MUL R10, R10, R1              @             offsetA *= sizeA
        ADD R10, R10, R7              @             offsetA += cMain
        ADD R10, R10, R9              @             offsetA += cSub 
        MOV R11, R8                   @             offsetB = rSub
        MUL R11, R11, R3              @             offsetB *= sizeB
        ADD R11, R11, R9              @             offsetB += cSub
        LDR R4, [R0, R10, LSL #2]     @             elemA = arrayA[rMain + rSub][cMain + cSub]
        LDR R12, [R2, R11, LSL #2]    @             elemB = arrayB [rSub][cSub]
        If:                           @             if(elemA != elemB){
          CMP R4, R12
          BEQ EndIf
          MOV R5, #0                  @               isSub = FALSE
        EndIf:
        ADD R9, R9, #1                @             cSub ++
        SUB R4, R1, R3                @             aLim = NA - NB
        B While4
      EndWhile4:                      @            }
      ADD R8, R8, #1                  @           rSub ++
      B While3  
    EndWhile3:                        @         }
    ADD R7, R7, #1                    @         cMain ++  
    B While2
  EndWhile2:                          @       }
  ADD R6, R6, #1                      @        rMain++
  B While
EndWhile:                             @     }
MOV R0, R5                            @     result = isSub

  @




  @ End of program ... check your result

End_Main:
  BX    lr

