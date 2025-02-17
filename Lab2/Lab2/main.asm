;Universidad del Valle de Guatemala
;IE2023: Programación de Microcontroladores
; Lab2.asm
;
; Created: 10/02/2025 11:21:47
; Author : Nicolas Zamora
;

.include "M328PDEF.inc" // Include definitions specific to ATMega328P
.cseg
.org 0x0000
.def COUNTER = R20
 
// Encabezado y Pila
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, HIGH(RAMEND)
OUT SPH, R16

MITABLA: .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x58, 0x5E, 0x79, 0x71  

SETUP:
	CALL INIT_TMR0
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16 // Habilitar cambio de clk
	LDI R16, 0b00000111 // factor de division 128
	STS CLKPR, R16 // Frecuencia de 1MHz
	LDI COUNTER, 0x00 // Salidas leds
	LDI R17, 0b0000_1111
	OUT DDRC, R17
	LDI R17, 0b0010_0000 // Salida led 
	OUT DDRB, R17
	LDI R23, 0b0111_1111 // Salidas display
	OUT DDRD, R23
	LDI R19, 0b0000_0000 // Entradas Pines C
	OUT PORTC, R19
	LDI COUNTER, 0x00
	LDI R21, 0X00 // CONTADOR
	LDI ZL, LOW(MITABLA << 1)
	LDI ZH, HIGH(MITABLA << 1)
	LPM R23, Z

LOOP:
	OUT PORTD, R23
	IN R17, PINC
	SBIC PINC, PC4
	CALL DELAY1
	IN R18, PINC
	SBIC PINC, PC5
	CALL DELAY2
	IN R16, TIFR0
	SBRS R16, OCF0A // Salta si el bit 0 est "set" (TOV0 bit)?
	RJMP LOOP // Reiniciar loop
	SBI TIFR0, OCF0A // Limpiar bandera de "overflow"
	OUT PORTC, COUNTER
	INC COUNTER
	CPI COUNTER, 16
	BREQ VOLVER
	CALL ALARMA
	RJMP LOOP

ALARMA:
	MOV R24, R21
	INC R24
	CP COUNTER, R24
	BREQ IGUAL

	RJMP LOOP
VOLVER:
	LDI COUNTER, 0
	RJMP LOOP
IGUAL:
	CPI R25, 1
	BREQ VUELTA0
	LDI R25, 1
	SBI PORTB, PB5
	LDI COUNTER, 0
	RJMP LOOP
VUELTA0:
	LDI R25, 0
	CBI PORTB, PB5
	LDI COUNTER, 0
	RJMP LOOP
	
DELAY1:
	LDI R17, 0x64
	D1:
		DEC R17
		BRNE D1
	SBIC PINC, PC4
	RJMP DELAY1
	CALL INCREMENTO

DELAY2:
	LDI R18, 0x64
	D2:
		DEC R18
		BRNE D2
	SBIC PINC, PC5
	RJMP DELAY2
	CALL DECREMENTO


INCREMENTO:
	/*SBIS PINC, PC4
	RET*/
	CPI R21, 0x0F // COMPARA SI ES IGUAL
	BREQ PASAR
	INC R21
	ADIW Z, 1
	LPM	R23, Z
	OUT PORTD, R23
	RJMP LOOP



DECREMENTO:
	/*SBIS PINC, PC5
	RET*/
	CPI R21, 0x00 // COMPARA SI ES IGUAL
	BREQ PASAR
	DEC R21
	SBIW Z, 1
	LPM	R23, Z
	OUT PORTD, R23
	RJMP LOOP
		
PASAR:
	RJMP LOOP

INIT_TMR0:
	LDI R16, 0
	OUT TCNT0, R16
	LDI R16, 156
	OUT OCR0A, R16
	LDI R16, (1 << WGM01)  // Modo de Operación en CTC
	OUT TCCR0A, R16
	LDI R16, (1<<CS02) | (1<<CS00)
	OUT TCCR0B, R16 // Setear prescaler del TIMER 0 a 1024
	RET
