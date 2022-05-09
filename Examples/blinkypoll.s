  .syntax unified
  .cpu cortex-m4
  .thumb
  .global Main

  @ Definitions are in definitions.s to keep this file "clean"
  .include "definitions.s"

  .equ    BLINK_PERIOD, 1000


@
@ To debug this program, you need to change your "Run and Debug"
@   configuration from "Emulate current ARM .s file" to "Graphic Emulate
@   current ARM .s file".
@
@ You can do this is either of the followig two ways:
@
@   1. Switch to the Run and Debug panel ("ladybug/play" icon on the left).
@      Change the dropdown at the top of the Run and Debug panel to "Graphic
@      Emulate current ARM .s file".
@
@   2. ctrl-shift-P (cmd-shift-P on a Mac) and type "Select and Start Debugging".
@      When prompted, select "Graphic Emulate ...".
@



Main:
  PUSH    {R4-R5,LR}

  @ Enable GPIO port D by enabling its clock
  LDR     R4, =RCC_AHB1ENR
  LDR     R5, [R4]
  ORR     R5, R5, RCC_AHB1ENR_GPIODEN
  STR     R5, [R4]

  @ We'll blink LED LD3 (the orange LED)

  @ Configure LD3 for output
  @ by setting bits 27:26 of GPIOD_MODER to 01 (GPIO Port D Mode Register)
  @ (by BIClearing then ORRing)
  LDR     R4, =GPIOD_MODER
  LDR     R5, [R4]                  @ Read ...
  BIC     R5, #(0b11<<(LD3_PIN*2))  @ Modify ...
  ORR     R5, #(0b01<<(LD3_PIN*2))  @ write 01 to bits 
  STR     R5, [R4]                  @ Write 

  @ Loop forever
.LwhBlink:
  @ Invert LD3
  @ by inverting bit 13 of GPIOD_ODR (GPIO Port D Output Data Register)
  @ (by using EOR to invert bit 13, leaving other bits unchanged)
  LDR     R4, =GPIOD_ODR
  LDR     R5, [R4]                  @ Read ...
  EOR     R5, #(0b1<<(LD3_PIN))     @ Modify ...
  STR     R5, [R4]                  @ Write

  @ wait for 1s ...
  LDR     R0, =BLINK_PERIOD
  BL      delay_ms

  @ ... and repeat
  B       .LwhBlink
  
End_Main:
  POP   {R4-R5,PC}



@ delay_ms subroutine
@ Use the Cortex SysTick timer to wait for a specified number of milliseconds
@
@ See Yiu, Joseph, "The Definitive Guide to the ARM Cortex-M3 and Cortex-M4
@   Processors", 3rd edition, Chapter 9.
@
@ Parameters:
@   R0: delay - time to wait in ms
@
@ Return:
@   None
delay_ms:
  PUSH  {R4-R5,LR}

  LDR   R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR   R5, =0                      @   by writing 0 to CSR
  STR   R5, [R4]                    @   CSR is the Control and Status Register
  
  LDR   R4, =SYSTICK_LOAD           @ Set SysTick LOAD for 1ms delay
  LDR   R5, =15999                  @ Assuming a 16MHz clock,
  STR   R5, [R4]                    @   16x10^6 / 10^3 - 1 = 15999
  
  LDR   R4, =SYSTICK_VAL            @ Reset SysTick internal counter to 0
  LDR   R5, =0x1                    @   by writing any value
  STR   R5, [R4]  

  LDR   R4, =SYSTICK_CSR            @ Start SysTick timer by setting CSR to 0x5
  LDR   R5, =0x5                    @   set CLKSOURCE (bit 2) to system clock (1)
  STR   R5, [R4]                    @   set ENABLE (bit 0) to 1

.LwhDelay:                          @ while (delay != 0) {
  CMP   R0, #0  
  BEQ   .LendwhDelay  
  
.Lwait:
  LDR   R5, [R4]                    @   Repeatedly load the CSR and check bit 16
  AND   R5, #0x10000                @   Loop until bit 16 is 1, indicating that
  CMP   R5, #0                      @     the SysTick internal counter has counted
  BEQ   .Lwait                      @     from 0x3E7F down to 0 and 1ms has elapsed 

  SUB   R0, R0, #1                  @   delay = delay - 1
  B     .LwhDelay                   @ }

.LendwhDelay:

  LDR   R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR   R5, =0                      @   by writing 0 to CSR
  STR   R5, [R4]                    @   CSR is the Control and Status Register
  

  POP   {R4-R5,PC}


  .end