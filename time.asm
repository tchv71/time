; Time.COM - get or set system time


system	MACRO	num,val
	mvi	e,val
	mvi	c,num
	call	5
	ENDM

systemw	MACRO	num,val
	lxi	d,val
	mvi	c,num
	call	5
	ENDM

	aseg
	org 100h
	call	GetInputBuf
	mov	a,h
	ora	l
	jz	NoInput
_01:	mov	a,m
	inx	h
	ora	a
	jz	0
	cpi	20h
	jz	_01
	cpi	9
	jz	_01
	dcx	h
	push	h
	lxi	d,TimeBuf
	mvi	c,2Ch
	call	BIOS_DATE
	pop	h
	jmp	ParseTime01
NoInput:
	systemw	9,TimeMsg
	lxi	d,TimeBuf
	mvi	c,2Ch
	call	BIOS_DATE
	lda	Hours
	call	PrintNum
	system	2,':'
	lda	Minutes
	call	PrintNum2
	system	2,':'
	lda	Seconds
	call	PrintNum2
	system	2,0Dh
	system	2,0Ah
GetTime:
	systemw	9,InputMsg
	systemw	0ah, strbuff
	lda	strbuff+1
	mov	l,a
	mvi	h,0
	lxi	d,strbuff+2
	dad	d
	mvi	m,0
	xchg
	mov	a,m
	ora	a
	jz	0
ParseTime01:
	mvi	b,0
	mvi	c,3
ParseTime:
	mov	a,m
	call	IsDelim
	jz	prst02
	lxi	d,FieldBuf
	push	b
	push	d
	call	GetField
	pop	d
	pop	b
	jc	InvalidTime
	push	h
	push	b
	call	GetVal
	pop	b
	pop	h
	jc	InvalidTime
	call	SaveField
prst02:
	inx	h
	inr	b
	inr	b
	inr	m
	dcr	m
	jz	prst01
	dcr	c
	jnz	ParseTime
prst01:	lxi	d,TimeBuf
	mvi	c,2Dh
	call	BIOS_DATE
	jmp	0

SaveField:
	push	h
	push	d
	lxi	h,FieldAddr
	mov	e,b
	mvi	d,0
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	stax	d
	pop	d
	pop	h
	ret

FieldAddr:
	dw	Hours,Minutes,Seconds

InvalidTime:
	systemw	9,InvalidTimeMsg
	jmp	GetTime

GetField:
	mov	a,m
	call	IsDelim
	jz	InvalidTime
	mvi	c,2
gf01:
	mov	a,m
	stax	d
	inx	d
	inx	h
	mov	a,m
	call	IsDelim
	jnz	gf02
	xra	a
	stax	d
	ret
gf02:	dcr	c
	jnz	gf01
	stc
	ret

GetVal:
	xchg
	mov	a,m
	mvi	b,0
gv02:
	mov	a,m
	inx	h
	sui	'0'
	rc
	cpi	10
	jc	gv01
	stc
	ret

gv01:
	inr	m
	dcr	m
	jnz	gv04
	add	b
	ret

gv04:
	mov	c,a
	inr	c
	xra	a
	mov	b,a
gv03:
	dcr	c
	jz	gv02
	adi	10
	mov	b,a
	jmp	gv03

FieldBuf:
	ds	3

strbuff:db	14,0
	ds	15

	
BIOS_DATE:
	lhld	1
	push	b
	lxi	b,33h
	dad	b
	pop	b
	mov	a,m
	cpi	jmp
	rnz
	inx	h
	push	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pop	d
	pchl

PrintNum2:
	cpi	10
	jnc	PrintNum
	push	psw
	system	2,'0'
	pop	psw
PrintNum:
	mvi	e,'0'
	cpi	10
	jc	pd01
pd02:
	inr	e
	sui	10
	cpi	10
	jnc	pd02
	push	psw
	mvi	c,2
	call	5
	pop	psw
pd01:
	adi	'0'
	mov	e,a
	mvi	c,2
	jmp	5

GetInputBuf:
	lxi	h,0
	lda	80h
	ora	a
	rz
	lxi	h,82h
	push	h
	add	l
	mov	l,a
	mvi	m,0
	pop	h
	ret


IsDelim:
	push	h
	push	b
	lxi	h,Delim
IsDel02:
	mov	c,m
	inx	h
	inr	c
	dcr	c
	jz	IsDel01
	cmp	c
	jz	IsDel03
	jmp	IsDel02
IsDel01:
	ora	a
IsDel03:
	pop	b
	pop	h
	ret

TimeBuf:
Hours:		DB	0
Minutes:	DB	0
Seconds:	DB	0
SecondFraction:	DB	0
SubSeconds:	DB	0

InvalidTimeMsg:
	DB	13,10,'*** Invalid time',13,10,'$'
TimeMsg:
	DB	'Current time is $'
InputMsg:
	DB	'Enter new time: $'
Delim:	DB	20h,9,',-./:',0

	END
