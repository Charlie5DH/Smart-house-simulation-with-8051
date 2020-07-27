
	DIG_1 EQU 30H 
	DIG_2 EQU 31H 
	DIG_3 EQU 32H
	DIG_4 EQU 33H
	E     EQU P1.1
	RS    EQU P1.0
	MAL   EQU 21H.7
;-----------------------------------------------------------------
	ORG 00H
	JMP STARTUP

	TABLA: DB '/','X','-','+',9,6,3,'=',8,5,2,0,7,4,1,'ON'

	; Secuencia de comandos para inicializar el trabajo del LCD. 
	tablac:  db  28h,06h,0Eh,80h,0fh ;CONEXION DE 4 BITS CON 2 LINEAS,MOVIMIENTO DEL CURSOSR DE IZQ A DER,ENCENDER PANTALLA Y ACTIVAR CURSOR,POSICION INICIAL 					 ;DEL CURSOR
;******************************************************************************
; cartel 1. 
tablad1:  db  '0123456789' ;ES EL NUM Y UN 2 DELANTE EJ 7-27
db  0   ; fin de cartel 
;****************************************************************************** 

;******************************************************************************
; cartel 1. 
tablad2:  db  'ALARMA ACTIVA' 
db  0   ; fin de cartel 
;****************************************************************************** 
; cartel 2. 
tablad3:  db  'ALARMA DESACTIVA' 
db  0   ; fin de cartel 
;******************************************************************************
	ORG 50H
STARTUP:
;---------------------------INICIALIZACION---------------------
	SETB E			;DESHABILITA EL LCD
	SETB RS			;DESHABILITA EL LCD
	CLR MAL
	MOV R0,#30H
	MOV 37H,#4
	MOV DIG_4,#04H
	MOV DIG_3,#03H
	MOV DIG_2,#02H
	MOV DIG_1,#01H

;--------------------------------------------------------------

	CLR 20H.0		;BANDERA QUE INDICA SI SE PRESIONA UNA TECLA

; Inicializando el trabajo del LCD. 
	call  lcd_ini	
	clr  RS  ; pone a RS en ´0´ (modo comando) 
	mov  P1, #00000000b 	; (PARTE ALTA) borra LCD y Home.
	call  lcd_e   ; habilita al Display 
	call  delay_164  ; demora de 1.64 ms. 

	clr  RS  ; pone a RS en ´0´ (modo comando) 
	mov  P1, #00000100b	 ;(PARTE BAJA) borra LCD y Home.
	call  lcd_e   ; habilita al Display 
	call  delay_164  ; demora de 1.64 ms.
;----------------------------------------------------------------------------------
BUS:	CALL TECLADO
	JB 20H.0,LAZO		;TECLA APRETADA?
	JMP BUS
LAZO:
CALL DISPLAY
JMP BUS

;------------SUBRUTINA TECLADO----------------------------------
TECLADO:
	MOV R6,#11101111B
	MOV R5,#4
	MOV R3,#0
REPITE:
	MOV P2,R6
	MOV A,P2
	MOV R4,#4
LAZO1:
	RRC A
	JNC ENCONT
	INC R3
	DJNZ R4,LAZO1
	MOV A,R6
	RL A
	MOV R6,A
	DJNZ R5,REPITE
	CLR 20H.0
	MOV A,0
	JMP SALIR
ENCONT:
	SETB 20H.0
	MOV A,R3
SALIR:
	RET

;-----------------SUBRUTINA DISPLAY--------------------------------------
DISPLAY:

	MOV DPTR,#TABLA	
	MOVC A,@A+DPTR
	MOV B,@R0
	INC R0
	

	CJNE A,B,ERROR
	JMP MANDALO
	ERROR:
	SETB MAL

	MANDALO:
;-------------------------------asignacion de num----------------------------
mov dptr,#tablad1
movc a,@a+dptr
;-----------------------------------------------------------------------------
	PUSH ACC
	ANL A,#0F0H
	MOV B,#4
	DIV AB		;ROTO DER
	CLR RS
	mov  P1,A   ; valor ASCII a sacar por Puerto1 (PARTE ALTA)
	SETB  RS  ; pone RS en ´1´ (modo dato).
	call  lcd_e   ; habilita al Display 
	call  delay_40 ;demora de 0.4 ms.

	POP ACC
	ANL A,#0FH
	MOV B,#4
	MUL AB		;ROTO IZQ
	mov  P1,A   ; valor ASCII a sacar por Puerto1 (PARTE BAJA)
	SETB  RS  ; pone RS en ´1´ (modo dato).
	call  lcd_e   ; habilita al Display 
	call  delay_c  ;demora de 0.4 ms.

	DJNZ 37H,NOO
	MUESTRA:
	JNB MAL,BIEN
mov  R0, #0 
mov  R4, #0 

	clr  RS  ; pone a RS en ´0´ (modo comando) 
	mov  P1, #00000000b 	; (PARTE ALTA) borra LCD y Home.
	call  lcd_e   ; habilita al Display 
	call  delay_164  ; demora de 1.64 ms. 

	clr  RS  ; pone a RS en ´0´ (modo comando) 
	mov  P1, #00000100b	 ;(PARTE BAJA) borra LCD y Home.
	call  lcd_e   ; habilita al Display 
	call  delay_164  ; demora de 1.64 ms. 

