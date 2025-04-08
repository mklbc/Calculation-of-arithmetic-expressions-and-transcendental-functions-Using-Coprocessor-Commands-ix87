.386 			                      ; all instructions of the proper processor are settled
.model flat, stdcall 	                ; the model of memory is set
option casemap :none 	                ; the register of characters is recognized
includelib \masm32\lib\kernel32.lib     ; connect external library kernel32.lib       
includelib \masm32\lib\user32.lib       ; connect external library user32.lib 
includelib \masm32\lib\masm32.lib       ; connect external library masm32.lib 
includelib \masm32\lib\fpu.lib          ; connect external library fpu.lib
include \masm32\include\windows.inc     ; for a management by the modes of Window
include \masm32\include\user32.inc      ; for using MessageBox
include \masm32\include\kernel32.inc    ; for using ExitProcess
include \masm32\include\masm32.inc      ; for using FloatToStr
include \masm32\include\fpu.inc         ; for using FPU instructions


.data
msg_title db "Variant number 12 [sqrt(25/c) - d + 2]/(b + a - 1)", 0                 ; text variable for title of window

msg_message db "Iutputing variables values:", 10, "A=%s ", "B=%s ","C=%s ","D=%s ",10, 10, 0 
msg_messageres db "Res = %s", 0
msg_message1 db "Exception situation - Denominator equal to 0",0 
msg_message2 db "Exception situation - sqrt value is negative as C is negative",0 


A dq  0.5,  -1.3,  32.5,  0.6,  -0.9,  0.5
B dq  5.5,  -2.7,  0.5, 0.3, 1.6,  0.5
C0 dq 5.0,  1.5, 26.5,  23.5,  -3.4,  3.2
D dq  0.75, 0.25,  10.5, 41.5,  2.1,  1.3


tfive dq 25.0
two dq 2.0

.data?

RES dq ?
digbuf db 512 dup(?)
inbuf db 64 dup(?)
finbuf db 64 dup(?)
buffA db 32 dup(?)
buffB db 32 dup(?)
buffC db 32 dup(?)
buffD db 32 dup(?)
buffRES db 32 dup(?)
.code

main:

finit

mov esi, 0
.WHILE esi <= 5

invoke FloatToStr, A[esi*8], addr buffA
invoke FloatToStr, B[esi*8], addr buffB
invoke FloatToStr, C0[esi*8], addr buffC
invoke FloatToStr, D[esi*8], addr buffD

invoke wsprintf, addr digbuf, addr msg_message, addr buffA, addr buffB, addr buffC, addr buffD
invoke szCatStr, addr digbuf, addr inbuf


; Load values into FPU registers

FLD C0[esi*8]
FTST                                    ; Compares the value in the ST(0) register with 0.0 
FSTSW AX                                ; Stores the current value of the x87 FPU status word in AX registry
SAHF                                    ; Loads the SF, ZF, AF, PF, and CF flags of the EFLAGS register
FSTP RES
jb Error_2

; numerator

fld C0[ESI*8]
fld tfive
fdiv st(0),st(1)                         ; ST(0) = ST(0)/ST(1)
fsqrt                                    ; ST(0) = sqrt(ST(0))
fld D[ESI*8]                             ; ST(0) = D, ST(1) = sqrt(ST(0))
fsubp st(1),st(0)  
fadd two                       
    
; denaminator

fld B[ESI*8]                             ; ST(0) = B
fadd A[ESI*8]                            ; ST(0) = B+A
fld1                                     ; ST(0) = 1, ST(1) = b+a
fsubp st(1),st(0)                        ; ST(1) = b+a-1 and POP ST(0)

FTST			                       ; Compares the value in the ST(0) register with 0.0 
FSTSW AX		                       ; Stores the current value of the x87 FPU status word in AX registry
SAHF			                       ; Loads the SF, ZF, AF, PF, and CF flags of the EFLAGS register
jz Error_1


fdiv                                     ; ST(0) = sqrt(25/c)-d+2/b+1-1
fstp  RES                                ; STORE the result and pop ST(0)



invoke FloatToStr2, RES, addr buffRES
;Print texts on the screen
invoke wsprintf, addr finbuf, addr msg_messageres, addr buffRES
Jmp Final

Error_1:
invoke wsprintf, addr finbuf, addr msg_message1
Jmp Final


Error_2:
invoke wsprintf, addr finbuf, addr msg_message2

Final:
invoke szCatStr, addr digbuf, addr finbuf
invoke MessageBox, 0, addr digbuf, addr msg_title, 0
;add esi, 1
inc esi
.endw
invoke ExitProcess, 0	              	    ; exit of process
end main




