LISTO EQU 27H.0	
RD_ADC EQU P3.5
WR_ADC EQU P3.4
CS EQU P3.3
SENSOR EQU 35H 
CONT EQU 36H
BOCINA EQU P0.0
BOMBA EQU P3.6
LAMP EQU P3.7
PRES EQU P0.2
org 0H
  sjmp  inicio ;salto al inicio del programa principal.  ; ///////////////////////////////////////////////////////////////////////////////// 
; Subrutina de atención a la interrupción EXTERNA 0 del microcontrolador 
; empleada para atender el Fin de Conversión.

; Leyendo el Conversor ADC0801. 
org 03H 
JMP EXT0

;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ORG 0BH		;VECTOR DE INTERRUPCION DEL TIMER0
JMP TMP0

ORG 50H
; Inicio del programa principal. 
inicio: 
 CLR BOMBA
 CLR BOCINA
 CLR LAMP
 CLR PRES
 clr  LISTO ;limpiando bandera de dato leído 
  MOV SENSOR,#0
  MOV CONT,#5
 
  mov  R7,#0 ;limpiando el registro de dato leído 
  MOV TCON,#11H		;EXTERNA0 POR FRENTE DESCENDENTE Y HABILITACION DEL TIMER0
; Dando una falsa lectura al conversor. 
; Esto hay que hacerlo solo una vez y con ello garantizamos que el conversor 
; este listo para el trabajo. Es como un RESET al conversor. 
  clr  CS ; se pone SELECT a 0 y no se cambia mas  
  clr  RD_ADC  ; LECT a 0, lectura del conversor. 
  nop 
  nop 
  setb RD_ADC 
; Esperando por dato leído, respuesta de la Subrutina de atención a Fin de 
; Conversión. 

		MOV R1,#0		;REGISTRO QUE SE VA A LLEVAR A 2 EN EL TIMER PARA EJECUTAR LOS 50ms 2 VECES=100ms
		MOV TMOD,#01H		;TIMER0 EN MODO 1 DE 16 BITS
		MOV TL0,#0D8H
		MOV TH0,#0F0H	
		MOV IP,#01H
		MOV IE,#82H		;HABILITA LA INTERRUPCION GLOBAL Y TIMER 0

REVISALO:
; Habilitar la interrupcion EXTERNA 0. 
  clr  IE0  ;limpiando la bandera de interrupción EXTERNA 0 
  SETB IE.0  ;habilitando la interrupción EXTERNA 0 
  SETB IE.7
jnb LISTO,$ 
clr  LISTO ;limpiando la bandera de dato leído 
; TRABAJANDO CON EL DATO LEIDO. El dato a mostrar esta en el Registro R7.

  MOV A,P3
  ORL A,SENSOR
  MOV P3,A	;PREPARO PARA LEER OTRO SENSOR

MOV A,#0
MOV B,SENSOR
XRL A,B
JNZ SENSOR_HUMO


MOV A,#1
MOV B,SENSOR
XRL A,B
JNZ SENSOR_LUZ

MOV A,#2
MOV B,SENSOR
XRL A,B
JNZ SENSOR_PRESENCIA

SENSOR_NIVEL:
MOV A,R7
CJNE A,#0FH,NO_EQ
NO_EQ:
JC APAGA
;ENCIENDE
SETB BOMBA
JMP EXIT
APAGA:
CLR BOMBA
JMP EXIT


SENSOR_HUMO:
MOV A,R7
CJNE A,#0FH,NO_EQ1
NO_EQ1:
JC APAGA1
;ENCIENDE
SETB BOCINA
JMP EXIT
APAGA1:
CLR BOCINA
JMP EXIT

SENSOR_LUZ:
MOV A,R7
CJNE A,#0FH,NO_EQ2
NO_EQ2:
JC APAGA2
;ENCIENDE
SETB LAMP
JMP EXIT
APAGA2:
CLR LAMP
JMP EXIT

SENSOR_PRESENCIA:
MOV A,R7
CJNE A,#0FH,NO_EQ3
NO_EQ3:
JC APAGA3
;ENCIENDE
SETB PRES
JMP EXIT
APAGA3:
CLR PRES

EXIT: 
INC SENSOR
JMP REVISALO

EXT0:

  ;CLR IE.0 ;deshabilitando la interrupción EXTERNA 0 
  MOV A,CONT
  DJNZ ACC,SIGUE
;CLR P2.0 
  MOV CONT,#5
  MOV SENSOR,#0
  SIGUE:
  DEC CONT
  clr RD_ADC  ;dando lectura al ADC0801, CS/ esta a 0.  
  nop   ;esperando por la respuesta del conversor ADC0801 
  nop 
  setb RD_ADC
  mov  A,P1  ;leyendo el ADC0801  
  mov  R7,A  ;salvando el dato leído   
  setb  LISTO  ;indicando que hay un dato leído listo para ser mostrado 
  setb RD_ADC ;quitando orden del lectura del ADC0801 
reti 

TMP0:
		CPL P2.0
		INC R1
		CJNE R1,#10,OUT

		clr  WR_ADC ; ICON a 0, inicio de conversión.
 	        nop 
 		nop 
		setb WR_ADC
		MOV R1,#0


OUT:		MOV TL0,#0D8H
		MOV TH0,#0F0H
		RETI

;-----------------------------------------------------------------------
	END