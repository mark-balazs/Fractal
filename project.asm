;Balazs Mark,511/1
;bmim1693

%include 'gfx.inc'
%include 'mio.inc'
%include 'io.inc'

%define HEIGHT 720
%define WIDTH 1024
global main

section .data

msg1 db 'SPACEBAR - Turn manipulating with mouse on/off.',0
msg2 db 'Q - Switch precision (single or double precision).',0
msg3 db 'Z, X - Zoom In/Out.',0
msg4 db 'C, V - Change coloring.',0
msg5 db 'B - Back to default settings.',0
msg6 db 'Created by Balazs Mark',0
msg7 db 'W, A, S, D - Move the screen.',0
msg8 db 'ESC - Exit.',0

WindowName db 'Julia',0
;the constant of the Julia function
ReC dd -0.462
ImC dd 0.559



;number of iterations (it scales with the zoom)
ITnumber dd 200



a dd 0
maxrange dd 4.0
centerx dd 0.0
centery dd 0.0
leptekx dd 0.0
lepteky dd 0.0
zoom dd 1.0

prevesp dd 0
prevcolor dd 0
prevedi dd 0
prevesi dd 0
prevebx dd 0



widthp2 dd 0
heightp2 dd 0
movemouse db 1
zoomconst dd 0.70


precision db 0


color db 1

recd dq 0.0
imcd dq 0.0
maxranged dq 4.0
centerxd dq 0.0
centeryd dq 0.0
ad dq 0.0
leptekxd dq 0.0
leptekyd dq 0.0
zoomd dq 1.0
zoomconstd dq 0.70


section .text

main:
	
	

	mov	eax, WIDTH
	mov	ebx, HEIGHT
	mov	ecx, 0
	mov edx,WindowName
	call gfx_init
	
	;calculating some constants to improve performance (not to be calculated within each loop)
		mov eax,WIDTH
		cdq
		mov ebx,2
		div ebx
		mov dword [widthp2],eax
		mov eax,HEIGHT
		cdq
		mov ebx,2
		div ebx
		mov dword [heightp2],eax
		
		mov dword[a],2
		cvtsi2ss xmm3,dword [a]
		movlhps xmm3,xmm3
		cvtsi2sd xmm4,dword [a]
		movlpd [ad],xmm4
		movhpd xmm4,[ad]
		movss xmm6,dword [maxrange]
		mulss xmm6,xmm6
		movsd xmm7,[maxranged]
		mulsd xmm7,xmm7
		
		mov eax,msg1
		call mio_writestr
		call mio_writeln
		mov eax,msg2
		call mio_writestr
		call mio_writeln
		mov eax,msg3
		call mio_writestr
		call mio_writeln
		mov eax,msg4
		call mio_writestr
		call mio_writeln
		mov eax,msg5
		call mio_writestr
		call mio_writeln
		mov eax,msg7
		call mio_writestr
		call mio_writeln
		mov eax,msg8
		call mio_writestr
		call mio_writeln
		mov eax,msg6
		call mio_writestr
		call mio_writeln
	
	
	
	call mainloop

ret