mov  dptr, #tablad2 ; puntero de la Tabla 2. 
otrodd:   mov  a, R4   ; carga desplazamiento en Tabla 
movc  a, @a+dptr  ; extrae carácter a mostrar de la Tabla 
jz  NO ; ¿ Fin del cartel? 
	PUSH ACC
	ANL A,#0F0H
	MOV B,#4
	DIV AB		;ROTO DER
	CLR RS
	mov  P1,A   ; valor ASCII a sacar por Puerto1 (PARTE ALTA)
	SETB  RS  ; pone RS en ´1´ (modo dato).
	call  lcd_e   ; habilita al Display 
	call  delay_40 ;demora de 0.4 ms.

	POP ACC
	ANL A,#0FH
	MOV B,#4
	MUL AB		;ROTO IZQ
	mov  P1,A   ; valor ASCII a sacar por Puerto1 (PARTE BAJA)
	SETB  RS  ; pone RS en ´1´ (modo dato).
	call  lcd_e   ; habilita al Display 
	call  delay_c  ;demora de 0.4 ms.
inc  R0 
inc  R4 
jmp  otrodd 

NOO:
	JMP NO
	BIEN:
mov  R0, #0 
mov  R4, #0 

	clr  RS  ; pone a RS en ´0´ (modo comando) 
	mov  P1, #00000000b 	; (PARTE ALTA) borra LCD y Home.
	call  lcd_e   ; habilita al Display 
	call  delay_164  ; demora de 1.64 ms. 

	clr  RS  ; pone a RS en ´0´ (modo comando) 
	mov  P1, #00000100b	 ;(PARTE BAJA) borra LCD y Home.
	call  lcd_e   ; habilita al Display 
	call  delay_164  ; demora de 1.64 ms. 

mov  dptr, #tablad3 ; puntero de la Tabla 2. 
otrod:   mov  a, R4   ; carga desplazamiento en Tabla 
movc  a, @a+dptr  ; extrae carácter a mostrar de la Tabla 
jz  NO  ; ¿ Fin del cartel? 
	PUSH ACC
	ANL A,#0F0H
	MOV B,#4
	DIV AB		;ROTO DER
	CLR RS
	mov  P1,A   ; valor ASCII a sacar por Puerto1 (PARTE ALTA)
	SETB  RS  ; pone RS en ´1´ (modo dato).
	call  lcd_e   ; habilita al Display 
	call  delay_40 ;demora de 0.4 ms.

	POP ACC
	ANL A,#0FH
	MOV B,#4
	MUL AB		;ROTO IZQ
	mov  P1,A   ; valor ASCII a sacar por Puerto1 (PARTE BAJA)
	SETB  RS  ; pone RS en ´1´ (modo dato).
	call  lcd_e   ; habilita al Display 
	call  delay_c  ;demora de 0.4 ms.
inc  R0 
inc  R4 
jmp  otrod 
	NO:		
	RET
	
	
	
;-----------------------------------------------------------------------
	
; Subrutina para la inicialización del LCD. 
; Bus de Datos de 4 bits. 
; Movimiento del cursor hacia la derecha. 
; Limpiando la pantalla antes de empezar. 
; Colocar cursor en la posición primera de la primera línea. 

lcd_ini:  mov  R1, #0  ; desplazamiento en la tabla de Comandos 
mov  DPTR, #tablac ; puntero a Tabla de Comandos. 
otroc:   mov  a, R1 
movc  a, @a+DPTR  ; saca de la tabal el Comando a enviar. 
clr  RS

PUSH ACC	
ANL A,#0F0H
MOV B,#4	;ROTO HASTA POSICION DESEADA
DIV AB		;ROTO DER
mov  P1, A ;(PARTE ALTA)
call  lcd_e 
call  delay_40

clr  RS
MOV B,#4
POP ACC
ANL A,#0FH
MUL AB		;ROTO IZQ
mov  P1, A 	;(PARTE BAJA)
call  lcd_e 
call  delay_40 
inc  R1

cjne  R1,#4, otroc  ; ¿ Fin de programación del LCD? 
clr  RS  ; pone a RS en ´0´ (modo comando) 
mov  P1, #00000000b ; borra LCD y Home. ;(PARTE ALTA)
call  lcd_e 
call  delay_164 

clr  RS  ; pone a RS en ´0´ (modo comando) 
mov  P1, #00000100b ; borra LCD y Home. ;(PARTE BAJA)
call  lcd_e 
call  delay_164 
ret 
;******************************************************************************

; Subrutina que genera el pulso de habilitación del LCD.
 
lcd_e:   setb E  ; pone a E en ´1´ 
NOP
clr  E   ; pone a E en ´0´ 
ret 
;******************************************************************************
; Subrutinas de demora de 40us y 1,64ms 

delay_40:  mov  R2, #40 
djnz  R5,$
ret 
delay_164:  mov  R3,#41 
lazo2:   call  delay_40 
djnz  R3,lazo2 
ret 
;******************************************************************************
delay_c:  mov  R1,#10
lazo3:   call  delay_164 
djnz  R1,lazo3 
ret 




;***************************FIN DEL PROGRAMA***********************

END