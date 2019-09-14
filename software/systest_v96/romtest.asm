;for train-z94

OFFSET	equ	2000h




;-------PROG START BEGIN: ------------------------------------
	org 	OFFSET

	;init
	xor		A
	ld		C,A
	ld		HL,0000h	;init rom pointer

l_1:
	ld		B,(HL)	;read rom address
	ld		A,C		;restore A from C
	add		A,B
	ld		C,A		;backup A in C

	inc		HL		;advance rom pointer

	ld		A,H
	cp		0Eh		;check for highbyte of rom area
	jp		nz,l_1

	ld		A,L
	cp		0D4h		;check for lowbyte of rom area+1
	jp		nz,l_1



	ld		A,C		;restore checksum from C
	ld		DE,OFFSET+100h
	ld		(DE),A	;save rom check sum in location OFFSET+20h

	ret