mainloop:
	
	
	;ecx - line of the pixels
	;edx - column of the pixels
	
	
	
	call gfx_map
	xor ecx,ecx
	
	loop1:
		
		cmp ecx,HEIGHT
		jge endofloop1
		
		xor edx,edx
		
		loop2:
			
			cmp byte[precision],0
			jne loop2D
			
			cmp edx,WIDTH
			jge endofloop2
			
			;calc leptekx
			movss xmm0,dword[maxrange]
			mov dword[a],WIDTH
			cvtsi2ss xmm1,dword[a]
			divss xmm0,xmm1
			movss xmm1,dword[zoom]
			mulss xmm0,xmm1
			movss dword[leptekx],xmm0
			movss dword[lepteky],xmm0
			
			
			
			
			
			;calc lepteky
			;fld dword[leptekconst]
			;fld dword[leptekx]
			;fmulp st1
			;fstp dword [lepteky]
			
			
			;calculating the current complex number to be analised by the Julia function which depends on the current pixel's position on the screen
			
			;calc Re
			cvtsi2ss xmm0,dword[widthp2]
			mov dword[a],edx
			cvtsi2ss xmm1,dword[a]
			subss xmm1,xmm0
			movss xmm0,dword [leptekx]
			mulss xmm0,xmm1
			movss xmm1,dword [centerx]
			addss xmm0,xmm1
			movlhps xmm0,xmm0
			
			;calc Im
			cvtsi2ss xmm1,dword [heightp2]
			mov dword[a],ecx
			cvtsi2ss xmm2,dword[a]
			subss xmm1,xmm2
			movss xmm2,dword[lepteky]
			mulss xmm1,xmm2
			movss xmm2,dword [centery]
			addss xmm1,xmm2
			movlhps xmm1,xmm1
			movhlps xmm0,xmm1
			
			
			call JuliaFunctionS
			
			jmp skipdoubleback
			
			doubleback:
				
				
				call JuliaFunctionD
				
			
			skipdoubleback:
			
			;coloring the pixels depending on the iteration value stored in esi(later ebx) which contains the number of iterations for which the current pixel's representation
			;as a complex number was able to stay in the circle with the radius of maxrange/2
			
			mov ebx,esi
			sub bl,[ITnumber]
			neg bl
			jmp skipblackandwhite
			white:
				
				mov [eax], bl
				mov [eax+1],bl
				mov [eax+2], bl
				mov [eax+3],byte 1
				
				jmp skipcolor
			black:
				
				mov [eax],byte 0
				mov [eax+1],byte 0
				mov [eax+2],byte 0
				mov [eax+3],byte 1
				
				jmp skipcolor
			
			skipblackandwhite:
			mov ebx,esi
			push eax
			push edx
			mov eax,ebx
			xor ebx,ebx
			mov bl,2
			mul bx
			mov ebx,eax
			add bl,[color]
			pop edx
			pop eax
			mov [eax],bl
			push eax
			push edx
			mov eax,ebx
			xor ebx,ebx
			mov ebx,eax
			add bl,[color]
			pop edx
			pop eax
			mov [eax+1],bl
			xor ebx,ebx
			add ebx,esi
			push eax
			push edx
			xor edx,edx
			mov eax,ebx
			mov bl,2
			mul bx
			mov ebx,eax
			add bl,[color]
			add ebx,13
			pop edx
			pop eax
			mov [eax+2],bl
			mov [eax+3],byte 1
			
			skipcolor:
			
			;moving  to the next pixel
			add eax,4
			
			inc edx
			jmp loop2
			
			endofloop2:
				inc ecx
				jmp loop1
		
		endofloop1:
		
		;drawing
			call gfx_unmap
			call gfx_draw
			
			;edi - delta x
			;esi - delta y
			;ebx - delta zoom
			
			
			
			mov ebx,[prevebx]
			mov edi,[prevedi]
			mov esi,[prevesi]
			mov edx,50
			mov ecx,-50
	
	event:
	
		call gfx_getevent
		
		mov dword[prevesp],esp
		mov esp,[prevcolor]
		
		;choosing the right action depending on the input
		
		cmp eax,'b'
		je bcktodefault
		cmp eax,'c'
		cmove esp,edx
		cmp eax,-'c'
		je creleased
		cmp eax,'v'
		cmove esp,ecx
		cmp eax,-'v'
		je creleased
		cmp eax,'q'
		je chprecision
		cmp eax,'z'
		cmove ebx,edx
		cmp eax,-'z'
		je zreleased
		cmp eax,'x'
		cmove ebx,ecx
		cmp eax,-'x'
		je xreleased
		cmp eax,32
		je changemove
		cmp eax,'w'
		cmove esi,edx
		cmp eax,-'w'
		je nullifysi
		cmp eax,'a'
		cmove edi,ecx
		cmp eax,-'a'
		je nullifydi
		cmp eax,'s'
		cmove esi,ecx
		cmp eax,-'s'
		je nullifysi
		cmp eax,'d'
		cmove edi,edx
		cmp eax,-'d'
		je nullifydi
		cmp eax,23
		je _end
		cmp eax,27
		je _end
		
		
		;delta x
		
		cmp edi,0
		je skip1
		cvtsi2ss xmm0,edi
		movss xmm1,dword[leptekx]
		mulss xmm0,xmm1
		movss xmm1,dword[centerx]
		addss xmm0,xmm1
		movss dword[centerx],xmm0
		
		cvtsi2sd xmm0,edi
		movsd xmm1,qword[leptekxd]
		mulsd xmm0,xmm1
		movsd xmm1,qword[centerxd]
		addsd xmm0,xmm1
		movsd qword[centerxd],xmm0
		
		skip1:
		
		
		;delta y
		
		cmp esi,0
		je skip2
		cvtsi2ss xmm0,esi
		movss xmm1,dword[lepteky]
		mulss xmm0,xmm1
		movss xmm1,dword[centery]
		addss xmm0,xmm1
		movss dword[centery],xmm0
		
		
		cvtsi2sd xmm0,esi
		movsd xmm1,qword[leptekyd]
		mulsd xmm0,xmm1
		movsd xmm1,qword[centeryd]
		addsd xmm0,xmm1
		movsd qword[centeryd],xmm0
		
		skip2:
		
		;changing the color variable (it changes the appearance of the image, but not the complexity)
		
		cmp esp,0
		je skipchc
		jl lowchc
		highchc:
			add byte[color],1
			jmp skipchc
		lowchc:
			sub byte[color],1
			jmp skipchc
		skipchc:
		
		
		;delta zoom
		
		cmp ebx,0
		je skip3
		jg skip4
			movss xmm0,dword[zoom]
			movss xmm1,dword[zoomconst]
			divss xmm0,xmm1
			movss dword[zoom],xmm0
			
			
			movsd xmm0,qword[zoomd]
			movsd xmm1,qword[zoomconstd]
			divsd xmm0,xmm1
			movsd qword[zoomd],xmm0
			
			mov eax,[ITnumber]
			sub eax,1
			mov dword[ITnumber],eax
			
			jmp skip3
		skip4:
			movss xmm0,dword[zoom]
			movss xmm1,dword[zoomconst]
			mulss xmm0,xmm1
			movss dword[zoom],xmm0
			
			
			movsd xmm0,qword[zoomd]
			movsd xmm1,qword[zoomconstd]
			mulsd xmm0,xmm1
			movsd qword[zoomd],xmm0
			
			mov eax,[ITnumber]
			add eax,1
			mov dword[ITnumber],eax
			
		skip3:
		
		jmp skipn
		
		zreleased:
			
			xor ebx,ebx
			jmp skipn
		
		xreleased:
		
			xor ebx,ebx
			jmp skipn
			
		creleased:
			
			xor esp,esp
			jmp skipn
			
		nullifysi:
		
			xor esi,esi
			jmp skipn
		nullifydi:
		
			xor edi,edi
			jmp skipn
		changemove:
			cmp byte[movemouse],0
			jne null
				mov byte[movemouse],byte 1
				jmp skipn
			null:
				mov byte[movemouse],byte 0
			jmp skipn
			
			
		chprecision:
			
			cmp byte [precision],0
			jne skip5
				
				cvtss2sd xmm0,dword[centerx]
				movlpd [centerxd],xmm0
				cvtss2sd xmm0,dword[centery]
				movlpd [centeryd],xmm0
				cvtss2sd xmm0,dword [zoom]
				movlpd [zoomd],xmm0
				
				jmp skip6
				
			skip5:
				
				cvtsd2ss xmm0,qword[centerxd]
				movss dword[centerx],xmm0
				cvtsd2ss xmm0,qword[centeryd]
				movss dword[centery],xmm0
				cvtsd2ss xmm0,qword[zoomd]
				movss dword[zoom],xmm0
				
				jmp skip6
				
			skip6:
		
		
			not byte[precision]
			jmp skipn
			
			
			bcktodefault:
				
				mov byte[precision],0
				mov dword[zoom],1
				cvtsi2ss xmm0,dword[zoom]
				movss dword [zoom],xmm0
				mov byte[color],1
				mov dword[centerx],0
				mov dword[centery],0
				mov byte[movemouse],1
				
			jmp skipn
			
			
		skipn:
		
		mov dword [prevebx],ebx
		mov dword [prevedi],edi
		mov dword [prevesi],esi
		mov dword [prevcolor],esp
		mov esp,[prevesp]
		
		
		
		
		
		cmp byte[movemouse],0
je skip
		;changing the constant of the Julia function (C) depending on the mouseposition
		call gfx_getmouse
			
			
			;calc ReC
			mov dword [a],WIDTH
			cvtsi2ss xmm0,dword [a]
			mov dword [a],2
			cvtsi2ss xmm1,dword [a]
			divss xmm0,xmm1
			mov dword[a],eax
			cvtsi2ss xmm1,dword[a]
			subss xmm1,xmm0
			movss xmm0,dword [leptekx]
			mulss xmm0,xmm1
			movss xmm1,dword [centerx]
			addss xmm0,xmm1
			movlhps xmm0,xmm0
			movss dword[ReC],xmm0
			
			
			;calc ImC
			mov dword[a],HEIGHT
			cvtsi2ss xmm1,dword[a]
			mov dword [a],2
			cvtsi2ss xmm2,dword [a]
			divss xmm1,xmm2
			mov dword[a],ebx
			cvtsi2ss xmm2,dword[a]
			subss xmm1,xmm2
			movss xmm2,dword[lepteky]
			mulss xmm1,xmm2
			movss xmm2,dword [centery]
			addss xmm1,xmm2
			movlhps xmm1,xmm1
			movhlps xmm0,xmm1
			movss dword[ImC],xmm0
			
			
			
			
skip:
		
		jmp mainloop
		
_end:

	mov esp,[prevesp]
	call gfx_destroy
	ret
	
	

	
	

loop2D:
			
			cmp edx,WIDTH
			jge endofloop2
			
			
			;calc leptekxd
			movsd xmm0,qword[maxranged]
			mov dword[ad],WIDTH
			cvtsi2sd xmm1,dword[ad]
			divsd xmm0,xmm1
			movsd xmm1,qword[zoomd]
			mulsd xmm0,xmm1
			movsd qword[leptekxd],xmm0
			movsd qword[leptekyd],xmm0
			
			
			
			;calculating the current complex number to be analised by the Julia function which depends on the current pixel's position on the screen - Double-precision
			
			;calc Re
			cvtsi2sd xmm0,dword[widthp2]
			mov dword[ad],edx
			cvtsi2sd xmm1,dword[ad]
			subsd xmm1,xmm0
			movsd xmm0,qword [leptekxd]
			mulsd xmm0,xmm1
			movsd xmm1,qword [centerxd]
			addsd xmm0,xmm1
			movlpd [ad],xmm0
			movhpd xmm0,[ad]
			
			;calc Im
			cvtsi2sd xmm1,dword [heightp2]
			mov dword[ad],ecx
			cvtsi2sd xmm2,dword[ad]
			subsd xmm1,xmm2
			movsd xmm2,qword[leptekyd]
			mulsd xmm1,xmm2
			movsd xmm2,qword [centeryd]
			addsd xmm1,xmm2
			movlpd [ad],xmm1
			movlpd xmm0,[ad]
			
jmp doubleback
	
	
	
	
	
	
JuliaFunctionS:
;applies the f(x)= z^2 + C function ITnumber times on the complex number z, which is stored as follows: the real part of the number is stored in the higher 64 bits of the 
;xmm0 register, the imaginary part is stored in the lower 64 bits of the xmm0 register
	
	xor esi,esi
	
	JFSLoop1:
		inc esi
		cmp esi,[ITnumber]
		jg JFSEND
		
		movaps xmm1,xmm0
		mulps xmm1,xmm1
		movlhps xmm2,xmm1
		subps xmm1,xmm2
		
		movhlps xmm2,xmm0
		mulps xmm2,xmm0
		mulps xmm2,xmm3
		
		movhlps xmm0,xmm1
		movlhps xmm0,xmm0
		movss xmm0,xmm2
		
		movss xmm1,dword [ImC]
		movss xmm2,dword [ReC]
		movlhps xmm1,xmm2
		addps xmm0,xmm1
		
		
;calculating distance from O (origo, it is represented by the center of the screen in the beginning of the simulation)
		
		movaps xmm1,xmm0
		mulps xmm1,xmm1
		movhlps xmm2,xmm1
		addps xmm1,xmm2
		
		
;comparing the distance with the maximum range allowed

		comiss xmm1,xmm6
		jb JFSLoop1
		
	JFSEND:
		
		
		
	ret
	
	
JuliaFunctionD:
;the double-precision version of the function above

	xor esi,esi
	
	JFDLoop1:
		
		inc esi
		cmp esi,[ITnumber]
		jg JFDEND
		
		
		movapd xmm1,xmm0
		mulpd xmm1,xmm1
		movlpd [ad],xmm1
		movhpd xmm2,[ad]
		subpd xmm1,xmm2
		
		movhpd [ad],xmm0
		movlpd xmm2,[ad]
		mulpd xmm2,xmm0
		mulpd xmm2,xmm4
		
		movlpd [ad],xmm2
		movlpd xmm0,[ad]
		movhpd [ad],xmm1
		movhpd xmm0,[ad]
		
		cvtss2sd xmm1,dword [ImC]
		cvtss2sd xmm2,dword [ReC]
		movlpd [ad],xmm2
		movhpd xmm1,[ad]
		addpd xmm0,xmm1
		
		movapd xmm1,xmm0
		mulpd xmm1,xmm1
		movhpd [ad],xmm1
		movlpd xmm2,[ad]
		addpd xmm1,xmm2
		
		comisd xmm1,xmm7
		jb JFDLoop1
		
	JFDEND:
	ret