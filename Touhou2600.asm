*
* How to branch!
* I always forget these!!
*
* X < Y
* LDA	X	
* CMP	Y
* BCS   else 	 
*
* X <= Y
*
* LDA	Y
* CMP	X
* BCC	else
*
* X > Y 
*
* LDA	Y
* CMP	X
* BCS	else
*
* X >= Y
*
* LDA	X
* CMP	Y
* BCC 	else
*



*Init Section
*---------------------------
* This is were variables and
* constants are asigned.
*
* This does not count into the
* ROM space.
*

random = $80
counter = $81
stack = $82
temp01 = $83
temp02 = $84
temp03 = $85
temp04 = $86
temp05 = $87
temp06 = $88
temp07 = $89
temp08 = $8a
temp09 = $8b
temp10 = $8c
temp11 = $8d
temp12 = $8e
temp13 = $8f
temp14 = $90
temp15 = $91
temp16 = $92
temp17 = $93
temp18 = $94
temp19 = $95

*
*	From $96 to $A5 is reserved for global stuff.
*
*	$96 - $99 is for the SoundPlayer 
*	Can be found at the bank1 routines.
* 

HScore_1 = $9A
HScore_2 = $9B
HScore_3 = $9C
HScore_4 = $9D
HScore_5 = $9E
HScore_6 = $9F
TextCounter = $A0

************************
*
* Constants
*-----------------------

NTSC_Vblank   =	169
NTSC_Overscan =	163
NTSC_Display  = 229

PAL_Vblank   =	169
PAL_Overscan =	206
PAL_Display  =  244


***************************
********* Start of 1st bank
***************************

	fill 256	; We have to prevent writing on addresses taken by the SuperChip RAM.

###Start-Bank1

*Enter Bank
*-----------------------------
*
* This is the section that happens
* everytime you go to a new screen.
* Should set the screen initialization
* here.
*

EnterScreenBank1

*
* Bank1 contains the main kernel and basically the game itself.
* This section is read as you start a new game.
*
*

LivesAndBombs = $A6
*
*	Low Nibble : Bombs
*	High Nibble: Lives	
*	
Score_1 = $A7
Score_2 = $A8
Score_3 = $A9
Score_4 = $AA
Score_5 = $AB
Score_6 = $AC

LevelAndCharge = $AD
*
*	0-4: Charge
*	  5: Just shoot flag
*	6-7: Level
*
eikiX = $AE
*
*	0-6: X position
*	7  : Direction
*
eikiY = $AF
*	
*	0-3: Y Position
*	4-7: Free
*
eikiSettings = $B0
*	0-1: 3 counter
*	2-4: Color Index
*	
*	4: Moving
*	5: Attack
*	6: Spell
*	7: Dead
*
eikiSettings2 = $B1
*
*	0-3: SpriteIndex
*	4-5: CoolDown
*	6-7: Free
*
DanmakuColor = $B2
StickBuffer = $B3


Eiki_Height = 23
Eiki_HeightPlus1 = 24
NumberOfLines = 35
StickColor = $30

	LDA	#60
	STA	eikiX

	LDA	#5
	STA	eikiY

	LDA	#%01100000
	STA	temp18
	LDA	#0
	STA	temp19

	JSR	Bank1_SoundPlayer

	LDA	#0
	STA	eikiSettings
	STA	eikiSettings2

****	LDA	#%00110011
	STA	StickBuffer

	LDA	#$06
	STA	DanmakuColor


HitBoxMinus = 9 	

Danmaku_Col_1W = $F016
Danmaku_Col_2W = $F028
Danmaku_Col_3W = $F03A
Danmaku_Col_4W = $F04C

Danmaku_Col_1R = $F096
Danmaku_Col_2R = $F0A8
Danmaku_Col_3R = $F0BA
Danmaku_Col_4R = $F0CC

	JMP	WaitUntilOverScanTimerEndsBank1

*Leave Bank
*-------------------------------
*
* This section goes as you leave
* the screen. Should set where to
* go and close or save things.
*

LeaveScreenBank1


*Overscan
*-----------------------------
*
* This is the place of the main
* code of this screen.
*

OverScanBank1

	CLC
        LDA	INTIM 
        BNE 	OverScanBank1

	STA	WSYNC
	LDA	#%11000010
	STA	VBLANK
	STA	WSYNC

    	LDA	#NTSC_Overscan
    	STA	TIM64T
	INC	counter

*Overscan Code
*-----------------------------
*
* This is where the game code
* begins.
*

	ASL	StickBuffer
*
*	Attack CountDown
*

	LDA	eikiSettings
	AND	#%11000000
	CMP	#0
	BNE	Bank1_EikiDeadOrSpell

*
*	Special: Double Click for spell!
*
	LDA	LevelAndCharge
	AND	#%00100000
	CMP	#%00100000
	BNE	Bank1_CannotCastSpell

	BIT 	INPT4
	BMI	Bank1_CannotCastSpell

	LDA	LevelAndCharge
	AND	#%11000000
	ORA	#%00011111
	STA	LevelAndCharge

	LDA	eikiSettings
	ORA	#%01000000
	AND	#%11011111
	STA	eikiSettings

	LDA	eikiSettings2
	AND	#%11001111
	STA	eikiSettings2

	JMP	Bank1_EikiDeadOrSpell

Bank1_CannotCastSpell

	LDA	eikiSettings2
	AND	#%11001111
	STA	temp01

	LDA	eikiSettings2
	AND	#%00110000
	CMP	#0
	BEQ	Bank1_DontSetMagicFlag	

	BIT 	INPT4
	BPL	Bank1_DontSetMagicFlag

	LDA	LevelAndCharge
	ORA	#%00100000
	STA	LevelAndCharge	

Bank1_DontSetMagicFlag

	LDA	counter
	AND	#%00000011
	CMP	#%00000011
	BNE	Bank1_CannotAttack

	LDA	eikiSettings2
	AND	#%00110000
	CMP	#0
	BEQ	Bank1_NoCountDownNeeded
	SEC
	SBC	#%00010000
	AND	#%00110000
	CMP	#0
	BNE	Bank1JustSaveThings
	STA	temp02
*
*	Disable Attack
*
	LDA	eikiSettings
	AND	#%11011111
	STA	eikiSettings
*
*	Disable Magic Flag
*	
	LDA	LevelAndCharge
	AND	#%11011111
	STA	LevelAndCharge	

	LDA	temp02
Bank1JustSaveThings
	ORA	temp01
	STA	eikiSettings2	

	JMP	Bank1_CannotAttack
Bank1_NoCountDownNeeded

	BIT	INPT4
	BMI	Bank1_NoAttackPressed
*
*	Enable Attack Bit and set counter to 3.
*
	LDA	eikiSettings	
	ORA	#%00100000
	STA	eikiSettings

	LDA	eikiSettings2
	ORA	#%00110000
	STA	eikiSettings2

	LDA	StickBuffer
	ORA	#7
	STA	StickBuffer

	LDA	#%00000010
	STA	temp18
	LDA	#0
	STA	temp19

	JSR	Bank1_SoundPlayer

	JMP	Bank1_JustAttacked

Bank1_EikiDeadOrSpell

	BIT	eikiSettings
	BMI	Bank1_EikiDied
	BVC	Bank1_EikiNoSpell

	LDA	counter
	AND	#%00000001
	CMP	#%00000001
	BNE	Bank1_EikiDied

	LDA	counter
	AND	#%00000111
	CMP	#%00000111
	BNE	Bank1_NoDECSpellCounter

	LDA	#1
	STA	temp18
	LDA	#0
	STA	temp19

	JSR	Bank1_SoundPlayer
	LDA	LevelAndCharge
	AND	#%11000000
	STA	temp01	

	LDA	LevelAndCharge
	AND	#%00011111
	SEC
	SBC	#1
	AND	#%00011111	
	STA	LevelAndCharge
	CMP	#0
	BNE	Bank1_DontStopSpell

	LDA	eikiSettings
	AND	#%10111111
	STA	eikiSettings

Bank1_DontStopSpell
	LDA	LevelAndCharge
	ORA	temp01
	STA	LevelAndCharge
*
*	Set sprite
*
Bank1_NoDECSpellCounter
Bank1_CannotAttack
Bank1_NoAttackPressed
Bank1_JustAttacked
Bank1_EikiNoSpell
	LDA	eikiY
	AND	#%00001111		
	TAX
	LDA	SWCHA
	ASL
	ASL	
	BMI	Bank1_NoIncY
	TXA
	CMP	#11
	BCS	Bank1_NotMovedHor
	CLC
	ADC	#1
	JMP	Bank1_MovedHor
Bank1_NoIncY
	ASL	
	BMI	Bank1_NotMovedHor
	TXA
	CMP	#0
	BEQ	Bank1_NotMovedHor
	SEC
	SBC	#1
Bank1_MovedHor
	STA	eikiY
Bank1_NotMovedHor

	LDA	Bank1MaxX	
	SEC
	SBC	Bank1MinX
	STA	temp01

	LDA	eikiX
	AND	#%01111111
	BIT	SWCHA
	BVS	Bank1_NoMoveLeft
	CMP	#0
	BEQ	Bank1_NoDecX
	SEC
	SBC	#1
Bank1_NoDecX
	AND	#%01111111
	JMP	Bank1_NoMoveRight
Bank1_NoMoveLeft
	BMI	Bank1_NoMove
	CMP	temp01
	BEQ	Bank1_NoIncX
	CLC
	ADC	#1
Bank1_NoIncX
	ORA	#%10000000
Bank1_NoMoveRight
	STA	eikiX

	LDA	eikiSettings
	ORA	#%00010000
	JMP	Bank1_Moved
Bank1_NoMove
	LDA	eikiSettings
	AND	#%11101111
Bank1_Moved
	STA	eikiSettings

Bank1_EikiDied

	LDA	counter
	AND	#7
	CMP	#7
	BNE	Bank1_DontINCSpriteIndex
	
	LDA	eikiSettings
	AND	#%11111100
	STA	temp01

	LDA	eikiSettings
	AND	#%00000011
	CLC
	ADC	#1
	CMP	#3
	BCC	Bank1_SmallerThan3
	LDA	#0
Bank1_SmallerThan3
	ORA	temp01
	STA	eikiSettings
Bank1_DontINCSpriteIndex

*
*	Priority: Dead, Spell, Attack, Moving, Standing
*
	LDA	eikiSettings
	BMI	Bank1_EikiDead
	ASL
	BMI	Bank1_EikiSpell
	ASL	
	BMI	Bank1_EikiAttack
	ASL	
	BMI	Bank1_EikiMoving

	LDA	eikiSettings
	AND	#%00000011
	STA	temp01

	LDA	eikiSettings2
	AND	#$F0
	ORA	temp01
	STA	eikiSettings2

*
*	Set colorpointer to 0
*
	JMP	Bank1_EikiColorPointer0	
Bank1_EikiDead

Bank1_EikiSpell
	LDA	eikiSettings2
	AND	#$F0
	ORA	#6			
	STA	eikiSettings2

	LDA	eikiSettings
	AND	#%11110011
	ORA	#%00001000
	STA	eikiSettings

	JMP	Bank1_EikiGotSpritePointer

Bank1_EikiAttack

	LDA	eikiSettings2
	AND	#$F0
	ORA	#5			
	STA	eikiSettings2

	LDA	eikiSettings
	AND	#%11110011
	ORA	#%00000100
	STA	eikiSettings

	JMP	Bank1_EikiGotSpritePointer

Bank1_EikiMoving
	LDA	eikiX
	ROL
	ROL
	AND	#1
	CLC	
	ADC	#3
	STA	temp01
	LDA	eikiSettings2
	AND	#$F0
	ORA	temp01
	STA	eikiSettings2

Bank1_EikiColorPointer0
	LDA	eikiSettings
	AND	#%11110011
	STA	eikiSettings

Bank1_EikiGotSpritePointer

	LDX	#NumberOfLines
	DEX
Bank1_Erase_PF
******	LDA	#0

	LDA	TestPF_00,x
	STA	Danmaku_Col_1W,x

	LDA	TestPF_01,x
	STA	Danmaku_Col_2W,x

	LDA	TestPF_02,x
	STA	Danmaku_Col_3W,x

	LDA	TestPF_03,x
	STA	Danmaku_Col_4W,x

	DEX
	BPL	Bank1_Erase_PF

Bank1_Fill_PF_Ended

*VSYNC
*----------------------------7
* This is a fixed section in
* every bank. Don't need to be
* at the same space, of course.

WaitUntilOverScanTimerEndsBank1
	CLC
	LDA 	INTIM
	BMI 	WaitUntilOverScanTimerEndsBank1

* Sync the Screen
*

	LDA 	#2
	STA 	WSYNC  ; one line with VSYNC
	STA 	VSYNC	; enable VSYNC
	STA 	WSYNC 	; one line with VSYNC
	STA 	WSYNC 	; one line with VSYNC
	LDA 	#0
	STA 	WSYNC 	; one line with VSYNC
	STA 	VSYNC 	; turn off VSYNC

* Set the timer for VBlank
*
	STA	VBLANK
	STA 	WSYNC

	CLC
 	LDA	#NTSC_Vblank
	STA	TIM64T


*VBLANK
*-----------------------------
* This is were you can set a piece
* of code as well, but some part may
* be used by the kernel.
*
VBLANKBank1

	LDA	#%00000000
	STA	temp18
	STA	temp19
	JSR	Bank1_SoundPlayer

*SkipIfNoGameSet - VBLANK
*---------------------------------
*


VBlankEndBank1
	CLC
	LDA 	INTIM
	BMI 	VBlankEndBank1

    	LDA	#NTSC_Display
    	STA	TIM64T


*Screen
*--------------------------------  
* This is the section for the
* top part of the screen.
*

	tsx
	stx	stack


	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUBK	
	STA	COLUP0
	STA	COLUP1	
	STA	COLUPF	
*
*	TestLines should be removed from finished product.
*

	JSR	Bank1_TestLines
****	JMP 	Bank1_Main_Ended

Bank1_Eiki_Field
	LDA	#0
	STA	WSYNC
	STA	COLUBK
	STA	HMCLR
	STA	PF0		; 9

	STA	PF1
	STA	PF2
	STA	GRP0
	STA	GRP1
**	STA	ENABL
**	STA	ENAM0
**	STA	ENAM1

*
*	Sprites
*

	LDA	eikiSettings2
	AND	#%00001111
	ASL
	TAX					; 9 (23)


	LDA	Eiki_Sprite_Pointers_P0,x
	STA	temp01
	LDA	Eiki_Sprite_Pointers_P0+1,x
	STA	temp02				; 16 (39)
	
	
	LDA	Eiki_Sprite_Pointers_P1,x
	STA	temp03
	LDA	Eiki_Sprite_Pointers_P1+1,x
	STA	temp04				; 16 (55)


	LDA	eikiX			
	AND	#%01111111
	STA	temp11
	STA	temp12				; 11 (66)

	CLC
	ADC	#4
	STA	temp13

	lda	counter
	and	#1
	tax
	LDA	Bank1M1AddX,x
	CLC
	ADC	temp11
	STA	temp14

*	LDA	#$1e
*	STA	COLUBK

Bank1_HorPos
*
*	Based on X, it will save
*	the position on strobe and also,
*	it will save the value on temp11-temp15
*
*
*  MinX = 39
** MaxX = 159
NumOfLoop=3

*	STA	WSYNC
*	LDA	#$1e
*	STA	COLUBK

	LDX	#NumOfLoop
Bank1_MaxLoop
	LDA	temp11,x
	CLC				
	ADC	Bank1MinX,x			
	CMP	Bank1MaxX,x			
 	BCS 	Bank1_OverMax	
	JMP	Bank1_NotOverMax
Bank1_OverMax
	LDA	Bank1MaxX,x
Bank1_NotOverMax
	STA	temp11,x
	DEX
	BPL	Bank1_MaxLoop

*	STA	WSYNC
*	LDA	#$00
*	STA	COLUBK

	LDX	#NumOfLoop
Bank1_NextHorPoz
	STA	WSYNC
	LDA	temp11,x
Bank1_DivideLoop
	sbc	#15
   	bcs	Bank1_DivideLoop
   	sta	temp11,X
   	sta	RESP0,X	
	DEX
	BPL	Bank1_NextHorPoz	

	STA	WSYNC

*	LDA	#$00
*	STA	COLUBK

	ldx	#NumOfLoop
Bank1_setFine
   	lda	temp11,x
	CLC
	ADC	#16
	TAY
   	lda	Bank1_FineAdjustTable,y
   	sta	HMP0,x		
	DEX
	BPL	Bank1_setFine


	STA	WSYNC
	STA	HMOVE

*	LDA	#0
*	STA	COLUBK

	LDA	#$20
	STA	NUSIZ1

	LDA	#$10
	STA	NUSIZ0
*
*	PF  : Mirrored, before the player
*
	LDA	#%00010001
	STA	CTRLPF			; 3

*
*	temp01: Eiki's P0 pointer
*	temp03: Eiki's P1 pointer
*	temp05: Eiki's P0 Color pointer
*	temp07: Eiki's P1 Color pointer
*
*	temp12: HitBox Y
*	temp13: Temp
*	temp14: Temp
*	temp15: Stickbuffer
*	temp16: Double Counter
*	temp19: Eiki's Y
*
	
	LDA	eikiSettings
	AND	#%00001100
	LSR					 
	TAX					; 9 

	LDA	Eiki_Sprite_Color_Pointers_P0,x		
	STA	temp05
	LDA	Eiki_Sprite_Color_Pointers_P0+1,x
	STA	temp06				; 16 

	LDA	Eiki_Sprite_Color_Pointers_P1,x
	STA	temp07
	LDA	Eiki_Sprite_Color_Pointers_P1+1,x
	STA	temp08				; 16 

	LDA	eikiY
	AND	#%00011111
	STA	temp14
	CLC
	ADC	#Eiki_Height
	STA	temp19	
	SEC
	SBC	#HitBoxMinus 
	CLC
	SBC	temp14
	STA	temp12


*
*	The kernel has basically 3 parts:
*	-Before Eiki: Your missiles, the spell, pf
*	-Eiki: Eiki, pf
*	-After Eiki: pf
*

	LDA	#NumberOfLines			; 2 
	STA	temp16

	LDA	StickBuffer
	STA	temp15

	LDA	counter
	AND	#$0F
	TAX
	LDA	Bank1_VicaVersa,x
	STA	temp14

	LDA	DanmakuColor
	STA	COLUPF

	BIT	eikiSettings
	BVS	Bank1_Eiki_Before_Magic__

	LDA	#StickColor		; 2
	ORA	temp14			; 3
	STA	COLUP0			; 3

	sleep	13

	JMP	Bank1_Eiki_Before_Loop	; 3 
Bank1_Eiki_Before_Magic__
	LDA	counter			; 3
	AND	#$F0			; 2 
	ORA	temp14			; 3
	STA	COLUP1			; 3
	
	LDA	#$0F			; 2
	SEC				; 2
	SBC	temp14			; 3
	STA	COLUP0			; 3


	JMP	Bank1_Eiki_Before_Loop	; 3 

*
*	Danmaku_Col_1R
*	Danmaku_Col_2R 
*	Danmaku_Col_3R 
*	Danmaku_Col_4R
*

	_align	125

Bank1_Eiki_Before_Loop
	STA	WSYNC
	LDA	temp16
	LSR
	TAX		; 7

	LDA	Danmaku_Col_1R,x
	STA	PF1

	LDA	Danmaku_Col_2R,x
	STA	PF2		; 14 (21)

***	sleep	20

	BIT 	eikiSettings		; 2 (23)
	BVC	Bank1_Eiki_Before_No_Magic	; 2 (25)

	LDA	counter
	LSR
	SBC	temp16		; 3 (28)
	AND	#%00000011	; 2 (33)

	JMP	Bank1_Eiki_Before_Was_Magic ; 2 (37) 

Bank1_Eiki_Before_No_Magic	 
	sleep	3
	LDA	#0		; 2 (27)
	ASL	temp15		; 5 (33)
	ROL			; 2 (35)

Bank1_Eiki_Before_Was_Magic
	TAY			; 2 (39)

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)

	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)
	
***	TXS			; 2 (55)

***	sleep	2

	BIT 	eikiSettings		; 2 (66)
	BVS	Bank1_Eiki_Before_Was_Magic2	; 2 (68)

	sleep	12

	LDA	Bank1_FakeMissile,y 	     ; 4 (74)
	JMP	Bank1_Eiki_Before_Was_No_Magic2 ; 3 (1)

Bank1_Eiki_Before_Was_Magic2
	sleep	9
	LDA	#2
	STA	ENAM1

	LDA	Bank1_Magic_Pattern_0,y ; 4 (70)
***	LDA	Bank1_Magic_Pattern_1,y ; 4 (74)
***	STX	GRP0			; 3 (1)
***	LDA	#%10100101
***	sleep	2
Bank1_Eiki_Before_Was_No_Magic2
	STA	GRP0			; 3 (4)	

***	TSX			; 2 (6)
	sleep	2
Bank1_Eiki_Before_SecondLine
	LDA	Danmaku_Col_1R,x
	STA	PF1

	LDA	Danmaku_Col_2R,x
	STA	PF2		; 14 (20)

***	sleep	19
	LDA	#Eiki_HeightPlus1	; 2 (22)
	DCP	temp19			; 5 (27)
	BCC	Bank1_NoEiki_StayHere 	; 2 (29)

	LDY	#Eiki_HeightPlus1	; 2 (31)
	STA	CXCLR			; 3 (34)
	sleep	2
	JMP	Bank1_GoForEiki		; 3 (39)
***	JMP	Bank1_ResetThings
Bank1_NoEiki_StayHere
	sleep	9

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)

	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)

	DEC	temp16
	BPL	Bank1_Eiki_Before_Loop
	
	_align	143

Bank1_Eiki_Loop
	STA	WSYNC
	LDA	temp16
	LSR
	TAX		; 7

	LDA	Danmaku_Col_1R,x
	STA	PF1

	LDA	Danmaku_Col_2R,x
	STA	PF2		; 14 (23)	
	
***	sleep	20
	sleep	4

	LDA	(temp05),y	; 5 (28)
	STA	temp13		; 3 (31)
	
	LDA	(temp03),y	; 5 (36)
	STA	temp14		; 3 (39)

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)
	
	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)
	
***	sleep	19

	LDA	(temp07),y	; 5 
	STA	COLUP1		; 3 
	LDA	temp13		; 3 
	STA	COLUP0		; 3 

	LDA	temp14		; 3 
	STA	GRP1		; 3 

Bank1_Eiki_Loop_Secondline
	
***	sleep	15
	LDA	(temp01),y	; 5 
	STA	GRP0		; 3 

	CPY	temp12
	PHP	
	PLA	
	STA	ENAM0		; 13

**	sleep	12

	LDA	Danmaku_Col_1R,x
	STA	PF1		; 7 (22)

	LDA	Danmaku_Col_2R,x
	STA	PF2		; 7 (29)	

****	sleep	7
	LDA	#0
	STA	ENAM1
	sleep	2

Bank1_GoForEiki	

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)
	
	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)

	LDX	stack		; 3 (56)
	TXS			; 2 (58)

	DEC	temp16		; 5 (63)
	DEY			; 2 (65)
	BPL	Bank1_Eiki_Loop	; 2 (67)
	
	LDY	#1

Bank1_OnlyDanmaku_Loop
	STA	WSYNC
	LDA	temp16
	LSR
	TAX		; 7

	LDA	Danmaku_Col_1R,x
	STA	PF1	; 7 (14)

	LDA	#0
	STA	GRP0
	STA	GRP1	; 8 (22)
	

	LDA	Danmaku_Col_2R,x
	STA	PF2		; 7 (29)	

	sleep	12

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)
	
	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)

	DEY
	BPL	Bank1_OnlyDanmaku_Loop	

	LDY	#1

	DEC	temp16
	BPL	Bank1_OnlyDanmaku_Loop

Bank1_ResetThings

	LDA	#0
	STA	WSYNC
	STA	PF1
	STA	PF2
	STA	GRP0
	STA	GRP1

	ldx	stack
	txs	

Bank1_Main_Ended
	JSR	Bank1_TestLines


	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUBK	
	STA	COLUP0
	STA	COLUP1	
	STA	COLUPF	
	
	ldx	stack
	txs

	JMP	OverScanBank1

*Data Section 
*----------------------------------
* Here goes the data used by
* custom ScreenTop and ScreenBottom
* elments.
*
	_align	4
Bank1MaxX
**	BYTE	#159
**	BYTE	#159
	BYTE	#157
	BYTE	#157
	BYTE	#161
	BYTE	#163

	_align	4
Bank1MinX
**	BYTE	#39
**	BYTE	#39
	BYTE	#43
	BYTE	#43
	BYTE	#43
	BYTE	#41

	_align	2
Bank1M1AddX
	BYTE	#0
	BYTE	#10

	_align	2

Bank1_FakeMissile
	BYTE	#%00000000
	BYTE	#%01100110


	_align	4
Bank1_Magic_Pattern_0
	BYTE 	#%01111110
	BYTE 	#%11111111
	BYTE 	#%01111110
	BYTE 	#%00111100

	_align	16

Bank1_VicaVersa	
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08
	BYTE	#$0A
	BYTE	#$0C
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0C
	BYTE	#$0A
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00

	_align	6

Bank1_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1

	_align	16
Bank1_FineAdjustTable
	byte	#$80
	byte	#$70
	byte	#$60
	byte	#$50
	byte	#$40
	byte	#$30
	byte	#$20
	byte	#$10
	byte	#$00
	byte	#$f0
	byte	#$e0
	byte	#$d0
	byte	#$c0
	byte	#$b0
	byte	#$a0
	byte	#$90

	_align	18
TestPF_00
	BYTE %00010000
	BYTE %00101000
	BYTE %01000101
	BYTE %10000010
	BYTE %00000000
	BYTE %01100110
	BYTE %00000000
	BYTE %11001110
	BYTE %10101000
	BYTE %11001100
	BYTE %10101000
	BYTE %11001110
	BYTE %00000000
	BYTE %00010000
	BYTE %00101000
	BYTE %01000101
	BYTE %01100110
	BYTE %10011001

	_align	18

TestPF_01
	BYTE %10000010
	BYTE %01000101
	BYTE %00101000
	BYTE %00010000
	BYTE %00000000
	BYTE %01100110
	BYTE %00000000
	BYTE %00100011
	BYTE %00100100
	BYTE %00100010
	BYTE %00100001
	BYTE %01110110
	BYTE %00000000
	BYTE %10000010
	BYTE %01000101
	BYTE %00101000
	BYTE %01100110
	BYTE %10011001

	_align	18

TestPF_02
	BYTE %00000100
	BYTE %10001010
	BYTE %01010001
	BYTE %00100000
	BYTE %00000000
	BYTE %01100110
	BYTE %00000000
	BYTE %01000111
	BYTE %01000100
	BYTE %01100100
	BYTE %01010100
	BYTE %01100100
	BYTE %00000000
	BYTE %00000100
	BYTE %10001010
	BYTE %01010001
	BYTE %01100110
	BYTE %10011001

	_align	18

TestPF_03
	BYTE %00001000
	BYTE %00010100
	BYTE %10100010
	BYTE %01000001
	BYTE %00000000
	BYTE %01100110
	BYTE %00000000
	BYTE %01001010
	BYTE %01001010
	BYTE %01001110
	BYTE %01001010
	BYTE %10100100
	BYTE %00000000
	BYTE %00001000
	BYTE %00010100
	BYTE %10100010
	BYTE %01100110
	BYTE %10011001
*
*	Height      = 24
*

	_align	14
Eiki_Sprite_Pointers_P0
	byte 	#<Eiki_Sprite_Stand_P0_0
	byte	#>Eiki_Sprite_Stand_P0_0
	byte 	#<Eiki_Sprite_Stand_P0_1
	byte	#>Eiki_Sprite_Stand_P0_1
	byte 	#<Eiki_Sprite_Stand_P0_2
	byte	#>Eiki_Sprite_Stand_P0_2
	byte 	#<Eiki_Sprite_Move_P0_0
	byte	#>Eiki_Sprite_Move_P0_0
	byte 	#<Eiki_Sprite_Move_P0_1
	byte	#>Eiki_Sprite_Move_P0_1
	byte	#<Eiki_Sprite_Attack_P0
	byte	#>Eiki_Sprite_Attack_P0
	byte	#<Eiki_Sprite_Spell_P0
	byte	#>Eiki_Sprite_Spell_P0

	_align	14
Eiki_Sprite_Pointers_P1
	byte 	#<Eiki_Sprite_Stand_P1_0
	byte	#>Eiki_Sprite_Stand_P1_0
	byte 	#<Eiki_Sprite_Stand_P1_1
	byte	#>Eiki_Sprite_Stand_P1_1
	byte 	#<Eiki_Sprite_Stand_P1_2
	byte	#>Eiki_Sprite_Stand_P1_2
	byte 	#<Eiki_Sprite_Move_P1_0
	byte	#>Eiki_Sprite_Move_P1_0
	byte 	#<Eiki_Sprite_Move_P1_1
	byte	#>Eiki_Sprite_Move_P1_1
	byte	#<Eiki_Sprite_Attack_P1
	byte	#>Eiki_Sprite_Attack_P1
	byte	#<Eiki_Sprite_Spell_P1
	byte	#>Eiki_Sprite_Spell_P1

	_align	6
Eiki_Sprite_Color_Pointers_P0
	byte 	#<Eiki_Color_Stand_Move_P0
	byte	#>Eiki_Color_Stand_Move_P0
	byte 	#<Eiki_Color_Attack_P0
	byte	#>Eiki_Color_Attack_P0
	byte 	#<Eiki_Color_Spell_P0
	byte	#>Eiki_Color_Spell_P0

	_align	6
Eiki_Sprite_Color_Pointers_P1
	byte 	#<Eiki_Color_Stand_Move_P1
	byte	#>Eiki_Color_Stand_Move_P1
	byte 	#<Eiki_Color_Attack_P1
	byte	#>Eiki_Color_Attack_P1
	byte 	#<Eiki_Color_Spell_P1
	byte	#>Eiki_Color_Spell_P1

	_align	24

Eiki_Sprite_Stand_P1_0
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%10100101
	byte	#%00111111
	byte	#%10011101
	byte	#%01111110
	byte	#%00111100
	byte	#%00111100
	byte	#%00011000
	byte	#%00111100
	byte	#%00111100
	byte	#%00111100
	byte	#%01101100
	byte	#%01010110
	byte	#%01011010
	byte	#%01100000
	byte	#%11111000
	byte	#%10011000	

	_align	24

Eiki_Sprite_Stand_P1_1
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01011001
	byte	#%01011110
	byte	#%01001100
	byte	#%00111111
	byte	#%00111100
	byte	#%00111100
	byte	#%00011000
	byte	#%00111100
	byte	#%00111100
	byte	#%00111100
	byte	#%00101110
	byte	#%01010111
	byte	#%01101000
	byte	#%01111000
	byte	#%11111100
	byte	#%10011000	

	_align	24
Eiki_Sprite_Stand_P1_2
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%01100110
	byte	#%10011010
	byte	#%10010110
	byte	#%11011010
	byte	#%00111110
	byte	#%00111100
	byte	#%00111100
	byte	#%00011000
	byte	#%00111100
	byte	#%00111100
	byte	#%00111100
	byte	#%10111110
	byte	#%00010110
	byte	#%00110110
	byte	#%01100010
	byte	#%11110000
	byte	#%10011000	; (2)

	_align	24

Eiki_Sprite_Move_P1_0
	byte	#%01100110
	byte	#%00110011
	byte	#%00110011
	byte	#%00110011
	byte	#%01100110
	byte	#%11101110
	byte	#%01110110
	byte	#%00111111
	byte	#%01101001
	byte	#%01111010
	byte	#%00110101
	byte	#%00011110
	byte	#%00001110
	byte	#%00001100
	byte	#%00001110
	byte	#%00001110
	byte	#%00001110
	byte	#%00011110
	byte	#%01101101
	byte	#%01011010
	byte	#%01001101
	byte	#%01110000
	byte	#%11111000
	byte	#%10011000

	_align	24	
Eiki_Sprite_Move_P1_1
	byte	#%01100110
	byte	#%11001100
	byte	#%11001100
	byte	#%11001100
	byte	#%01100110
	byte	#%01110111
	byte	#%01101110
	byte	#%11111100
	byte	#%01001010
	byte	#%10101110
	byte	#%01010100
	byte	#%00111000
	byte	#%01110000
	byte	#%00110000
	byte	#%01110000
	byte	#%01110000
	byte	#%01110000
	byte	#%01111000
	byte	#%01011010
	byte	#%01101110
	byte	#%10110010
	byte	#%01000000
	byte	#%11100000
	byte	#%10000000	; (4)

	_align	24

Eiki_Color_Stand_Move_P1
	byte	#$04
	byte	#$0a
	byte	#$0e
	byte	#$0e
	byte	#$0e
	byte	#$0e
	byte	#$3e
	byte	#$3e
	byte	#$04
	byte	#$88
	byte	#$86
	byte	#$84
	byte	#$86
	byte	#$44
	byte	#$86
	byte	#$88
	byte	#$86
	byte	#$84
	byte	#$d6
	byte	#$D8
	byte	#$08
	byte	#$82
	byte	#$86
	byte	#$84

	_align	24

Eiki_Sprite_Stand_P0_0
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%01011010
	byte	#%11000000
	byte	#%01100010
	byte	#%00000000
	byte	#%11000011
	byte	#%01000011
	byte	#%11000010
	byte	#%11000011
	byte	#%11000011
	byte	#%01000010
	byte	#%00010000
	byte	#%00101000
	byte	#%10100101
	byte	#%00011110
	byte	#%00000111
	byte	#%00000001	

	_align	24
Eiki_Sprite_Stand_P0_1
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00100110
	byte	#%00100001
	byte	#%00110011
	byte	#%00000000
	byte	#%01000011
	byte	#%01000010
	byte	#%01100011
	byte	#%01000011
	byte	#%01000011
	byte	#%01000010
	byte	#%00010000
	byte	#%00101000
	byte	#%00010111
	byte	#%00000110
	byte	#%00000011
	byte	#%00000001	

	_align	24
Eiki_Sprite_Stand_P0_2
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%01100100
	byte	#%01101000
	byte	#%00100100
	byte	#%00000000
	byte	#%11000010
	byte	#%11000010
	byte	#%01000110
	byte	#%11000010
	byte	#%11000010
	byte	#%01000010
	byte	#%01000000
	byte	#%01101000
	byte	#%11001000
	byte	#%00011100
	byte	#%00001111
	byte	#%00000001	

	_align	24
Eiki_Sprite_Move_P0_0
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00010110
	byte	#%00000101
	byte	#%00001010
	byte	#%11100000
	byte	#%01110001
	byte	#%00110011
	byte	#%01110001
	byte	#%01110001
	byte	#%01110001
	byte	#%00100001
	byte	#%00010010
	byte	#%00100100
	byte	#%00110010
	byte	#%00001110
	byte	#%00000111
	byte	#%00000001

	_align	24
Eiki_Sprite_Move_P0_1
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%10110100
	byte	#%01010000
	byte	#%00101000
	byte	#%00000111
	byte	#%10001110
	byte	#%11001100
	byte	#%10001110
	byte	#%10001110
	byte	#%10001110
	byte	#%10000100
	byte	#%10100100
	byte	#%00010000
	byte	#%01001100
	byte	#%00111110
	byte	#%00011111
	byte	#%00011001	; (4)

	_align	24

Eiki_Color_Stand_Move_P0
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$3e
	byte	#$3e
	byte	#$0e
	byte	#$8a
	byte	#$88
	byte	#$0a
	byte	#$0c
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0c
	byte	#$0e
	byte	#$d8
	byte	#$Da
	byte	#$0e
	byte	#$86
	byte	#$8A
	byte	#$88

	_align	24	

Eiki_Sprite_Attack_P1
	byte	#%01000010
	byte	#%01100110
	byte	#%11100111
	byte	#%01111110
	byte	#%00111100
	byte	#%00111100
	byte	#%01111110
	byte	#%10100101
	byte	#%11000011
	byte	#%11001111
	byte	#%01110010
	byte	#%00111100
	byte	#%00011000
	byte	#%00111100
	byte	#%00111100
	byte	#%01111110
	byte	#%00111100
	byte	#%01111110
	byte	#%10100101
	byte	#%01111110
	byte	#%11110001
	byte	#%10011001
	byte	#%00000000
	byte	#%00000000	; (0)

	_align	24	

Eiki_Color_Attack_P1
	byte	#$02
	byte	#$04
	byte	#$06
	byte	#$0e
	byte	#$0e
	byte	#$3c
	byte	#$3e
	byte	#$04
	byte	#$8c
	byte	#$8a
	byte	#$88
	byte	#$44
	byte	#$86
	byte	#$88
	byte	#$8a
	byte	#$88
	byte	#$d4
	byte	#$d6
	byte	#$0e
	byte	#$84
	byte	#$86
	byte	#$88
	byte	#$88
	byte	#$88

	_align	24	

Eiki_Sprite_Attack_P0
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%01011010
	byte	#%00111100
	byte	#%00110000
	byte	#%00001100
	byte	#%00000000
	byte	#%00100100
	byte	#%00010000
	byte	#%11000011
	byte	#%10000001
	byte	#%01000010
	byte	#%10000001
	byte	#%01011010
	byte	#%10000001
	byte	#%00001110
	byte	#%01100110
	byte	#%11000011
	byte	#%10000001	; (0)

	_align	24	

Eiki_Color_Attack_P0
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$0c
	byte	#$0e
	byte	#$8c
	byte	#$8a
	byte	#$1e
	byte	#$88
	byte	#$0a
	byte	#$0a
	byte	#$0c
	byte	#$0a
	byte	#$08
	byte	#$0a
	byte	#$0c
	byte	#$84
	byte	#$0e
	byte	#$3c
	byte	#$3e


	_align	24	

Eiki_Sprite_Spell_P1
	byte	#%11000011
	byte	#%11000011
	byte	#%11000011
	byte	#%11000011
	byte	#%11000011
	byte	#%11000011
	byte	#%11100111
	byte	#%10111001
	byte	#%11010011
	byte	#%01100110
	byte	#%00011000
	byte	#%01000010
	byte	#%11000011
	byte	#%10110101
	byte	#%01011010
	byte	#%01011010
	byte	#%00001110
	byte	#%00111111
	byte	#%01100110
	byte	#%11011011
	byte	#%11100111
	byte	#%01000010
	byte	#%10000001
	byte	#%00000000	; (0)


	_align	24	

Eiki_Color_Spell_P1
	byte	#$02
	byte	#$04
	byte	#$06
	byte	#$0c
	byte	#$0e
	byte	#$3c
	byte	#$3e
	byte	#$8c
	byte	#$8a
	byte	#$88
	byte	#$86
	byte	#$0a
	byte	#$0e
	byte	#$d6
	byte	#$d8
	byte	#$08
	byte	#$8c
	byte	#$8a
	byte	#$0c
	byte	#$0e
	byte	#$3e
	byte	#$1c
	byte	#$1e
	byte	#$0e


	_align	24	

Eiki_Sprite_Spell_P0
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%01000110
	byte	#%00101100
	byte	#%00011000
	byte	#%00000000
	byte	#%00111100
	byte	#%00111100
	byte	#%01001010
	byte	#%00100100
	byte	#%10100101
	byte	#%01110000
	byte	#%11000000
	byte	#%10011001
	byte	#%00100100
	byte	#%00011000
	byte	#%00111100
	byte	#%01111110
	byte	#%00000000	; (0)


	_align	24	

Eiki_Color_Spell_P0
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$1e
	byte	#$8a
	byte	#$88
	byte	#$86
	byte	#$0c
	byte	#$86
	byte	#$84
	byte	#$d8
	byte	#$da
	byte	#$0e
	byte	#$86
	byte	#$86
	byte	#$84
	byte	#$3c
	byte	#$16
	byte	#$8a
	byte	#$8e
	byte	#$1e
*
*	Tokens
*
	_align	19

Tokens_Sprite_P1_1up
	byte	#%11111111
	byte	#%10101101
	byte	#%10110111
	byte	#%10110101
	byte	#%11110111
	byte	#%10100001
Tokens_Sprite_P1_Bomb
	byte	#%11111111
	byte	#%10111001
	byte	#%10100101
	byte	#%10111001
	byte	#%10100101
	byte	#%10111001
Tokens_Sprite_P1_Gold
	byte	#%11111111
	byte	#%10011001
	byte	#%10100101
	byte	#%10101101
	byte	#%10100001
	byte	#%10011101
	byte	#%11111111	; (0)

	_align	19
Tokens_Color_P1_1up
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0e
	byte	#$0e
	byte	#$0c
Tokens_Color_P1_Bomb
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0e
	byte	#$0e
	byte	#$0c
Tokens_Color_P1_Gold
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0e
	byte	#$0e
	byte	#$0c
	byte	#$0a

	_align	19
Tokens_Sprite_P0_1up
	byte	#%00000000
	byte	#%01010010
	byte	#%01001000
	byte	#%01001010
	byte	#%00001000
	byte	#%01011110
Tokens_Sprite_P0_Bomb
	byte	#%00000000
	byte	#%01000110
	byte	#%01011010
	byte	#%01000110
	byte	#%01011010
	byte	#%01000110
Tokens_Sprite_P0_Gold
	byte	#%00000000
	byte	#%01100110
	byte	#%01011010
	byte	#%01010010
	byte	#%01011110
	byte	#%01100010
	byte	#%00000000	; (0)

	_align	19
Tokens_Color_P0_1up
	byte	#$72
	byte	#$74
	byte	#$76
	byte	#$76
	byte	#$74
	byte	#$72
Tokens_Color_P0_Bomb
	byte	#$d4
	byte	#$d6
	byte	#$d8
	byte	#$d8
	byte	#$d6
	byte	#$d4
Tokens_Color_P0_Gold
	byte	#$18
	byte	#$1a
	byte	#$1c
	byte	#$1e
	byte	#$1c
	byte	#$1a
	byte	#$18

*
*	AUDC0 / AUDC1
*

	_align 	4
Bank1_SoundPlayer_SoundChannels
	BYTE	#6
	BYTE	#2
	BYTE	#9
	BYTE	#14
*
*	Must be between 1-15
*
	_align 	4
Bank1_SoundPlayer_SoundDurations
	BYTE	#8
	BYTE	#11
	BYTE	#6
	BYTE	#10
*
*	Can be set 1-7
*
	_align 	4
Bank1_SoundPlayer_SoundSlowDown
	BYTE	#2
	BYTE	#2
	BYTE	#3
	BYTE	#4

	_align	8
Bank1_SoundPlayer_SoundData_Pointers
	BYTE	#<Bank1_SoundPlayer_SoundData_1
	BYTE	#>Bank1_SoundPlayer_SoundData_1
	BYTE	#<Bank1_SoundPlayer_SoundData_2
	BYTE	#>Bank1_SoundPlayer_SoundData_2
	BYTE	#<Bank1_SoundPlayer_SoundData_3
	BYTE	#>Bank1_SoundPlayer_SoundData_3
	BYTE	#<Bank1_SoundPlayer_SoundData_4
	BYTE	#>Bank1_SoundPlayer_SoundData_4
*
*	Every byte is build up:
*	0-4: Frequency
*	5-8: Volume
*
	_align	8
Bank1_SoundPlayer_SoundData_1
	BYTE	#%00100010
	BYTE	#%00101100
	BYTE	#%01010000
	BYTE	#%01011000
	BYTE	#%10010000
	BYTE	#%00101100
	BYTE	#%01100100
	BYTE	#%00100010

	_align	11
Bank1_SoundPlayer_SoundData_2
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#%01000111
	BYTE	#%01101000
	BYTE	#%10000111
	BYTE	#%10000011
	BYTE	#%01001101

	_align	6
Bank1_SoundPlayer_SoundData_3
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#%01001110
	BYTE	#%00100111
	BYTE	#%00111110

	_align	10
Bank1_SoundPlayer_SoundData_4
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#%01001000
	BYTE	#%00101000
	BYTE	#%00100100
	BYTE	#%00100010
	BYTE	#%00100001
	BYTE	#%01100010

*Routines Section 
*----------------------------------
* Reusable code
*

*
*	The sound player is used globally, and transfers
* 	data thru temp18 and temp19!
*
*	temp18 is used only for new sound registration.
*	0-3:	The sound id (max of 16)
*	4:	Set if the sound must be looped.
*	5:	Force Mute channel 0
*	6:	Force Mute Channel 1
*	7:	Register sound (1) / Play sound (0)
*
*	Basically there are three modes:
*	- temp18 is 0, it's put in vblank, 
*         it plays the sounds in the buffer.
*	- temp18 has 5 or 6 bits set, so it's muting sound
*	- temp18 has the 7th bit set, it registers a new sound.
*
*	temp19 is used for returning, it's set auto in 
*       the subroutine of on each bank,
*
*	255 if it was called from bank1 with JSR.
*
SoundCounters = $96
*	low  nibble: channel0
*	high nibble: channel1
* 
SoundSettings = $97
*	0-5: free
*	6  : loop for channel0
*	7  : loop for channel1
*
SoundChannels = $98
*	low  nibble: channel0
*	high nibble: channel1
* 
SoundPointers = $99
*	low  nibble: channel0
*	high nibble: channel1


Bank1_SoundPlayer
	LDA	temp18
	CMP	#0
	BNE	Bank1_SoundSettingsMustBeDone
	JMP	Bank1_No_New_Sound
Bank1_SoundSettingsMustBeDone
	AND	#%01100000
	CMP	#0
	BEQ	Bank1_NoMutingButSetting
	CMP	#%01100000
	BNE	Bank1_NoMutingForBoth

	LDA	#0
	STA	SoundCounters
	STA	SoundSettings
	JMP	Bank1_ReturnFromSP

Bank1_NoMutingForBoth
	TAX
	AND	#%00100000
	CMP	#%00100000
	BNE	Bank1_NoMutingForChannel0

	STY	AUDV0
	LDA	SoundCounters
	AND	#$F0
	STA	SoundCounters

	LDA	SoundSettings
	AND	#%10111000
	STA	SoundSettings

Bank1_NoMutingForChannel0
	TXA	
	AND	#%01000000
	CMP	#%01000000
	BPL	Bank1_NoMutingForChannel1

	STY	AUDV1
	LDA	SoundCounters
	AND	#$0F
	STA	SoundCounters

	LDA	SoundSettings
	AND	#%01000111
	STA	SoundSettings
	

Bank1_NoMutingForChannel1

	JMP	Bank1_ReturnFromSP

Bank1_NoMutingButSetting
	LDY	#0
	LDA	temp18

	AND	#$0F
	TAX
	
	LDA	Bank1_SoundPlayer_SoundChannels,x
	STA	temp01

	LDA	SoundChannels
	AND	#$0F
	STA	temp02
	CMP	temp01
	BNE	Bank1_Channel_NotFound1
	JMP	Bank1_Channel_Found
Bank1_Channel_NotFound1
	LDA	SoundChannels
	LSR
	LSR
	LSR
	LSR
	CMP	temp01	
	BNE	Bank1_Channel_NotFound2
	LDY	#1
	JMP	Bank1_Channel_Found

Bank1_Channel_NotFound2
	CMP	temp02
	BCS	Bank1_CounterOfChannel0IsSmaller
	LDY	#1
Bank1_CounterOfChannel0IsSmaller
* X > Y 
*
* LDA	Y (temp01)
* CMP	X (temp02)
* BCS	else
*
Bank1_Channel_Found
	LDA	Bank1_SoundPlayer_SoundDurations,x
	STA	temp02

	TXA
	STA	temp03	

	LDA	temp18
	AND	#%00010000
	ASL
	ASL
	STA	temp05

	LDA	Bank1_SoundPlayer_SoundSlowDown,x
	STA	temp06

	CPY	#0
	BEQ	Bank1_Save_On_Channel_0
	JMP	Bank1_Save_On_Channel_1
Bank1_Save_On_Channel_0

	LDA	temp01
	STA	AUDC0

	LDA	SoundChannels
	AND	#$F0
	ORA	temp01
	STA	SoundChannels

	LDA	SoundCounters
	AND	#$F0
	ORA	temp02
	STA	SoundCounters

	LDA	SoundPointers
	AND	#$F0
	ORA	temp03
	STA	SoundPointers

	LDA	SoundSettings
	AND	#%10111000
	ORA	temp05
	ORA	temp06
	STA	SoundSettings	

	JMP	Bank1_ReturnFromSP
Bank1_Save_On_Channel_1

	LDA	SoundChannels
	AND	#$0F
	STA	SoundChannels

	LDA	SoundCounters
	AND	#$0F
	STA	SoundCounters

	LDA	SoundPointers
	AND	#$0F
	STA	SoundPointers

	LDA	temp01
	STA	AUDC1
	ASL
	ASL
	ASL
	ASL
	ORA	SoundChannels
	STA	SoundChannels

	LDA	temp02
	ASL
	ASL
	ASL
	ASL
	ORA	SoundCounters
	STA	SoundCounters

	LDA	temp03
	ASL
	ASL
	ASL
	ASL
	ORA	SoundPointers
	STA	SoundPointers	ASL 	temp05
	LDA	temp06	
	ASL
	ASL	
	ASL
	STA	temp06

	LDA	SoundSettings
	AND	#%01000111
	ORA	temp05
	ORA	temp06
	STA	SoundSettings

	JMP	Bank1_ReturnFromSP
Bank1_No_New_Sound
	LDA	#0
	STA	temp06
	STA	temp07

	LDA	SoundCounters
	AND	#$0F
	CMP	#0
	BNE	Bank1_Play_Channel0
	LDA	SoundSettings
	AND	#%11111000
	STA	SoundSettings

	JMP	Bank1_Finished_Channel0
Bank1_Play_Channel0
	TAY
	DEY

*	LDA	#$88
*	STA	COLUBK

	LDA	SoundPointers
	AND	#$0F
	ASL
	TAX

	LDA	Bank1_SoundPlayer_SoundData_Pointers,x
	STA	temp01
	LDA	Bank1_SoundPlayer_SoundData_Pointers+1,x
	STA	temp02	

	LDA	(temp01),y
	STA	AUDF0
	
	LSR
	LSR
	LSR	
	LSR
	LSR
	CMP	#0
	BEQ	Bank1_NoVolINC0
	CLC
	ADC	#2
Bank1_NoVolINC0
	STA	temp06
***	STA	AUDV0

	LDA	SoundSettings
	AND	#%11111000
	STA	temp13

	LDA	SoundSettings
	AND	#%00000111
	SEC
	SBC	#1
	AND	#%00000111
	ORA	temp13
	STA	SoundSettings
	AND	#%00000111		
	CMP	#0
	BNE	Bank1_Finished_Channel0

	LDA	SoundSettings
	AND	#%11111000	
	ORA	Bank1_SoundPlayer_SoundSlowDown,x
	STA	SoundSettings

*	LDA	counter
*	AND 	Bank1_SoundPlayer_SoundSlowDown,x	
*	CMP	Bank1_SoundPlayer_SoundSlowDown,x
*	BNE	Bank1_Finished_Channel1

	CPY	#0
	BNE	Bank1_NoLoopResetChannel0
	BIT	SoundSettings
	BVC	Bank1_NoLoopResetChannel0
	LDY	Bank1_SoundPlayer_SoundDurations,x	
Bank1_NoLoopResetChannel0
	STY	temp03
	
	LDA	SoundCounters
	AND	#$F0
	ORA	temp03
	STA	SoundCounters

Bank1_Finished_Channel0
	LDA	SoundCounters
	LSR
	LSR
	LSR
	LSR
	CMP	#0
	BNE	Bank1_Play_Channel1

	LDA	SoundSettings
	AND	#%11000111
	STA	SoundSettings

	JMP	Bank1_Finished_Channel1
Bank1_Play_Channel1
	TAY
	DEY
	
***	LDA	#$1e
***	STA	COLUBK

	LDA	SoundPointers
	LSR
	LSR
	LSR
****	LSR
	TAX


	LDA	Bank1_SoundPlayer_SoundData_Pointers,x
	STA	temp01
	LDA	Bank1_SoundPlayer_SoundData_Pointers+1,x
	STA	temp02

	LDA	(temp01),y
***	STA	$00F0,y
	STA	AUDF1

	LSR
	LSR
	LSR	
	LSR
	LSR
	CMP	#0
	BEQ	Bank1_NoVolINC1
	CLC
	ADC	#2
Bank1_NoVolINC1
	STA	temp07
***	STA	AUDV1

	LDA	SoundSettings
	AND	#%11000111
	STA	temp13

	LDA	SoundSettings
	AND	#%00111000
	SEC
	SBC	#%00001000
	AND	#%00111000
	ORA	temp13
	STA	SoundSettings
	AND	#%00111000		
	CMP	#0
	BNE	Bank1_Finished_Channel1
	
	LDA	Bank1_SoundPlayer_SoundSlowDown,x
	ASL
	ASL
	ASL
	ORA	temp13
	STA	SoundSettings

*	LDA	counter
*	AND 	Bank1_SoundPlayer_SoundSlowDown,x	
*	CMP	Bank1_SoundPlayer_SoundSlowDown,x
*	BNE	Bank1_Finished_Channel1

	CPY	#0
	BNE	Bank1_NoLoopResetChannel1
	BIT	SoundSettings
	BPL	Bank1_NoLoopResetChannel1
	LDY	Bank1_SoundPlayer_SoundDurations,x
Bank1_NoLoopResetChannel1
	TYA	
	ASL
	ASL
	ASL
	ASL
	STA 	temp03	

	LDA	SoundCounters
	AND	#$0F
	ORA	temp03
	STA	SoundCounters

Bank1_Finished_Channel1
*Bank1_SetVolumes
	LDA	temp06
	STA	AUDV0
	LDA	temp07
	STA	AUDV1

Bank1_ReturnFromSP
	LDA	#0
	STA	temp18
	LDX	temp19
	CPX	#255
	BNE	Bank1_ReturnNoRTS
Bank1_Return
	RTS
Bank1_ReturnNoRTS

	TXA
	INX

	ASL		
	TAY

	LDA	Bank1_Return_JumpTable,y
   	pha
   	lda	Bank1_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump


Bank1_TestLines
	LDA	#1
	STA	CTRLPF

	LDX	#1
	LDA	counter
	STA	COLUPF
	LDA	#255
Bank1_TestLine1
	STA	WSYNC
	STA	PF1
	STA	PF2
	
	DEX
	BPL 	Bank1_TestLine1
		
	LDA	#0
	STA	WSYNC
	STA	PF1
	STA	PF2

	RTS

###End-Bank1


	saveFreeBytes
	rewind 1fd4

start_bank1 
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address   
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 1ffc
   	.byte 	#<start_bank1
   	.byte 	#>start_bank1
   	.byte 	#<start_bank1
   	.byte 	#>start_bank1

***************************
********* Start of 2nd bank
***************************
	Bank 2

	fill	256
###Start-Bank2
	
*Enter Bank
*-----------------------------
*
* This is the section that happens
* everytime you go to a new screen.
* Should set the screen initialization
* here.
*


EnterScreenBank2

*
* This is the very first screen you witness as
* you startup the game. Contains the menu.
*
*

	LDA	#$12
	STA	HScore_1

	LDA	#$34
	STA	HScore_2

	LDA	#$56
	STA	HScore_3

	LDA	#$78
	STA	HScore_4

	LDA	#$90
	STA	HScore_5

	LDA	#$12
	STA	HScore_6

	LDA	#%01100000
	STA	temp18
	JSR	Bank2_Call_SoundPlayer


	LDA	#0

	STA	ENAM0
	STA	ENAM1
	STA	ENABL

*
*	Disable missiles and ball.
*
*
* 	The columns are 8 lines tall.
*
ScrollingColumn1 = $A6
ScrollingColumn2 = $AE
ScrollingColumn3 = $B6
ScrollingColumn4 = $BE
*
*	Next free one: $C7
*
WaitCounter = $C7
*
PressedDelay = $C8
*	7th bit   : ON / OFF
*	6th bit   : Checks if fire was hold at the beginning.
*	5th bit   : Visible / Non-visible
*	All others: counter


	LDX	#8
Bank2InitScrollingColumns	
	STA	ScrollingColumn1,x
	STA	ScrollingColumn2,x
	STA	ScrollingColumn3,x
	STA	ScrollingColumn4,x
	DEX
	BPL	Bank2InitScrollingColumns

	STA	PressedDelay

	LDA	#255
	STA	WaitCounter
****	STA	$F0
*
*	Superchip RAM $F0000 - F0015 is reserved for long time storage!
* 	Never use those!
*

	LDA	#0
	BIT 	INPT4
	BMI	Bank2_No_Joy0_Fire_Was_Pressed_At_Enter
	LDA	#%01000000
Bank2_No_Joy0_Fire_Was_Pressed_At_Enter
	STA	PressedDelay

	JMP	WaitUntilOverScanTimerEndsBank2

*Leave Bank
*-------------------------------
*
* This section goes as you leave
* the screen. Should set where to
* go and close or save things.
*

LeaveScreenBank2


*Overscan
*-----------------------------
*
* This is the place of the main
* code of this screen.
*

OverScanBank2

	CLC
        LDA	INTIM 
        BNE 	OverScanBank2

	STA	WSYNC
	LDA	#%11000010
	STA	VBLANK
	STA	WSYNC

    	LDA	#NTSC_Overscan
    	STA	TIM64T
	INC	counter

*Overscan Code
*-----------------------------
*
* This is where the game code
* begins.
*


*
*	Fill the SARA with JinJang PF data!
*

JinJang_Col_01W = $F016
JinJang_Col_01R = $F096

JinJang_Col_02W = $F036
JinJang_Col_02R = $F0B6

JinJang_ColorW = $F056
JinJang_ColorR = $F0D6

	LDA	PressedDelay
	BPL	Bank2_NoCounter_ForLeaving
	
	LDY	SoundCounters
	CPY	#$01
	BNE	Bank2_NoCounter_ForLeaving

	AND	#$0F
	TAX
	INX	
	CPX	#14
	BNE	Bank2_DontLeaveTheScreenYet

*
*	Give you two bombs and three lives.
*
	LDA	#$32
	STA	LivesAndBombs

*
*	Reset level to 1.	
*
	LDA	#%01000000
	STA	LevelAndCharge
*
*	Reset Score
*
	LDA	#0
	STA	Score_1
	STA	Score_2
	STA	Score_3
	STA	Score_4
	STA	Score_5
	STA	Score_6


	lda	#>(EnterScreenBank3-1)
   	pha
   	lda	#<(EnterScreenBank3-1)
   	pha
   	pha
   	pha
   	ldx	#3
   	jmp	bankSwitchJump

Bank2_DontLeaveTheScreenYet
	STX	temp01
	LDA	PressedDelay
	AND	#$F0
	ORA	temp01
	STA	PressedDelay
Bank2_NoCounter_ForLeaving
	LDA	counter
	LSR
	LSR
	AND	#%00000111
	TAY
	LSR
***	LSR
	AND	#%00000011
	TAX
	LDA	JingJang_Color_Adder,y
	STA	temp05
*
*	temp01: The low  nibble for JJ Left
*	temp02: The high nibble for JJ Left
*	temp03: The low  nibble for JJ Right
*	temp04: The high nibble for JJ Right
*       temp05: Amplitude
*

	LDA	JingJang_00_LookUp,x	
	STA	temp01			

	LDA	#>JinJang_1_00		
	STA	temp02			

	LDA	JingJang_01_LookUp,x	
	STA	temp03			

	LDA	#>JinJang_1_01		
	STA	temp04			

	LDY	#15
	LDX	#31

JinJang_Fill_SARA
	LDA	(temp01),y		
	STA	JinJang_Col_01W,x

	LDA	(temp03),y		
	STA	JinJang_Col_02W,x

	LDA	temp05
	BPL	JinJang_Fill_SARA_HasColor_1
	LDA	#0
	JMP	JinJang_Fill_SARA_Nope_1
JinJang_Fill_SARA_HasColor_1
	LDA	JinJang_Colors_32,x
	CLC
	ADC	temp05
JinJang_Fill_SARA_Nope_1
	STA	JinJang_ColorW,x

	DEX
	LDA	(temp01),y		
	STA	JinJang_Col_01W,x

	LDA	(temp03),y		
	STA	JinJang_Col_02W,x

	LDA	temp05
	BPL	JinJang_Fill_SARA_HasColor_2
	LDA	#0
	JMP	JinJang_Fill_SARA_Nope_2
JinJang_Fill_SARA_HasColor_2
	LDA	JinJang_Colors_32,x
	CLC
	ADC	temp05
JinJang_Fill_SARA_Nope_2
	STA	JinJang_ColorW,x

	DEY
	DEX
	BPL	JinJang_Fill_SARA

*
*	Text is based on mirrored playfield.
*	So shifting bits to the left goes like this.
*	Non-mirrored PF1 << Mirrored PF2 << Non-Mirrored PF2 << Mirrored PF1 << Buffer
*	temp 19 is tud buffer.	
*
*	

Bank2FirstNum = 180
Bank2SecondNum = 150

	LDA	counter
	AND	#%0000011
	CMP	#%0000011
	BNE	Bank2WaitCounterNoChange

	INC	WaitCounter
	LDA	WaitCounter
	CMP	#Bank2FirstNum
	BCC	Bank2WaitCounterNotLargerThan1

	LDA	#0
	STA	WaitCounter
	JMP	Bank2WaitCounterNoMoreThings
Bank2WaitCounterNotLargerThan1
	CMP	#Bank2SecondNum
	BCC	Bank2WaitCounterNotLargerThan2

	LDA	#0
	JMP	Bank2WaitCounterNoMoreThings
Bank2WaitCounterNotLargerThan2
	TAX

	LDA	Impure_Soul_Eclipse,x
Bank2WaitCounterNoMoreThings
	STA	temp19

	LDX	#7
Bank2ShiftingLoop
	LSR	temp19
	ROR	ScrollingColumn4,x
	ROL	ScrollingColumn3,x
	ROR	ScrollingColumn2,x
	ROL	ScrollingColumn1,x
	DEX
	BPL	Bank2ShiftingLoop

Bank2WaitCounterNoChange

	BIT	PressedDelay
	BMI	Bank2_Fire0WasOncePressed_During_Overscan
	BVS	Bank2_No_Joy0_Still_Not_Released
	BIT 	INPT4
	BMI	Bank2_No_Joy0_Fire_Was_Pressed_At_Overscan	
*
*	Register 0th sound with loop.
*
	LDA	#%10010000
	STA	temp18
	JSR	Bank2_Call_SoundPlayer

	LDA	PressedDelay
	ORA	#%10000000
	JMP	Bank2_Save_Pressed
Bank2_No_Joy0_Fire_Was_Pressed_At_Overscan
Bank2_No_Joy0_Still_Not_Released

	BIT 	INPT4
	BPL	Bank2_No_Joy0_Fire_Was_Released_At_Overscan
	LDA	PressedDelay
	AND	#%10111111
Bank2_Save_Pressed
	STA	PressedDelay
Bank2_No_Joy0_Fire_Was_Released_At_Overscan
Bank2_Fire0WasOncePressed_During_Overscan

	LDX	#0
	BIT	PressedDelay
	BMI 	Bank2_NotPressedFireYet
	INX
Bank2_NotPressedFireYet
	LDA	counter
	AND 	Bank2_Press_Fire_Speed,x
	CMP	Bank2_Press_Fire_Speed,x
	BNE 	Bank2_No5thBitFlip
	LDA	PressedDelay
	EOR	#%00100000
	STA	PressedDelay
Bank2_No5thBitFlip

**	LDA	SoundCounters
**	CMP	#0
**	BNE	Bank2_NoSoundTest

**	LDA	#$01
**	BIT	SWCHB
**	BNE	Bank2_NoSoundTest
**	INC	$F0	
**	LDA	$F0
**	AND	#%00000011
**
**	ORA	#%10000000
**	STA	temp18
**	JSR	Bank2_Call_SoundPlayer	
**Bank2_NoSoundTest

*VSYNC
*----------------------------
* This is a fixed section in
* every bank. Don't need to be
* at the same space, of course.

WaitUntilOverScanTimerEndsBank2
	CLC
	LDA 	INTIM
	BMI 	WaitUntilOverScanTimerEndsBank2

* Sync the Screen
*

	LDA 	#2
	STA 	WSYNC  ; one line with VSYNC
	STA 	VSYNC	; enable VSYNC
	STA 	WSYNC 	; one line with VSYNC
	STA 	WSYNC 	; one line with VSYNC
	LDA 	#0
	STA 	WSYNC 	; one line with VSYNC
	STA 	VSYNC 	; turn off VSYNC

* Set the timer for VBlank
*
	STA	VBLANK
	STA 	WSYNC

	CLC
 	LDA	#NTSC_Vblank
	STA	TIM64T


*VBLANK
*-----------------------------
* This is were you can set a piece
* of code as well, but some part may
* be used by the kernel.
*
VBLANKBank2
	LDA	#0
	STA	temp18
	JSR	Bank2_Call_SoundPlayer


*SkipIfNoGameSet - VBLANK
*---------------------------------
*


VBlankEndBank2
	CLC
	LDA 	INTIM
	BMI 	VBlankEndBank2

    	LDA	#NTSC_Display
    	STA	TIM64T


*Screen
*--------------------------------  
* This is the section for the
* top part of the screen.
*

	tsx
	stx	stack

	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUPF		; 3 
	STA	COLUP0		; 3 (6)
	STA	COLUP1		; 3 (9)
	STA	COLUBK		; 3 (12)	

*
* The Touhou logo has two seperated parts.
* First, a spinning jinjang ball in the background.	
* The other part is the Touhou 2600 text.
*

Bank2_DrawLogo
	STA	PF0		; 3 (15)
	STA	PF1		; 3 (18)
	STA	NUSIZ1		; 3 (21)
*
*	CTRLPF bits:
*	0  : Mirrored
*	1  : Two Colors
*	2  : Players move behind playfield
*	4-5: Ball Size
* 
	LDA	#%0000001	; 2 (20)
	STA	CTRLPF		; 3 (23)
*
*	Mirrored playfield.
*
	
	LDA	counter		; 3 (26)
	LSR
	LSR		
	LSR			; 6 (32)

	AND	#%00000011	; 2 (34)
	STA	RESP0
	TAX			; 2 (36)
	STA	RESP1

	LDA	#$02			; 2 
	STA	NUSIZ0			; 3
*
*	P0 spites set to 2 instances with medium gaps.
*

	LDA	counter
	AND	#$0F
	TAX
	LDA	Touhou_Title_Color,x
	STA	COLUP0
	STA	COLUP1

	LDA	#$10
	STA	HMP0
	LDA	#$00
	STA	HMP1
	
	STA	WSYNC
	STA	HMOVE

	LDX	#4
Bank2_Blank_Lines1
	STA	WSYNC
	DEX
	BPL	Bank2_Blank_Lines1

	LDA	counter
	AND	#1
	TAX	
	LDA	JingJang_First_HMOVE,x
	STA	HMP0
	STA	HMP1
	STA	WSYNC
	STA	HMOVE

Bank2_DrawLogo_Loop_Text

	LDA	#0
	STA	PF2
	STA	GRP0
	STA	GRP1
*
*	temp01: Pointer to touhou text column 1
*	temp03: Pointer to touhou text column 2	
*	temp05: Pointer to touhou text column 3
*	temp07: Pointer to touhou text column 4
*	temp09: Pointer to touhou text column 5
*	temp11: Pointer to touhou text column 6
*
*	temp13: Adder to Col6
*	temp14: Adder to Col5
*	temp15: Adder to Col4
*	temp16: Adder to Col3
*	temp17: Adder to Col2
*	temp18: Adder to Col1
*
	LDX	#6
Bank2_Set_Adders
	TXA
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC	counter
	BMI	Bank2_NotThatEasy

	sleep	9
	LDA	#8
	JMP	Bank2_NextAdder
Bank2_NotThatEasy
	AND	#%01111111
	LSR
	LSR
	LSR
	TAY
	LDA	Touhou_Letter_Adder,y	
Bank2_NextAdder
	STA	temp13,x
	DEX
	BPL	Bank2_Set_Adders
	

	LDA	#<Touhou_Title__E00
	CLC	
	ADC	temp18	
	STA	temp01

	LDA	#<Touhou_Title__E01
	CLC	
	ADC	temp17	
	STA	temp03

	LDA	#<Touhou_Title__E02
	CLC	
	ADC	temp16	
	STA	temp05

	LDA	#<Touhou_Title__E03
	CLC	
	ADC	temp15	
	STA	temp07

	LDA	#<Touhou_Title__E04
	CLC	
	ADC	temp14	
	STA	temp09

	LDA	#<Touhou_Title__E05
	CLC	
	ADC	temp13	
	STA	temp11

	LDA	#>Touhou_Title__E00
	STA	temp02
	STA	temp04
	STA	temp06
	STA	temp08
	STA	temp10
	STA	temp12

	LDY	#31

	LDA	counter
	AND	#1
	TAX
	CPX	#1
	BNE	Bank2_DrawLogo_Loop_Text_Odd_Start		
	JMP	Bank2_DrawLogo_Loop_Text_Even_Start

	_align	100
Bank2_DrawLogo_Loop_Text_Even_Start
	LDA	#$80			; 2 
	STA	HMP0			; 3 
	STA	HMP1			; 3 

Bank2_DrawLogo_Loop_Text_Even_Loop		
	STA	WSYNC			; 3
	STA	HMOVE			; 3 (6)

***	sleep 	64
	LDA	JinJang_Col_01R,y	; 4 
	STA	PF2			; 3 (13)

	LDA	JinJang_ColorR,y	; 4
	STA	COLUPF			; 3 (20)

	LDA	(temp03),y		
	STA	GRP0			; 8 (28)
	
	LDA	(temp07),y		
	STA	GRP1			; 8 (36)

	sleep	2
	LDA	JinJang_Col_02R,y	; 4 (42)

******	sleep	23
	sleep	3
	STA	PF2			; 3 (48)
	LDA	(temp11),y		; 5 (53)

	STA	GRP0			; 3 (56)

	sleep	10

	LDA	#$00			; 2 (68)
	STA	HMP0			; 3 
	STA	HMP1			; 3 (76)

Bank2_DrawLogo_Loop_Text_Even_SecondLine
	STA	HMOVE			; 3 (2)

	LDA	JinJang_Col_01R,y	; 4 
	STA	PF2			; 3 (9)

	LDA	(temp01),y		
	STA	GRP0			; 8 (15)

	LDA	(temp05),y		
	STA	GRP1			; 8 (23)

	LAX	JinJang_Col_02R,y	; 4 (27)

	sleep	13

	LDA	(temp09),y		; 5 (45)
	STX	PF2			; 3 (48)
	STA	GRP0			; 3 (51)

	LDA	#$80			; 2 (53)
	STA	HMP0			; 3 
	STA	HMP1			; 3 (59)
	
	DEY				; 2 (61)
	BPL	Bank2_DrawLogo_Loop_Text_Even_Loop	; 2
	JMP	Bank2_DrawLogo_Loop_Text_Ended

	_align	120
Bank2_DrawLogo_Loop_Text_Odd_Start
*
*	Currently at cycle 18
*	
	LDA	#$00
	STA	HMP0 
	STA	HMP1	; 7

	_sleep 	46
	sleep	2

Bank2_DrawLogo_Loop_Text_Odd_Loop
	STA	HMOVE			; 3 (2)

	LDA	JinJang_Col_01R,y	; 4 
	STA	PF2			; 3 (9)

	LDA	JinJang_ColorR,y	; 4
	STA	COLUPF			; 3 (16)

	LDA	(temp01),y		
	STA	GRP0			; 8 (24)

	LDA	(temp05),y		
	STA	GRP1			; 8 (32)

	sleep	6

	LAX	JinJang_Col_02R,y	; 4 (42)
	LDA	(temp09),y		; 4 (46)

	STX	PF2			; 3 (49)
	STA	GRP0			; 8 (55)


	LDA	#$80			; 2
	STA	HMP0			; 3
	STA	HMP1			; 3 (63)
Bank2_DrawLogo_Loop_Text_Odd_SecondLine
	STA	WSYNC			; 3 (76)
	STA	HMOVE			; 6 

	LDA	JinJang_Col_01R,y	; 4 
	STA	PF2			; 3 (13)

***	sleep	57

	LDA	(temp03),y		
	STA	GRP0			; 8 (21)
	
	LDA	(temp07),y		
	STA	GRP1			; 8 (29)

	LDA	JinJang_Col_02R,y	; 4 (33)
	sleep	12
	STA	PF2			; 3 (48)
	LDA	(temp11),y		; 5 (53)

	STA	GRP0			; 8 (61)

	sleep	2


	LDA	#$00			
	STA	HMP0			
	STA	HMP1			; 7 (70)

	DEY						; 2 (72)
	BPL	Bank2_DrawLogo_Loop_Text_Odd_Loop	; 2 (74)

Bank2_DrawLogo_Loop_Text_Ended

	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUBK	
	STA	COLUP0
	STA	COLUP1	
	STA	COLUPF	
	STA	HMCLR
	STA	PF2
	STA	GRP0
	STA	GRP1

	LDX	#4
Bank2_Blank_Lines2
	STA	WSYNC
	DEX
	BPL	Bank2_Blank_Lines2

	LDA	#255
	STA	temp19
	JSR	Bank2_Decrementing_RainbowLine

Bank2_Draw_ScrollingText

	LDX	#7
Bank2_Draw_ScrollingText_Loop2
	LDY	#1
Bank2_Draw_ScrollingText_Loop
	STA	WSYNC			; 76
	LDA	ScrollingColumn1,x	; 4
	STA	PF1			; 3 (7)
	LDA	ScrollingColumn2,x	; 4 (11)
	STA	PF2			; 3 (14)

	LDA	JingJang_Color_Adder,x  ; 4 (18)
	CLC				; 2 (20)
	ADC	counter			; 3 (23)
	STA	COLUPF			; 3 (26)

	sleep	15
	LDA	ScrollingColumn3,x	; 4 (46)
	STA	PF2			; 3 (49)
	LDA	ScrollingColumn4,x	; 4 (55)
	STA	PF1			; 3 (58)
	DEY
	BPL	Bank2_Draw_ScrollingText_Loop
	DEX
	BPL	Bank2_Draw_ScrollingText_Loop2

Bank2_Draw_ScrollingText_Ended
	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUPF	
	STA	PF1
	STA	PF2

	LDA	#255
	STA	temp19
	JSR	Bank2_Incrementing_RainbowLine

	LDX	#7
Bank2_Wasting_More_Lines
	STA	WSYNC
	DEX
	BPL	Bank2_Wasting_More_Lines

Bank2_High_Score_Text
*
*	temp01: P0-1-1 pointer	
*	temp03: P0-1-2 pointer	
*	temp05: P1-1   pointer
*	temp07: P1-2   pointer
*	temp09: P0-2-1 pointer
*	temp11: P0-2-2 pointer
*	temp13: FG     pointer
*	temp15: BG     pointer
*

	LDA	#<Bank2_High_Score_Text_00
	STA	temp01
	LDA	#>Bank2_High_Score_Text_00
	STA	temp02

	LDA	#<Bank2_High_Score_Text_01
	STA	temp03
	LDA	#>Bank2_High_Score_Text_01
	STA	temp04

	LDA	#<Bank2_High_Score_Text_02
	STA	temp05
	LDA	#>Bank2_High_Score_Text_02
	STA	temp06

	LDA	#<Bank2_High_Score_Text_03
	STA	temp07
	LDA	#>Bank2_High_Score_Text_03
	STA	temp08

	LDA	#<Bank2_High_Score_Text_04
	STA	temp09
	LDA	#>Bank2_High_Score_Text_04
	STA	temp10

	LDA	#<Bank2_High_Score_Text_05
	STA	temp11
	LDA	#>Bank2_High_Score_Text_05
	STA	temp12


	LDA	counter
	ASL
	STA	temp19
	LSR
	LSR	
	LSR
	AND	#%00000111
	CLC
	BIT	temp19
	BVC	Bank2_High_Score_FG_NoInvert
	EOR	#%00000111
Bank2_High_Score_FG_NoInvert
	ADC	#<Bank2_High_Score_FG_Normal
	STA	temp13
	LDA	#>Bank2_High_Score_FG_Normal
	STA	temp14 				; 10 (15)


	LDA	#<Bank2_Press_Fire_Colors_BG_Normal
	STA	temp15
	LDA	#>Bank2_Press_Fire_Colors_BG_Normal
	STA	temp16				; 10 (25)

	STA	WSYNC
	_sleep	26
	sleep	2

	LDA	#255
	STA	PF2
	STA	PF1

	STA	RESP0				; 3 (31)
	sleep	3
	STA	RESP1				; 3 (36)

	LDA	#$E0
	STA	HMP0
	LDA	#$00
	STA	HMP1
	STA	WSYNC
	STA	HMOVE

	LDY	#4
	LDA	#255
	STA	temp19

	STA	WSYNC
	STA	HMOVE		; 3

	LDA	#$00
	STA	HMP0
	STA	HMP1		; 8 (11)

	JSR	Bank2_48px_Text_Routine

Bank2_Prepare_And_Jump_To_DynamicText
*	temp05		: Letter01
*	temp01		: Letter02
*	temp02		: Letter03
*	temp09		: Letter04
*	temp10		: Letter05
*	temp06		: Letter06
*	temp07		: Letter07
*	temp03		: Letter08
*	temp04		: Letter09
*	temp11		: Letter10
*	temp12		: Letter11
*	temp08		: Letter12
*			
*	temp18		: Text Color
*	temp17		: AND


	LDA	counter
	CMP	#240
	BCS	Bank2_DText_Has_Better_Colors	
	LDA	#$16
	STA	temp18
	sleep	6

	JMP	Bank2_DText_Was_Flat
Bank2_DText_Has_Better_Colors
	AND	#$0F
	LSR
	TAX
	LDA	Bank2_Dynamic_Text_Glow,x
	STA	temp18
	
Bank2_Press_Fire_Colors_FG_Selected

Bank2_DText_Was_Flat

	LDA	HScore_1
	AND	#$0F
	STA	temp05

	LDA	HScore_1
	LSR
	LSR
	LSR
	LSR
	STA	temp01

	LDA	HScore_2
	AND	#$0F
	STA	temp02

	LDA	HScore_2
	LSR
	LSR
	LSR
	LSR
	STA	temp09

	LDA	HScore_3
	AND	#$0F
	STA	temp10

	LDA	HScore_3
	LSR
	LSR
	LSR
	LSR
	STA	temp06

	LDA	HScore_4
	AND	#$0F
	STA	temp07

	LDA	HScore_4
	LSR
	LSR
	LSR
	LSR
	STA	temp03

	LDA	HScore_5
	AND	#$0F
	STA	temp04

	LDA	HScore_5
	LSR
	LSR
	LSR
	LSR
	STA	temp11

	LDA	HScore_6
	AND	#$0F
	STA	temp12

	LDA	HScore_6
	LSR
	LSR
	LSR
	LSR
	STA	temp08

	JSR	Bank2_Call_DynamicText

	LDX	#7
Bank2_Wasting_More_Lines2
	STA	WSYNC
	DEX
	BPL	Bank2_Wasting_More_Lines2

Bank2_Press_Start_Text
*
*	temp01: P0-1-1 pointer	
*	temp03: P0-1-2 pointer	
*	temp05: P1-1   pointer
*	temp07: P1-2   pointer
*	temp09: P0-2-1 pointer
*	temp11: P0-2-2 pointer
*	temp13: FG     pointer
*	temp15: BG     pointer
*

	LDA	#$02			
	STA	NUSIZ0			
	LDA	#00
	STA	NUSIZ1			; 10

	LDA	PressedDelay
	AND	#%00100000
	CMP	#%00100000
	BEQ	Bank2_Press_Start_Text_Visible

	LDA	#<Bank2_Press_Fire_Empty
	STA	temp01
	STA	temp03
	STA	temp05
	STA	temp07
	STA	temp09
	STA	temp11

	LDA	#>Bank2_Press_Fire_Empty
	STA	temp02
	STA	temp04
	STA	temp06
	STA	temp08
	STA	temp10
	STA	temp12
	
	; 40

	_sleep	14
	sleep	3

	JMP	Bank2_Text_Press_Start_Was_Visible

Bank2_Press_Start_Text_Visible
	LDA	#<Bank2_Press_Fire_00
	STA	temp01
	LDA	#>Bank2_Press_Fire_00
	STA	temp02

	LDA	#<Bank2_Press_Fire_01
	STA	temp03
	LDA	#>Bank2_Press_Fire_01
	STA	temp04

	LDA	#<Bank2_Press_Fire_02
	STA	temp05
	LDA	#>Bank2_Press_Fire_02
	STA	temp06

	LDA	#<Bank2_Press_Fire_03
	STA	temp07
	LDA	#>Bank2_Press_Fire_03
	STA	temp08

	LDA	#<Bank2_Press_Fire_04
	STA	temp09
	LDA	#>Bank2_Press_Fire_04
	STA	temp10

	LDA	#<Bank2_Press_Fire_05
	STA	temp11
	LDA	#>Bank2_Press_Fire_05
	STA	temp12

	; 60
Bank2_Text_Press_Start_Was_Visible
	STA	WSYNC		; 76

	BIT	PressedDelay			; 3
	BMI	Bank2_Press_Start_Text_With_SelectedColors  ; 2 (5)

	LDA	#<Bank2_Press_Fire_Colors_FG_Normal 
	STA	temp13
	LDA	#>Bank2_Press_Fire_Colors_FG_Normal
	STA	temp14 				; 10 (15)

	LDA	#<Bank2_Press_Fire_Colors_BG_Normal
	STA	temp15
	LDA	#>Bank2_Press_Fire_Colors_BG_Normal
	STA	temp16				; 10 (25)

	JMP	Bank2_Press_Start_Text_wasNotSelected	; 3 (28)

Bank2_Press_Start_Text_With_SelectedColors

	LDA	#<Bank2_Press_Fire_Colors_FG_Selected
	STA	temp13
	LDA	#>Bank2_Press_Fire_Colors_FG_Selected
	STA	temp14

	LDA	#<Bank2_Press_Fire_Colors_BG_Selected
	STA	temp15
	LDA	#>Bank2_Press_Fire_Colors_BG_Selected
	STA	temp16				; (25)

	sleep	3
Bank2_Press_Start_Text_wasNotSelected
	STA	WSYNC
	_sleep	22
	sleep	2

	LDA	#255
	STA	PF2
	STA	PF1

	STA	RESP0				; 3 (31)
	sleep	3
	STA	RESP1				; 3 (36)

	LDA	#$E0
	STA	HMP0
	LDA	#$00
	STA	HMP1
	STA	WSYNC
	STA	HMOVE

	LDY	#4
	LDA	#255
	STA	temp19

	STA	WSYNC
	STA	HMOVE		; 3

	LDA	#$00
	STA	HMP0
	STA	HMP1		; 8 (11)

	JSR	Bank2_48px_Text_Routine


	ldx	stack
	txs
	JMP	OverScanBank2


*Data Section 
*----------------------------------
* Here goes the data used by
* custom ScreenTop and ScreenBottom
* elments.
*

	_align 16
Touhou_Letter_Adder
	BYTE	#8
	BYTE	#7
	BYTE	#6
	BYTE	#5
	BYTE	#4
	BYTE	#5
	BYTE	#6
	BYTE	#7
	BYTE	#8
	BYTE	#9
	BYTE	#10
	BYTE	#11
	BYTE	#12
	BYTE	#11
	BYTE	#10
	BYTE	#9

	_align 8
JingJang_Color_Adder
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$06
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00

	_align	4
JingJang_00_LookUp
	BYTE #<JinJang_1_00
	BYTE #<JinJang_2_00
	BYTE #<JinJang_3_00
	BYTE #<JinJang_4_00

	_align	4
JingJang_01_LookUp
	BYTE #<JinJang_1_01
	BYTE #<JinJang_2_01
	BYTE #<JinJang_3_01
	BYTE #<JinJang_4_01

	_align	32

JinJang_Colors_32
	BYTE $02
	BYTE $04
	BYTE $06
	BYTE $06
	BYTE $04
	BYTE $02
	BYTE $02
	BYTE $04
	BYTE $06
	BYTE $06
	BYTE $04
	BYTE $04
	BYTE $02
	BYTE $02
	BYTE $04
	BYTE $06
	BYTE $06
	BYTE $04
	BYTE $02
	BYTE $02
	BYTE $04
	BYTE $06
	BYTE $06
	BYTE $04
	BYTE $04
	BYTE $02
	BYTE $02
	BYTE $04
	BYTE $06
	BYTE $06
	BYTE $04
	BYTE $02

	_align	64

JinJang_1_00
	BYTE %11100000
	BYTE %00011000
	BYTE %11110100
	BYTE %01111010
	BYTE %01111010
	BYTE %11111101
	BYTE %11111101
	BYTE %11111101
	BYTE %00111101
	BYTE %00011101
	BYTE %00001101
	BYTE %10001010
	BYTE %10001010
	BYTE %00000100
	BYTE %00011000
	BYTE %11100000
JinJang_2_00
	BYTE %11100000
	BYTE %00011000
	BYTE %11100100
	BYTE %11111010
	BYTE %11000010
	BYTE %10000001
	BYTE %00000001
	BYTE %00011001
	BYTE %00011001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000010
	BYTE %00000010
	BYTE %00000100
	BYTE %00011000
	BYTE %11100000
JinJang_3_00
	BYTE %11100000
	BYTE %00011000
	BYTE %00000100
	BYTE %10000010
	BYTE %10000010
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %11000001
	BYTE %11100001
	BYTE %11110001
	BYTE %01110010
	BYTE %01110010
	BYTE %11100100
	BYTE %00011000
	BYTE %11100000
JinJang_4_00
	BYTE %11100000
	BYTE %00011000
	BYTE %00000100
	BYTE %00000010
	BYTE %00111010
	BYTE %01111101
	BYTE %11111101
	BYTE %11100101
	BYTE %11100101
	BYTE %11111101
	BYTE %11111101
	BYTE %11111110
	BYTE %11111010
	BYTE %11100100
	BYTE %00011000
	BYTE %11100000

	_align	64

JinJang_1_01
	BYTE %11100000
	BYTE %00011000
	BYTE %11100100
	BYTE %01110010
	BYTE %01110010
	BYTE %11110001
	BYTE %11100001
	BYTE %11000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %10000010
	BYTE %10000010
	BYTE %00000100
	BYTE %00011000
	BYTE %11100000
JinJang_2_01
	BYTE %11100000
	BYTE %00011000
	BYTE %11100100
	BYTE %11111010
	BYTE %11111110
	BYTE %11111101
	BYTE %11111101
	BYTE %11100101
	BYTE %11100101
	BYTE %11111101
	BYTE %01111101
	BYTE %00111010
	BYTE %00000010
	BYTE %00000100
	BYTE %00011000
	BYTE %11100000
JinJang_3_01
	BYTE %11100000
	BYTE %00011000
	BYTE %00000100
	BYTE %10001010
	BYTE %10001010
	BYTE %00001101
	BYTE %00011101
	BYTE %00111101
	BYTE %11111101
	BYTE %11111101
	BYTE %11111101
	BYTE %01111010
	BYTE %01111010
	BYTE %11110100
	BYTE %00011000
	BYTE %11100000
JinJang_4_01
	BYTE %11100000
	BYTE %00011000
	BYTE %00000100
	BYTE %00000010
	BYTE %00000010
	BYTE %00000001
	BYTE %00000001
	BYTE %00011001
	BYTE %00011001
	BYTE %00000001
	BYTE %10000001
	BYTE %11000010
	BYTE %11111010
	BYTE %11100100
	BYTE %00011000
	BYTE %11100000

*
*	Extra blanks added so the title can move up and down by 16.
*

	_align 16
Touhou_Title_Color
	BYTE	#$12
	BYTE	#$14
	BYTE	#$16
	BYTE	#$18
	BYTE	#$1A
	BYTE	#$1C
	BYTE	#$1E
	BYTE	#$0E
	BYTE	#$1E
	BYTE	#$1C
	BYTE	#$1A
	BYTE	#$18
	BYTE	#$16
	BYTE	#$14
	BYTE	#$12

	_align	208

Touhou_Title__E00
JingJang_First_HMOVE
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

Touhou_Title__00
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00111000
	BYTE %00010000
	BYTE %00111000
	BYTE %00010000
	BYTE %00010000
	BYTE %10010010
	BYTE %11111110

Touhou_Title__E01
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

Touhou_Title__01
	BYTE %11111110
	BYTE %01000010
	BYTE %00110000
	BYTE %00011000
	BYTE %00000100
	BYTE %10000010
	BYTE %01000100
	BYTE %00111000
	BYTE %00000000
	BYTE %00111000
	BYTE %01000100
	BYTE %10000110
	BYTE %10111010
	BYTE %11000010
	BYTE %01000100
	BYTE %00111000

Touhou_Title__E02
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

Touhou_Title__02
	BYTE %00111000
	BYTE %01000100
	BYTE %11000010
	BYTE %11100010
	BYTE %10111100
	BYTE %10000000
	BYTE %01000010
	BYTE %00111100
	BYTE %00000000
	BYTE %01111100
	BYTE %11000110
	BYTE %10000010
	BYTE %11000010
	BYTE %10000010
	BYTE %10000110
	BYTE %10000010

Touhou_Title__E03
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

Touhou_Title__03
	BYTE %00111100
	BYTE %11000110
	BYTE %10000010
	BYTE %10000010
	BYTE %10000010
	BYTE %10000010
	BYTE %11000110
	BYTE %01111000
	BYTE %00000000
	BYTE %11000110
	BYTE %10000010
	BYTE %10000010
	BYTE %11111110
	BYTE %10000010
	BYTE %10000010
	BYTE %11000110

Touhou_Title__E04
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

Touhou_Title__04
	BYTE %00111100
	BYTE %11000110
	BYTE %10000010
	BYTE %10000010
	BYTE %10000010
	BYTE %10000010
	BYTE %11000110
	BYTE %01111000
	BYTE %00000000
	BYTE %00111000
	BYTE %01000100
	BYTE %10000110
	BYTE %10111010
	BYTE %11000010
	BYTE %01000100
	BYTE %00111000

Touhou_Title__E05
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

Touhou_Title__05
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %01111100
	BYTE %11000110
	BYTE %10000010
	BYTE %11000010
	BYTE %10000010
	BYTE %10000110
	BYTE %10000010

Touhou_Title__E06
Bank2_Press_Fire_Empty
Bank2_Press_Fire_Colors_BG_Normal
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	2
Bank2_Press_Fire_Speed
	BYTE %00000111
	BYTE %00111111

	_align	150
Impure_Soul_Eclipse
	BYTE %10000001
	BYTE %10100001
	BYTE %11111111
	BYTE %10010001
	BYTE %10000001
	BYTE %00000000
	BYTE %00000000
	BYTE %11111111
	BYTE %00100001	
	BYTE %00000010	; 10
	BYTE %00001100
	BYTE %00000010
	BYTE %00010001
	BYTE %11111111
	BYTE %00000000
	BYTE %11111111
	BYTE %00010001
	BYTE %00011001
	BYTE %00010011
	BYTE %00010001	; 20
	BYTE %00001010
	BYTE %00000100
	BYTE %00000000
	BYTE %01111111
	BYTE %10100000
	BYTE %10100000
	BYTE %10000000
	BYTE %10001000
	BYTE %10001000
	BYTE %01111111	; 30
	BYTE %00000000
	BYTE %11111111
	BYTE %00010001
	BYTE %00011001
	BYTE %01110011
	BYTE %11010001
	BYTE %10001010
	BYTE %00000100
	BYTE %00000000
	BYTE %11111111	; 40
	BYTE %10001001
	BYTE %10011001
	BYTE %10001101
	BYTE %10000001
	BYTE %11000011
	BYTE %10000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	; 50
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %01100110
	BYTE %10001001
	BYTE %10001001
	BYTE %10011101
	BYTE %10110001	; 60
	BYTE %10010001
	BYTE %01100110
	BYTE %00000000
	BYTE %00111100
	BYTE %01010010
	BYTE %10010001
	BYTE %10011001
	BYTE %10001001
	BYTE %01001010
	BYTE %00111100	; 70
	BYTE %00000000
	BYTE %01111111
	BYTE %10100000
	BYTE %10100000
	BYTE %10000000
	BYTE %10001000
	BYTE %10001000
	BYTE %01111111
	BYTE %00000000
	BYTE %11111111	; 80
	BYTE %10000100
	BYTE %10000000
	BYTE %10000000
	BYTE %11000000
	BYTE %10000000
	BYTE %10000000
	BYTE %00000000
Bank2_LevelText_5
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	; 90
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %11111111
	BYTE %10001001
	BYTE %10011001
	BYTE %10001101
	BYTE %10000001	; 100
	BYTE %11000011
	BYTE %10000001
	BYTE %00000000
	BYTE %00111100
	BYTE %01010010
	BYTE %10010001
	BYTE %10000001
	BYTE %10000001
	BYTE %10000001
	BYTE %01000010	; 110
	BYTE %00000000
	BYTE %11111111
	BYTE %10000100
	BYTE %10000000
	BYTE %10000000
	BYTE %11000000
	BYTE %10000000
	BYTE %10000000
	BYTE %00000000
	BYTE %00000000	; 120
	BYTE %10000001
	BYTE %10100001
	BYTE %11111111
	BYTE %10010001
	BYTE %10000001
	BYTE %00000000
	BYTE %00000000
	BYTE %11111111
	BYTE %00010001
	BYTE %00011001	; 130
	BYTE %00010011
	BYTE %00010001
	BYTE %00001010
	BYTE %00000100
	BYTE %00000000
	BYTE %01100110
	BYTE %10001001
	BYTE %10001001
	BYTE %10011101
	BYTE %10110001	; 140
	BYTE %10010001
	BYTE %01100110
	BYTE %00000000
	BYTE %11111111
	BYTE %10001001
	BYTE %10011001
	BYTE %10001101
	BYTE %10000001
	BYTE %11000011
	BYTE %10000001	; 150

	_align 5

Bank2_Press_Fire_00
	BYTE	%10101000
	BYTE	%00001000
	BYTE	%10101100
	BYTE	%10101010
	BYTE	%10101100

	_align 5

Bank2_Press_Fire_01
	BYTE	%10101110
	BYTE	%10101000
	BYTE	%11001100
	BYTE	%10101000
	BYTE	%11001110

	_align 5

Bank2_Press_Fire_02
	BYTE	%11001100
	BYTE	%00100010
	BYTE	%01000100
	BYTE	%10001000
	BYTE	%01100110

	_align 5

Bank2_Press_Fire_03
	BYTE	%00000100
	BYTE	%00000100
	BYTE	%11110110
	BYTE	%00000100
	BYTE	%00000111

	_align 5

Bank2_Press_Fire_04
	BYTE	%01110101
	BYTE	%00100101
	BYTE	%00100110
	BYTE	%00100101
	BYTE	%01110110

	_align 5

Bank2_Press_Fire_05
	BYTE	%01110101
	BYTE	%01000000
	BYTE	%01100101
	BYTE	%01000101
	BYTE	%01110101

	_align 5

Bank2_Press_Fire_Colors_BG_Selected
	BYTE	$42
	BYTE	$44
	BYTE	$46
	BYTE	$44
	BYTE	$42

	_align 5

Bank2_Press_Fire_Colors_FG_Normal
	BYTE	$0A
	BYTE	$0C
	BYTE	$0E
	BYTE	$0C
	BYTE	$0A

	_align 5

Bank2_Press_Fire_Colors_FG_Selected
	BYTE	$1A
	BYTE	$1C
	BYTE	$1E
	BYTE	$1C
	BYTE	$1A

	_align	5
Bank2_High_Score_Text_00
	BYTE	#%00000101
	BYTE	#%00000101
 	BYTE	#%00000111
 	BYTE	#%00000101
 	BYTE	#%00000101

	_align	5
Bank2_High_Score_Text_01
 	BYTE	#%01001100
 	BYTE	#%01010010
 	BYTE	#%01010110
 	BYTE	#%01010000
 	BYTE	#%01001110

	_align	5
Bank2_High_Score_Text_02
 	BYTE	#%10100011
 	BYTE	#%10100000
 	BYTE	#%11100001
 	BYTE	#%10100010
 	BYTE	#%10100001

	_align	5
Bank2_High_Score_Text_03
 	BYTE	#%00011001
 	BYTE	#%10100010
 	BYTE	#%00100010
 	BYTE	#%00100010
 	BYTE	#%10011001

	_align	5
Bank2_High_Score_Text_04
 	BYTE	#%00101011
 	BYTE	#%10101010
 	BYTE	#%10110011
 	BYTE	#%10101010
 	BYTE	#%00110011

	_align	5
Bank2_High_Score_Text_05
 	BYTE	#%10000000
 	BYTE	#%00100000
 	BYTE	#%00000000
 	BYTE	#%00100000
 	BYTE	#%10000000

	_align 13

Bank2_High_Score_FG_Normal
	BYTE	$4A
	BYTE	$4C
	BYTE	$4E
	BYTE	$3C
	BYTE	$1A
	BYTE	$1C
	BYTE	$1C
	BYTE	$1A
	BYTE	$3C
	BYTE	$4E
	BYTE	$4E
	BYTE	$4C
	BYTE	$4A

	_align	8
Bank2_Dynamic_Text_Glow
	BYTE	#$18
	BYTE	#$1A
	BYTE	#$1C
	BYTE	#$1E
	BYTE	#$1E
	BYTE	#$1C
	BYTE	#$1A
	BYTE	#$18	

	_align	6

Bank2_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1

	_align	5

Bank2_LevelText_1
	BYTE #%01110011
	BYTE #%01000010
	BYTE #%01000011
	BYTE #%01000010
	BYTE #%01000011

	_align	5

Bank2_LevelText_2
	BYTE #%10001000
	BYTE #%00010100
	BYTE #%00010100
	BYTE #%00010100
	BYTE #%10010100

	_align	5

Bank2_LevelText_3
	BYTE #%11100111
	BYTE #%10000100
	BYTE #%11000100
	BYTE #%10000100
	BYTE #%11100100

	_align	5

Bank2_LevelText_4
	BYTE #%00000000
	BYTE #%00010000
	BYTE #%00000000
	BYTE #%00010000
	BYTE #%00000000


	_align	5
Bank2_Number1
	BYTE #%00001000
	BYTE #%00001000
	BYTE #%00101000
	BYTE #%00011000
	BYTE #%00001000

	_align	5
Bank2_Number2
	BYTE #%00111100
	BYTE #%00010000
	BYTE #%00001000
	BYTE #%00100100
	BYTE #%00011000

	_align	5
Bank2_Number3
	BYTE #%00011000
	BYTE #%00100100
	BYTE #%00001000
	BYTE #%00100100
	BYTE #%00011000

	_align	5
Bank2_Number4
	BYTE #%00001000
	BYTE #%00111100
	BYTE #%00101000
	BYTE #%00010000
	BYTE #%00001000

	_align	5
Bank2_Number5
	BYTE #%00110000
	BYTE #%00001000
	BYTE #%00110000
	BYTE #%00100000
	BYTE #%00111000

	_align	5
Bank2_Number6
	BYTE #%00011000
	BYTE #%00100100
	BYTE #%00111000
	BYTE #%00100000
	BYTE #%00011100

	_align	2
Bank2_From3_48Px_HMove
	BYTE #$00
	BYTE #$A0

	_align	12
Bank2_LevelNumberPointers
	BYTE #<Bank2_Number1
	BYTE #>Bank2_Number1
	BYTE #<Bank2_Number2
	BYTE #>Bank2_Number2
	BYTE #<Bank2_Number3
	BYTE #>Bank2_Number3
	BYTE #<Bank2_Number4
	BYTE #>Bank2_Number4
	BYTE #<Bank2_Number5
	BYTE #>Bank2_Number5
	BYTE #<Bank2_Number6
	BYTE #>Bank2_Number6


*Routine Section
*---------------------------------
* This is were the routines are
* used by the developer.
*

Bank2_48px_Text_Routine_For3

	LDA	LevelAndCharge
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	SEC	
	SBC	#1
	ASL
	TAX
	
	
	LDA	Bank2_LevelNumberPointers,x
	STA	temp11
	LDA	Bank2_LevelNumberPointers+1,x
	STA	temp12

	LDA	counter
	AND	#1
	TAX
	LDA	Bank2_From3_48Px_HMove,x
	STA	HMP0
	
	LDA	Bank2_From3_48Px_HMove,x
	STA	HMP1

	STA	WSYNC
	STA	HMOVE		; 3

	LDA	#$00
	STA	HMP0
	STA	HMP1		; 8 (11)

Bank2_48px_Text_Routine
	LDA	counter		; 3 (14)
	AND	#1		; 2 (16)
	CMP	#1
	BEQ	Bank2_48px_Text_Odd_Start	; 2 (18)
	JMP	Bank2_48px_Text_Even_Start

	_align	105
Bank2_48px_Text_Even_Start
	LDA	#$80
	STA	HMP0
	STA	HMP1		; 8 

Bank2_48px_Text_Even_Loop
	STA	WSYNC
	STA	HMOVE		; 3 

****	sleep	63

	LDA	(temp15),y	; 5 (8)
	STA	COLUPF		; 3 (11)

	LDA	(temp13),y	; 5 (16)
	STA	COLUP0		; 3 (19)
	STA	COLUP1		; 3 (21)

	LDA	(temp03),y	; 5 (26)
	STA	GRP0		; 3 (29)

	LDA	(temp07),y	; 5 (34)
	STA	GRP1		; 3 (37)	

	LDA	(temp11),y	; 5 (42)
	sleep	4
	STA	GRP0		; 3 (47)

	sleep	12

	LDA	#0	
	STA	HMP0
	STA	HMP1		; 8 (11)

Bank2_48px_Text_Even_SecondLine
	STA	HMOVE		; 3 (2)	

	LDA	(temp01),y	; 5 (7)
	STA	GRP0		; 3 (10)

	LDA	(temp05),y	; 5 (15)
	STA	GRP1		; 3 (18)	

	LDA	(temp09),y	; 5 (23)
	sleep	24

	STA	GRP0		; 3 (46)

	LDA	#$80
	STA	HMP0
	STA	HMP1		; 8 

	DEY			; 2 (10)
	BPL	Bank2_48px_Text_Even_Loop
	JMP	Bank2_48px_Text_Ended	

	_align	90
Bank2_48px_Text_Odd_Start
	_sleep	18

	LDA	temp19
	CMP	#255
	BEQ	Bank2_48px_Text_Odd_Skip

	sleep	3
Bank2_48px_Text_Odd_Skip
	sleep	6

	LDA	#$00
	STA	HMP0
	STA	HMP1		; 8 (74)

Bank2_48px_Text_Odd_Loop
	STA	HMOVE		; (1)
	
	LDA	(temp15),y	; 5 (6)
	STA	COLUPF		; 3 (9)

	LDA	(temp13),y	; 5 (14)
	STA	COLUP0		; 3 (17)
	STA	COLUP1		; 3 (20)

	LDA	(temp01),y	; 5 (25)
	STA	GRP0		; 3 (28)

	LDA	(temp05),y	; 5 (33)
	STA	GRP1		; 3 (36)	

	LDA	(temp09),y	; 5 (41)
	sleep	8
	STA	GRP0		; 3 (46)

	LDA	#$80
	STA	HMP0
	STA	HMP1		; 8 

Bank2_48px_Text_Odd_SecondLine
	STA	WSYNC
	STA	HMOVE		; 3 

	LDA	(temp03),y	; 5 (8)
	STA	GRP0		; 3 (11)

	LDA	(temp07),y	; 5 (16)
	STA	GRP1		; 3 (19)	

	LDA	(temp11),y	; 5 (24)
	sleep	21
	STA	GRP0		; 3 (46)

*****	sleep	57
	sleep	8

	LDA	#$00
	STA	HMP0
	STA	HMP1		; 8 (70)

	DEY			; 2 (72)
	BPL	Bank2_48px_Text_Odd_Loop ; 2 (74)


Bank2_48px_Text_Ended
	LDA	#0
	STA	WSYNC
	STA	HMCLR
	STA	COLUBK
	STA	PF1
	STA	PF2
	STA	GRP0
	STA	GRP1

	JMP	Bank2_Jump_Back_To_Any

Bank2_Decrementing_RainbowLine
	LDX	#1
Bank2_Decrementing_RainbowLine_Loop
	LDY	counter
	STA	WSYNC
	STY	COLUBK
	LDA	#255
	STA	PF0	

	sleep	6

	DEY
	DEY 	
	STY	COLUBK

	DEY
	DEY 	
	STY	COLUBK

	DEY
	DEY 	
	STY	COLUBK

	DEY
	DEY 	
	STY	COLUBK

	DEY
	DEY 	
	STY	COLUBK

	DEY
	DEY 	
	STY	COLUBK

	DEY
	DEY 	
	STY	COLUBK

	LDA	#0
	sleep	3
	STA	COLUBK
	DEX
	BPL 	Bank2_Decrementing_RainbowLine_Loop
	STA	PF0
	
	JMP	Bank2_Jump_Back_To_Any

Bank2_Incrementing_RainbowLine
	LDX	#1
Bank2_Incrementing_RainbowLine_Loop
	LDY	counter
	STA	WSYNC
	STY	COLUBK
	LDA	#255
	STA	PF0	

	sleep	6

	INY
	INY 	
	STY	COLUBK

	INY
	INY 	
	STY	COLUBK

	INY
	INY 	
	STY	COLUBK

	INY
	INY 	
	STY	COLUBK

	INY
	INY 	
	STY	COLUBK

	INY
	INY 	
	STY	COLUBK

	INY
	INY 	
	STY	COLUBK

	LDA	#0
	sleep	3
	STA	COLUBK
	DEX
	BPL 	Bank2_Incrementing_RainbowLine_Loop
	STA	PF0
	JMP	Bank2_Jump_Back_To_Any

Bank2_Call_SoundPlayer
*
*	temp19 = (number of bank) - 1 
*
	LDA	#1
	STA	temp19

	lda	#>(Bank1_SoundPlayer-1)
   	pha
   	lda	#<(Bank1_SoundPlayer-1)
   	pha
   	pha
   	pha
   	ldx	#1
   	jmp	bankSwitchJump

Bank2_Call_DynamicText
*
*	temp19 = (number of bank) - 1 
*
	LDA	#1
	STA	temp19

	lda	#>(Bank8_DynamicText-1)
   	pha
   	lda	#<(Bank8_DynamicText-1)
   	pha
   	pha
   	pha
   	ldx	#8
   	jmp	bankSwitchJump

Bank2_Jump_Back_To_Any
	LDX	temp19
	CPX	#255
	BNE	Bank2_ReturnNoRTS
Bank2_Return
	RTS
Bank2_ReturnNoRTS

	TXA
	INX

	ASL		
	TAY

	LDA	Bank2_Return_JumpTable,y
   	pha
   	lda	Bank2_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump


###End-Bank2
	saveFreeBytes
	rewind 	2fd4
	
start_bank2
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address  
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 2ffc
   	.byte 	#<start_bank2
   	.byte 	#>start_bank2
   	.byte 	#<start_bank2
   	.byte 	#>start_bank2

***************************
********* Start of 3rd bank
***************************
	Bank 3
	fill	256
###Start-Bank3
*Enter Bank
*-----------------------------
*
* This is the section that happens
* everytime you go to a new screen.
* Should set the screen initialization
* here.
*


EnterScreenBank3

	LDA	#%01100000
	STA	temp18
	JSR	Bank3_Call_SoundPlayer

	LDA	counter
	EOR	random	
	STA	random

SpriteCounter = $E0
*
*	0-4: Counter
*	5-7: SpriteNum
*
	LDA	#0
	STA	SpriteCounter

	LDA	#%10111100
	STA	TextCounter

TextBuffer_W01 = $F000
TextBuffer_W02 = $F001
TextBuffer_W03 = $F002
TextBuffer_W04 = $F003
TextBuffer_W05 = $F004
TextBuffer_W06 = $F005
TextBuffer_W07 = $F006
TextBuffer_W08 = $F007
TextBuffer_W09 = $F008
TextBuffer_W10 = $F009
TextBuffer_W11 = $F00A
TextBuffer_W12 = $F00B

TextBuffer_R01 = $F080
TextBuffer_R02 = $F081
TextBuffer_R03 = $F082
TextBuffer_R04 = $F083
TextBuffer_R05 = $F084
TextBuffer_R06 = $F085
TextBuffer_R07 = $F086
TextBuffer_R08 = $F087
TextBuffer_R09 = $F088
TextBuffer_R10 = $F089
TextBuffer_R11 = $F08A
TextBuffer_R12 = $F08B

*Leave Bank
*-------------------------------
*
* This section goes as you leave
* the screen. Should set where to
* go and close or save things.
*

LeaveScreenBank3


*Overscan
*-----------------------------
*
* This is the place of the main
* code of this screen.
*

OverScanBank3

	CLC
        LDA	INTIM 
        BNE 	OverScanBank3

	STA	WSYNC
	LDA	#%11000010
	STA	VBLANK
	STA	WSYNC

    	LDA	#NTSC_Overscan
    	STA	TIM64T
	INC	counter

*Overscan Code
*-----------------------------
*
* This is where the game code
* begins.
*

	LDA	counter
	AND	#1
	CMP	#1
	BNE	Bank3_NoEnd

	LDA	SpriteCounter
	AND	#%00011111
	BNE 	Bank3_NoPlaySound

	LDA	#%00000011
	STA	temp18
	JSR	Bank3_Call_SoundPlayer
Bank3_NoPlaySound
	LDA	SpriteCounter
	AND	#%11100000

	STA	temp19
	
	LDA	SpriteCounter
	AND 	#%00011111
	CLC
	ADC	#1
	CMP	#%00100000
	BNE	Bank3_NoIncrementSprite
	LDA	temp19
	CMP	#%10100000
	BNE	Bank3_IncrementSprite
Bank3_Exit_To_Speak
	lda	#>(EnterScreenBank4-1)
   	pha
   	lda	#<(EnterScreenBank4-1)
   	pha
   	pha
   	pha
   	ldx	#4
   	jmp	bankSwitchJump

	JMP	Bank3_NoIncrementSpriteNOORA

Bank3_IncrementSprite
	CLC
	ADC	#%00100000
	JMP	Bank3_NoIncrementSpriteNOORA
Bank3_NoIncrementSprite
	ORA	temp19
Bank3_NoIncrementSpriteNOORA
	STA	SpriteCounter
	AND	#%11100000
	CMP	#%10100000
	BNE	Bank3_NoEnd
	JMP	Bank3_Exit_To_Speak

Bank3_NoEnd


*VSYNC
*----------------------------
* This is a fixed section in
* every bank. Don't need to be
* at the same space, of course.

WaitUntilOverScanTimerEndsBank3
	CLC
	LDA 	INTIM
	BMI 	WaitUntilOverScanTimerEndsBank3

* Sync the Screen
*

	LDA 	#2
	STA 	WSYNC  ; one line with VSYNC
	STA 	VSYNC	; enable VSYNC
	STA 	WSYNC 	; one line with VSYNC
	STA 	WSYNC 	; one line with VSYNC
	LDA 	#0
	STA 	WSYNC 	; one line with VSYNC
	STA 	VSYNC 	; turn off VSYNC

* Set the timer for VBlank
*
	STA	VBLANK
	STA 	WSYNC

	CLC
 	LDA	#NTSC_Vblank
	STA	TIM64T


*VBLANK
*-----------------------------
* This is were you can set a piece
* of code as well, but some part may
* be used by the kernel.
*
VBLANKBank3
	LDA	#0
	STA	temp18
	JSR	Bank3_Call_SoundPlayer


*SkipIfNoGameSet - VBLANK
*---------------------------------
*


VBlankEndBank3
	CLC
	LDA 	INTIM
	BMI 	VBlankEndBank3

    	LDA	#NTSC_Display
    	STA	TIM64T


*Screen
*--------------------------------  
* This is the section for the
* top part of the screen.
*

	tsx
	stx	stack

	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUPF		; 3 
*	STA	COLUP0		; 3 (6)
*	STA	COLUP1		
	STA	COLUBK			
	STA	PF0
	STA	PF1
	STA	PF2
	STA	GRP0
	STA	GRP1		; 15 (21)

Bank3_Bad_Apple_Do_it

	LDA	#$02
	STA	NUSIZ0
	LDA	#$00		; 2 (32)

	STA	COLUP0		;
***	STA	COLUP1		; 
	BYTE	#$8D
	BYTE	#COLUP1
	BYTE	#0

***	STA	RESP0
	BYTE	#$8D
	BYTE	#RESP0
	BYTE	#0

	STA	RESP1		; 9	
	LDY	#74

	LDA	#$02
	STA	NUSIZ1

	JSR	Bank3_SetPointers

	LDY	#73

	LDA	counter
*	LSR
*	LSR
*	LSR
*	LSR
*	LSR	
*	LSR

	AND	#1
	TAX

	LDA	#255
	STA	PF2

	LDA	#%00000101
	STA	CTRLPF

*	LDA	#$1e
*	CPX	#1
*	BNE	AAAAA
*	LDA	#$88
*AAAAA
*	STA	COLUP1

	LDA	Bank3_Bad_Apple_FirstHMOVE_P0,x
	STA	HMP0
	LDA	Bank3_Bad_Apple_FirstHMOVE_P1,x
	STA	HMP1		; 10 (48)

	STA	WSYNC		; 76
	STA	HMOVE

	CPX	#0
	BEQ	Bank3_Bad_Apple_Even_Start
	JMP	Bank3_Bad_Apple_Odd_Start

	_align	90

Bank3_Bad_Apple_Even_Start
	LDA	#$80
	STA	HMP0
	STA	HMP1

Bank3_Bad_Apple_Even_Loop
	STA	WSYNC
	STA	HMOVE	; 3

	LDA	(temp03),y
	STA	GRP0

	LDA	(temp07),y
	STA	GRP1		; 16

	LDA	temp17
	STA	COLUP0
	STA	COLUP1

	sleep	7

	LAX	(temp15),y
	LDA	(temp11),y
	STA	GRP0		
	STX	GRP1

	sleep	8


	LDA	#0
	STA	PF2
	STA	HMP0
	STA	HMP1	; 8 (74)

Bank3_Bad_Apple_Even_SecondLine
	STA	HMOVE 	; 1
	
	LDA	(temp01),y
	STA	GRP0

	LDA	(temp05),y
	STA	GRP1	
	sleep	18

	LAX	(temp13),y
	LDA	(temp09),y
	STA	GRP0		
	STX	GRP1

	LDA	#$80
	STA	HMP0
	STA	HMP1
	
	DEY
	BPL	Bank3_Bad_Apple_Even_Loop
	JMP	Bank3_Bad_Apple_End

	_align	120

Bank3_Bad_Apple_Odd_Start
	
	sleep	61

	LDA	#0
	STA	HMP0
	STA	HMP1	; 8 (74)

Bank3_Bad_Apple_Odd_Loop
	STA	HMOVE	; 1

	LDA	(temp01),y
	STA	GRP0

	LDA	(temp05),y
	STA	GRP1	

	LDA	temp17
	STA	COLUP0
	STA	COLUP1

	sleep	11

	LAX	(temp13),y
	LDA	(temp09),y
	STA	GRP0		
	STX	GRP1

	LDA	#0
	STA	PF2

	LDA	#$80
	STA	HMP0
	STA	HMP1

Bank3_Bad_Apple_Odd_SecondLine
	STA	WSYNC
	STA	HMOVE	; 3

	LDA	(temp03),y
	STA	GRP0

	LDA	(temp07),y
	STA	GRP1		; 16

	sleep	16

	LAX	(temp15),y
	LDA	(temp11),y
	STA	GRP0		
	STX	GRP1

	sleep	4

	LDA	#0
	STA	HMP0
	STA	HMP1	; 8 (70)
	
	DEY					; 2 (72)
	BPL	Bank3_Bad_Apple_Odd_Loop	; 74

Bank3_Bad_Apple_End
	LDA	#0
	STA	WSYNC
	STA	HMCLR
	STA	GRP0
	STA	GRP1
	STA	PF2
	STA	CTRLPF

Bank3_Another48Px
	STA	WSYNC

	LDA	#<Bank2_LevelText_1
	STA	temp01
	LDA	#>Bank2_LevelText_1
	STA	temp02

	LDA	#<Bank2_LevelText_2
	STA	temp03
	LDA	#>Bank2_LevelText_2
	STA	temp04

	LDA	#<Bank2_LevelText_3
	STA	temp05
	LDA	#>Bank2_LevelText_3
	STA	temp06

	LDA	#<Bank2_LevelText_4
	STA	temp07
	LDA	#>Bank2_LevelText_4
	STA	temp08

	LDA	#<Bank2_LevelText_5
	STA	temp09
	LDA	#>Bank2_LevelText_5
	STA	temp10

	LDA	#$02			
	STA	NUSIZ0			
	LDA	#00
	STA	NUSIZ1			

	LDA	#<Bank2_Press_Fire_Colors_FG_Selected
	STA	temp13
	LDA	#>Bank2_Press_Fire_Colors_FG_Selected
	STA	temp14 				

	LDA	#<Bank2_Press_Fire_Colors_BG_Normal
	STA	temp15
	LDA	#>Bank2_Press_Fire_Colors_BG_Normal
	STA	temp16				

	STA	WSYNC
	_sleep	24
	sleep	4

	LDA	#255
	STA	PF2
	STA	PF1

	STA	RESP0				; 3 (31)
	sleep	3
	STA	RESP1				; 3 (36)

	LDA	#$E0
	STA	HMP0
	LDA	#$00
	STA	HMP1
	STA	WSYNC
	STA	HMOVE

	LDY	#4

	LDA	#2
	STA	temp19
	JSR	Bank3_Call_48px

	JSR	Bank3_Call_DynamicText

	ldx	stack
	txs
	JMP	OverScanBank3



*Data Section 
*----------------------------------
* Here goes the data used by
* custom ScreenTop and ScreenBottom
* elments.
*

	_align	2
Bank3_Bad_Apple_FirstHMOVE_P0
	BYTE	#$00
	BYTE	#$70

	_align	2
Bank3_Bad_Apple_FirstHMOVE_P1
	BYTE	#$00
	BYTE	#$00

	_align	17
Bad_Apple_Light
	BYTE	#$0C
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$0C
	BYTE	#$0A
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00
	BYTE	#$00

	_align	10

Bad_Apple_04_Pointers
	BYTE #<Bad_Apple_1_04
	BYTE #>Bad_Apple_1_04	
	BYTE #<Bad_Apple_2_04
	BYTE #>Bad_Apple_2_04	
	BYTE #<Bad_Apple_3_04
	BYTE #>Bad_Apple_3_04	
	BYTE #<Bad_Apple_4_04
	BYTE #>Bad_Apple_4_04	
	BYTE #<Bad_Apple_5_04
	BYTE #>Bad_Apple_5_04	

	_align	10

Bad_Apple_05_Pointers
	BYTE #<Bad_Apple_1_05
	BYTE #>Bad_Apple_1_05	
	BYTE #<Bad_Apple_2_05
	BYTE #>Bad_Apple_2_05	
	BYTE #<Bad_Apple_3_05
	BYTE #>Bad_Apple_3_05	
	BYTE #<Bad_Apple_4_05
	BYTE #>Bad_Apple_4_05	
	BYTE #<Bad_Apple_5_05
	BYTE #>Bad_Apple_5_05	

	_align	10

Bad_Apple_06_Pointers
	BYTE #<Bad_Apple_1_06
	BYTE #>Bad_Apple_1_06	
	BYTE #<Bad_Apple_2_06
	BYTE #>Bad_Apple_2_06	
	BYTE #<Bad_Apple_3_06
	BYTE #>Bad_Apple_3_06	
	BYTE #<Bad_Apple_4_06
	BYTE #>Bad_Apple_4_06	
	BYTE #<Bad_Apple_5_06
	BYTE #>Bad_Apple_5_06

	_align	10

Bad_Apple_07_Pointers
	BYTE #<Bad_Apple_1_07
	BYTE #>Bad_Apple_1_07	
	BYTE #<Bad_Apple_2_07
	BYTE #>Bad_Apple_2_07	
	BYTE #<Bad_Apple_3_07
	BYTE #>Bad_Apple_3_07	
	BYTE #<Bad_Apple_4_07
	BYTE #>Bad_Apple_4_07	
	BYTE #<Bad_Apple_5_07
	BYTE #>Bad_Apple_5_07	

	_align	10

Bad_Apple_08_Pointers
	BYTE #<Bad_Apple_1_08
	BYTE #>Bad_Apple_1_08	
	BYTE #<Bad_Apple_2_08
	BYTE #>Bad_Apple_2_08	
	BYTE #<Bad_Apple_3_08
	BYTE #>Bad_Apple_3_08	
	BYTE #<Bad_Apple_4_08
	BYTE #>Bad_Apple_4_08	
	BYTE #<Bad_Apple_5_08
	BYTE #>Bad_Apple_5_08

	_align	10

Bad_Apple_09_Pointers
	BYTE #<Bad_Apple_1_09
	BYTE #>Bad_Apple_1_09	
	BYTE #<Bad_Apple_2_09
	BYTE #>Bad_Apple_2_09	
	BYTE #<Bad_Apple_3_09
	BYTE #>Bad_Apple_3_09	
	BYTE #<Bad_Apple_4_09
	BYTE #>Bad_Apple_4_09	
	BYTE #<Bad_Apple_5_09
	BYTE #>Bad_Apple_5_09			

	_align	10

Bad_Apple_10_Pointers
	BYTE #<Bad_Apple_1_10
	BYTE #>Bad_Apple_1_10	
	BYTE #<Bad_Apple_2_10
	BYTE #>Bad_Apple_2_10	
	BYTE #<Bad_Apple_3_10
	BYTE #>Bad_Apple_3_10	
	BYTE #<Bad_Apple_4_10
	BYTE #>Bad_Apple_4_10	
	BYTE #<Bad_Apple_5_10
	BYTE #>Bad_Apple_5_10	

	_align	10

Bad_Apple_11_Pointers
	BYTE #<Bad_Apple_1_11
	BYTE #>Bad_Apple_1_11	
	BYTE #<Bad_Apple_2_11
	BYTE #>Bad_Apple_2_11	
	BYTE #<Bad_Apple_3_11
	BYTE #>Bad_Apple_3_11	
	BYTE #<Bad_Apple_4_11
	BYTE #>Bad_Apple_4_11	
	BYTE #<Bad_Apple_5_11
	BYTE #>Bad_Apple_5_11	

	_align 97
Bad_Apple_1_04
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000010
	BYTE %00000011
	BYTE %00000011
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
Bad_Apple_2_04
Bad_Apple_3_04
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000	
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000


	_align	74

Bad_Apple_1_05
	BYTE %00111111
	BYTE %00011111
	BYTE %00111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111110
	BYTE %11111100
	BYTE %11111100
	BYTE %11111110
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00011111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000110
	BYTE %00001100
	BYTE %00001000
	BYTE %00010001
	BYTE %00010111
	BYTE %00110111
	BYTE %00110011
	BYTE %00011111
	BYTE %00111111
	BYTE %01111111
	BYTE %00111111
	BYTE %00000111
	BYTE %00001111
	BYTE %00111111
	BYTE %01111111
	BYTE %01100111
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001110
	BYTE %00001100
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_1_06
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11100111
	BYTE %11110011
	BYTE %11111011
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %00011111
	BYTE %00000011
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_1_07
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000011
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000111
	BYTE %00001111
	BYTE %00011111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_1_08
	BYTE %00000001
	BYTE %00000001
	BYTE %00000101
	BYTE %00000101
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000010
	BYTE %00000111
	BYTE %00000111
	BYTE %10000011
	BYTE %00011000
	BYTE %00111100
	BYTE %00011111
	BYTE %00001111
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000011
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00010000
	BYTE %00111000
	BYTE %11111100
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74
Bad_Apple_1_09
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %10111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00011111
	BYTE %00011111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %00111111
	BYTE %10111111
	BYTE %10011111
	BYTE %11011111
	BYTE %11001111
	BYTE %11001111
	BYTE %11001111
	BYTE %00011111
	BYTE %00111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %00111111
	BYTE %00011111
	BYTE %10011111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_1_10
Bad_Apple_1_11
Bad_Apple_4_10
Bad_Apple_4_11
Bad_Apple_5_09
Bad_Apple_5_10
Bad_Apple_5_11
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

Bad_Apple_2_06
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %00111111
	BYTE %01111111
	BYTE %11100111
	BYTE %10000111
	BYTE %00001111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11101111
	BYTE %11000111
	BYTE %00000011
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_2_05
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00001011
	BYTE %00001011
	BYTE %00001101
	BYTE %00001101
	BYTE %00001101
	BYTE %00000101
	BYTE %00000100
	BYTE %00000110
	BYTE %00000010
	BYTE %00000010
	BYTE %00000011
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000110
	BYTE %00001100
	BYTE %00011000
	BYTE %00011001
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_2_07
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %11110000
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_2_08
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000011
	BYTE %00011111
	BYTE %01111111
	BYTE %01111111
	BYTE %01110000
	BYTE %00100000
	BYTE %00000011
	BYTE %00000011
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_2_09
	BYTE %00001111
	BYTE %00011111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111110
	BYTE %11111100
	BYTE %11110000
	BYTE %01000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000011
	BYTE %00111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %00011111
	BYTE %00001111
	BYTE %11000111
	BYTE %11110011
	BYTE %00111001
	BYTE %00111101
	BYTE %00111101
	BYTE %00011101
	BYTE %00011001
	BYTE %00010011
	BYTE %00000011
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %00011111
	BYTE %00111111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00001111
	BYTE %10001111
	BYTE %11001111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_2_10
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %00000011
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00001111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_2_11
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_3_05
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000111
	BYTE %00000110
	BYTE %00000110
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00001111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_3_06
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %00111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %10011111
	BYTE %00001111
	BYTE %00000011
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_3_07
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %10000000
	BYTE %11001111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_3_08
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000011
	BYTE %00001111
	BYTE %01111111
	BYTE %00100000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00001100
	BYTE %00111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_3_09
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11001111
	BYTE %11000111
	BYTE %10000111
	BYTE %00001111
	BYTE %00011111
	BYTE %00011111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111100
	BYTE %11000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000011
	BYTE %00110001
	BYTE %00111001
	BYTE %00111000
	BYTE %00011100
	BYTE %00011000
	BYTE %00010001
	BYTE %00000011
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %01001111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_3_10
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %00111100
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00010000
	BYTE %11111000
	BYTE %11111100
	BYTE %11111000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111100
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_3_11
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11110111
	BYTE %11000001
	BYTE %10000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_4_04
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_4_05
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00001111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %00011111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00011111
	BYTE %00111111
	BYTE %00111000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_4_06
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %00111111
	BYTE %00011111
	BYTE %00000011
	BYTE %00000011
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_4_07
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %11100000
	BYTE %11110000
	BYTE %11111000
	BYTE %11111100
	BYTE %11111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_4_08
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00000001
	BYTE %00011001
	BYTE %00111100
	BYTE %11111100
	BYTE %00111110
	BYTE %00111111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000010
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000001
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %01000001
	BYTE %01110001
	BYTE %00111111
	BYTE %00011111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %10000000
	BYTE %11000000
	BYTE %11100000
	BYTE %11100000
	BYTE %11100000
	BYTE %11110000
	BYTE %11110000
	BYTE %11110000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111100
	BYTE %11111100
	BYTE %11111110
	BYTE %11111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_4_09
	BYTE %00000111
	BYTE %00011111
	BYTE %00111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %00111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %00001111
	BYTE %10001111
	BYTE %10011111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_5_04
	BYTE %00000001
	BYTE %00000011
	BYTE %00000010
	BYTE %00000010
	BYTE %00000011
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000

	_align	74

Bad_Apple_5_05
	BYTE %00000111
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111
	BYTE %00011111
	BYTE %00111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %01111111
	BYTE %00111111
	BYTE %00111111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000011
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000001
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00000111
	BYTE %00001111
	BYTE %00001111

	_align	74

Bad_Apple_5_06
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11100111
	BYTE %11110000
	BYTE %11110000
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111110
	BYTE %01111110
	BYTE %01111110
	BYTE %01111110
	BYTE %11111100
	BYTE %11111000
	BYTE %11111000
	BYTE %11110000
	BYTE %11110000
	BYTE %11110000
	BYTE %11110000
	BYTE %11110000
	BYTE %11110000
	BYTE %11110000
	BYTE %11100000
	BYTE %11100000
	BYTE %11100000
	BYTE %11100000
	BYTE %11100000
	BYTE %11100000
	BYTE %11000000
	BYTE %11000000
	BYTE %11000000

	_align	74

Bad_Apple_5_07
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000001
	BYTE %00000011
	BYTE %00111111
	BYTE %01111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

	_align	74

Bad_Apple_5_08
	BYTE %00001111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00100111
	BYTE %11100111
	BYTE %11001111
	BYTE %10001111
	BYTE %00001111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00011111
	BYTE %00111111
	BYTE %00011111
	BYTE %00011111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00001111
	BYTE %00000111
	BYTE %00000111
	BYTE %00001111
	BYTE %00011111
	BYTE %00011111
	BYTE %00111111
	BYTE %00111111
	BYTE %00111111
	BYTE %01111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111


*Routine Section
*---------------------------------
* This is were the routines are
* used by the developer.
*

Bank3_Call_SoundPlayer
*
*	temp19 = (number of bank) - 1 
*
	LDA	#2
	STA	temp19

	lda	#>(Bank1_SoundPlayer-1)
   	pha
   	lda	#<(Bank1_SoundPlayer-1)
   	pha
   	pha
   	pha
   	ldx	#1
   	jmp	bankSwitchJump

Bank3_Call_DynamicText
*
*	temp19 = (number of bank) - 1 
*
	LDA	#2
	STA	temp19

	lda	#>(Bank8_Display_Level_Name-1)
   	pha
   	lda	#<(Bank8_Display_Level_Name-1)
   	pha
   	pha
   	pha
   	ldx	#8
   	jmp	bankSwitchJump

Bank3_Return
	RTS

Bank3_Call_48px
	lda	#>(Bank2_48px_Text_Routine_For3-1)
   	pha
   	lda	#<(Bank2_48px_Text_Routine_For3-1)
   	pha
   	pha
   	pha
   	ldx	#2

   	jmp	bankSwitchJump

Bank3_SetPointers
*
*	TestOnly! (this is the widest)
*
*	LDA	#%01000000
*	STA	SpriteCounter


*
*	temp01:	Pointer for sprite 04
*	temp03:	Pointer for sprite 05
*	temp05:	Pointer for sprite 06
*	temp07:	Pointer for sprite 07
*	temp09:	Pointer for sprite 08
*	temp11:	Pointer for sprite 09
*	temp13:	Pointer for sprite 10
*	temp15:	Pointer for sprite 11
*

	LDA	SpriteCounter
	AND	#%11100000
	LSR
	LSR
	LSR
	LSR
	TAX

	LDA	Bad_Apple_04_Pointers,x
	STA	temp01

	LDA	Bad_Apple_04_Pointers+1,x
	STA	temp02
	
	LDA	Bad_Apple_05_Pointers,x
	STA	temp03

	LDA	Bad_Apple_05_Pointers+1,x
	STA	temp04

	LDA	Bad_Apple_06_Pointers,x
	STA	temp05

	LDA	Bad_Apple_06_Pointers+1,x
	STA	temp06

	LDA	Bad_Apple_07_Pointers,x
	STA	temp07

	LDA	Bad_Apple_07_Pointers+1,x
	STA	temp08

	LDA	Bad_Apple_08_Pointers,x
	STA	temp09

	LDA	Bad_Apple_08_Pointers+1,x
	STA	temp10

	LDA	Bad_Apple_09_Pointers,x
	STA	temp11

	LDA	Bad_Apple_09_Pointers+1,x
	STA	temp12

	LDA	Bad_Apple_10_Pointers,x
	STA	temp13

	LDA	Bad_Apple_10_Pointers+1,x
	STA	temp14

	LDA	Bad_Apple_11_Pointers,x
	STA	temp15

	LDA	Bad_Apple_11_Pointers+1,x
	STA	temp16

	LDA	SpriteCounter
	AND	#%00011111
	LSR
	TAX
	LDA	Bad_Apple_Light,x
	STA	temp17

	RTS

###End-Bank3

	saveFreeBytes
	rewind 	3fd4

start_bank3
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address 
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 3ffc
   	.byte 	#<start_bank3
   	.byte 	#>start_bank3
   	.byte 	#<start_bank3
   	.byte 	#>start_bank3

***************************
********* Start of 4th bank
***************************
	Bank 4
	fill	256
###Start-Bank4

EnterScreenBank4
Eiki2_Initialize

	LDA	#2
	STA	VBLANK ; Turn off graphics display

	; Turn off graphics and make sure we are finish overscan
	; Save the number of tics the timer had!

	LDA	#0
	STA	AUDC0
	STA	AUDF0
	STA	AUDV0
	STA	AUDV1
	STA	temp13

	LDA	#1
	STA	temp12

	; Usage of temps:
	;
	; temp10, temp11: Sound Pointer
	; temp12        : Saved Data
	; temp13	: Counter
	;	


Eiki2_Constant      = 20
Eiki2_NTSC_Vblank   = 37
Eiki2_NTSC_Overscan = 30
Eiki2_PAL_Vblank    = 67
Eiki2_PAL_Overscan  = 50


Eiki2_EOF_byte = %00000000


	LDA	#<Eiki2_Table
	STA	temp10
	LDA	#>Eiki2_Table
	STA	temp11

	; Because in this case, there is nothing done
	; by the player and this is a temporal state,
	; we don't have to waste any of the precious
	; memory!


Eiki2_EndOScan
	LDA	INTIM
	BPL	Eiki2_EndOScan

	; End OverScan, so we can calculate better!

Eiki2_LoadSample
	LDA	temp13			; 3
	CMP	#0			; 2
	BEQ	Eiki2_LoadNew	; 2

	_sleep	42
	sleep	5

	DEC	temp13			; 5
	LDA	temp12			; 3
	JMP	Eiki2_CounterDone ; 3

Eiki2_LoadNew
	LDX	#temp10			; 2
	LDA	($00,x)			; 6 
	CMP	#Eiki2_EOF_byte	; 2 
	BEQ	Eiki2_FinishHim	; 2 
	INC	0,x			; 6
	BNE	*+4			; 2 
	INC	1,x 			; 6 

	CMP	#16			; 2
	BCS	Eiki2_NoCounter	; 2

	STA	temp13			; 3

	INC	0,x			; 6
	BNE	*+4			; 2 
	INC	1,x 			; 6 

	LDA	temp12			; 3
	JMP	Eiki2_CounterDone ; 3

Eiki2_NoCounter
	STA	temp12			; 3
	_sleep	22

	LDA	temp12			; 3
Eiki2_CounterDone
	TAY				; 2

	_sleep 50
	sleep 4

	TYA				; 2
	STA	AUDV0			; 3 (5)
	LSR				; 2 (7)
	LSR				; 2 (9)
	LSR				; 2 (11)
	LSR				; 2 (13)

	TAY				; 2 (15)
	_sleep 122
	sleep 2


	TYA				; 2
	STA	AUDV0			; 3 (5)
	JMP	Eiki2_LoadSample	; 3 (8)
	
Eiki2_FinishHim
	LDX	#Eiki2_Constant	; 2 (14)

	LDA	#0
	STA	COLUP0
	STA	COLUP1
	STA	COLUPF
	STA	COLUBK
	JMP	Eiki2_JumpHereToFake

Eiki2_DebugScreen
	LDA	#2
	STA	VBLANK
	STA	VSYNC

	STA	WSYNC
	STA	WSYNC
	STA	WSYNC

	LDA	#0
	STA	VSYNC
	
	LDY	#Eiki2_NTSC_Vblank
Eiki2_DebugLoop1
	STA	WSYNC
	DEY
	BNE	Eiki2_DebugLoop1

	LDA	#0
	STA	VBLANK
		
	LDY	#192
Eiki2_JumpHereToFake
	DEX	
	CPX	#0
	BEQ	Eiki2_NoMoreLoops
Eiki2_DebugLoop2
	STA	WSYNC
	DEY
	BNE	Eiki2_DebugLoop2

	LDA	#2
	STA	VBLANK
	LDY	#Eiki2_NTSC_Overscan
Eiki2_DebugLoop3
	STA	WSYNC
	DEY
	BNE	Eiki2_DebugLoop3

	JMP	Eiki2_DebugScreen


Eiki2_NoMoreLoops
	LDX	#1	
		
	lda	#>(EnterScreenBank1-1)
   	pha
   	lda	#<(EnterScreenBank1-1)
   	pha
   	pha
   	pha
   	jmp	bankSwitchJump


Eiki2_Table
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%00000110
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%00000110
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10001000
	BYTE	#%00000110
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10001000
	BYTE	#%00000101
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000110
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000110
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001001
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10010111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01100110
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01111001
	BYTE	#%01101000
	BYTE	#%01110110
	BYTE	#%01100110
	BYTE	#%01011000
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%10011001
	BYTE	#%01010110
	BYTE	#%01100110
	BYTE	#%10000110
	BYTE	#%01111000
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001001
	BYTE	#%01101000
	BYTE	#%01100110
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001010
	BYTE	#%01111000
	BYTE	#%01010111
	BYTE	#%10001000
	BYTE	#%01111001
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10011000
	BYTE	#%10000110
	BYTE	#%01011000
	BYTE	#%10011000
	BYTE	#%11001000
	BYTE	#%01010110
	BYTE	#%01100110
	BYTE	#%01110111
	BYTE	#%10100111
	BYTE	#%10001000
	BYTE	#%01101000
	BYTE	#%01110110
	BYTE	#%10111001
	BYTE	#%01111001
	BYTE	#%01010100
	BYTE	#%01110110
	BYTE	#%10010111
	BYTE	#%10011010
	BYTE	#%01101000
	BYTE	#%01010110
	BYTE	#%10100111
	BYTE	#%10011010
	BYTE	#%01000111
	BYTE	#%01100110
	BYTE	#%10000110
	BYTE	#%10111010
	BYTE	#%10001010
	BYTE	#%01010101
	BYTE	#%01110100
	BYTE	#%10111010
	BYTE	#%01101011
	BYTE	#%01000110
	BYTE	#%01010110
	BYTE	#%10011001
	BYTE	#%11001011
	BYTE	#%01100111
	BYTE	#%01000100
	BYTE	#%10100111
	BYTE	#%10111001
	BYTE	#%01100111
	BYTE	#%01010101
	BYTE	#%10000110
	BYTE	#%10101010
	BYTE	#%10011011
	BYTE	#%01010101
	BYTE	#%01110101
	BYTE	#%10011011
	BYTE	#%10011001
	BYTE	#%01010101
	BYTE	#%01100100
	BYTE	#%11001000
	BYTE	#%10011010
	BYTE	#%01001001
	BYTE	#%01000101
	BYTE	#%10110110
	BYTE	#%10001010
	BYTE	#%01101010
	BYTE	#%01010101
	BYTE	#%10100011
	BYTE	#%10111010
	BYTE	#%01111001
	BYTE	#%00110110
	BYTE	#%01110110
	BYTE	#%10111010
	BYTE	#%01111001
	BYTE	#%01011001
	BYTE	#%01010110
	BYTE	#%10110110
	BYTE	#%10111010
	BYTE	#%01100110
	BYTE	#%01000110
	BYTE	#%01111000
	BYTE	#%10101010
	BYTE	#%01110110
	BYTE	#%01001001
	BYTE	#%01100111
	BYTE	#%11010111
	BYTE	#%10001001
	BYTE	#%01001000
	BYTE	#%01011000
	BYTE	#%10011000
	BYTE	#%10011001
	BYTE	#%01110110
	BYTE	#%01000111
	BYTE	#%01101000
	BYTE	#%11001000
	BYTE	#%10001000
	BYTE	#%01010111
	BYTE	#%01101000
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%01110110
	BYTE	#%01001001
	BYTE	#%10000111
	BYTE	#%10110111
	BYTE	#%10001000
	BYTE	#%01100111
	BYTE	#%01100111
	BYTE	#%10001001
	BYTE	#%10001000
	BYTE	#%10000110
	BYTE	#%01001000
	BYTE	#%01111001
	BYTE	#%10101000
	BYTE	#%10000111
	BYTE	#%01100110
	BYTE	#%01110111
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%10010110
	BYTE	#%01011000
	BYTE	#%01101000
	BYTE	#%10110111
	BYTE	#%10011001
	BYTE	#%01010111
	BYTE	#%10000111
	BYTE	#%10101001
	BYTE	#%01101000
	BYTE	#%10010111
	BYTE	#%01101000
	BYTE	#%01011000
	BYTE	#%10111000
	BYTE	#%10001000
	BYTE	#%01010110
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01100111
	BYTE	#%10101000
	BYTE	#%01010111
	BYTE	#%01110111
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%01100110
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110110
	BYTE	#%10011010
	BYTE	#%01100101
	BYTE	#%01110111
	BYTE	#%10001001
	BYTE	#%10011000
	BYTE	#%01100110
	BYTE	#%10000111
	BYTE	#%10101001
	BYTE	#%01110111
	BYTE	#%10001001
	BYTE	#%01110101
	BYTE	#%10001000
	BYTE	#%01111010
	BYTE	#%01110110
	BYTE	#%10000110
	BYTE	#%01111001
	BYTE	#%10011000
	BYTE	#%01100101
	BYTE	#%10101001
	BYTE	#%01011000
	BYTE	#%10000110
	BYTE	#%10011000
	BYTE	#%01100111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000110
	BYTE	#%01110111
	BYTE	#%10001010
	BYTE	#%01100101
	BYTE	#%10010111
	BYTE	#%01101011
	BYTE	#%01100110
	BYTE	#%10010110
	BYTE	#%01111010
	BYTE	#%01111000
	BYTE	#%10010111
	BYTE	#%01010111
	BYTE	#%01110111
	BYTE	#%10111001
	BYTE	#%01000110
	BYTE	#%10000101
	BYTE	#%10011010
	BYTE	#%01111000
	BYTE	#%01100110
	BYTE	#%01111010
	BYTE	#%10000101
	BYTE	#%10011001
	BYTE	#%01011010
	BYTE	#%10000100
	BYTE	#%10101001
	BYTE	#%01011000
	BYTE	#%10000111
	BYTE	#%01110110
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%01100111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10101000
	BYTE	#%01001000
	BYTE	#%10010110
	BYTE	#%10101000
	BYTE	#%01011001
	BYTE	#%10000110
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01101000
	BYTE	#%10100111
	BYTE	#%01101001
	BYTE	#%01110110
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%01100111
	BYTE	#%10010111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10101001
	BYTE	#%01000100
	BYTE	#%10010111
	BYTE	#%10011011
	BYTE	#%01010100
	BYTE	#%10010111
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%10001001
	BYTE	#%01010101
	BYTE	#%10111000
	BYTE	#%01101010
	BYTE	#%01100101
	BYTE	#%10101000
	BYTE	#%01111001
	BYTE	#%01110111
	BYTE	#%10011001
	BYTE	#%01100100
	BYTE	#%10101001
	BYTE	#%01011010
	BYTE	#%01110100
	BYTE	#%10101001
	BYTE	#%01101010
	BYTE	#%01100110
	BYTE	#%10000110
	BYTE	#%01111010
	BYTE	#%10000101
	BYTE	#%01111000
	BYTE	#%10001001
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10011001
	BYTE	#%01010100
	BYTE	#%10011001
	BYTE	#%10001010
	BYTE	#%01110100
	BYTE	#%01111000
	BYTE	#%10001011
	BYTE	#%01110110
	BYTE	#%10010110
	BYTE	#%01101000
	BYTE	#%10011000
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10011001
	BYTE	#%01110111
	BYTE	#%01100111
	BYTE	#%10111001
	BYTE	#%01010101
	BYTE	#%01111000
	BYTE	#%10011011
	BYTE	#%01110011
	BYTE	#%01110111
	BYTE	#%10001010
	BYTE	#%10010111
	BYTE	#%01001001
	BYTE	#%01110101
	BYTE	#%10111001
	BYTE	#%01011001
	BYTE	#%01110101
	BYTE	#%10101000
	BYTE	#%01101000
	BYTE	#%10000111
	BYTE	#%01011000
	BYTE	#%10100110
	BYTE	#%10101001
	BYTE	#%01000111
	BYTE	#%10010110
	BYTE	#%10101000
	BYTE	#%01011000
	BYTE	#%01100110
	BYTE	#%10101000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01100101
	BYTE	#%01111010
	BYTE	#%10001001
	BYTE	#%10000100
	BYTE	#%01110111
	BYTE	#%10001010
	BYTE	#%01110111
	BYTE	#%10000110
	BYTE	#%10000111
	BYTE	#%10011001
	BYTE	#%01010111
	BYTE	#%10010101
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01110110
	BYTE	#%10001010
	BYTE	#%10000101
	BYTE	#%10001000
	BYTE	#%01011000
	BYTE	#%10000111
	BYTE	#%10000110
	BYTE	#%10001000
	BYTE	#%10011010
	BYTE	#%01010100
	BYTE	#%01110111
	BYTE	#%10101010
	BYTE	#%01100111
	BYTE	#%01100101
	BYTE	#%10101001
	BYTE	#%10001001
	BYTE	#%01000111
	BYTE	#%10000101
	BYTE	#%10111010
	BYTE	#%01011000
	BYTE	#%01100110
	BYTE	#%10101000
	BYTE	#%10001001
	BYTE	#%00110110
	BYTE	#%10100111
	BYTE	#%10011000
	BYTE	#%01010111
	BYTE	#%10001000
	BYTE	#%10010111
	BYTE	#%01101000
	BYTE	#%01100101
	BYTE	#%10111001
	BYTE	#%01101000
	BYTE	#%01110110
	BYTE	#%10011000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111001
	BYTE	#%01110101
	BYTE	#%10011010
	BYTE	#%01011000
	BYTE	#%10000101
	BYTE	#%10011000
	BYTE	#%01111001
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10010111
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01101000
	BYTE	#%10011001
	BYTE	#%01110100
	BYTE	#%10001000
	BYTE	#%01111011
	BYTE	#%01110110
	BYTE	#%10000110
	BYTE	#%10001010
	BYTE	#%10011000
	BYTE	#%01010100
	BYTE	#%10010111
	BYTE	#%10011011
	BYTE	#%01100101
	BYTE	#%01110110
	BYTE	#%10011010
	BYTE	#%10011000
	BYTE	#%00110101
	BYTE	#%10010111
	BYTE	#%10011011
	BYTE	#%01010101
	BYTE	#%01100111
	BYTE	#%10111010
	BYTE	#%01101001
	BYTE	#%01100100
	BYTE	#%10011001
	BYTE	#%10001001
	BYTE	#%01110110
	BYTE	#%01110101
	BYTE	#%10011001
	BYTE	#%01111000
	BYTE	#%10000110
	BYTE	#%01011000
	BYTE	#%10011000
	BYTE	#%10000111
	BYTE	#%01100111
	BYTE	#%01111001
	BYTE	#%10000111
	BYTE	#%10100111
	BYTE	#%00110111
	BYTE	#%10101000
	BYTE	#%10011001
	BYTE	#%01100110
	BYTE	#%01101000
	BYTE	#%10101001
	BYTE	#%10000111
	BYTE	#%01000111
	BYTE	#%10010111
	BYTE	#%10101010
	BYTE	#%01000111
	BYTE	#%10000101
	BYTE	#%10101010
	BYTE	#%01011000
	BYTE	#%01111000
	BYTE	#%10000100
	BYTE	#%10011010
	BYTE	#%01011010
	BYTE	#%10000100
	BYTE	#%10001000
	BYTE	#%01111010
	BYTE	#%10001000
	BYTE	#%01100011
	BYTE	#%10101010
	BYTE	#%01111010
	BYTE	#%01010101
	BYTE	#%10010110
	BYTE	#%10101011
	BYTE	#%01001000
	BYTE	#%10000100
	BYTE	#%10101001
	BYTE	#%01101001
	BYTE	#%01010101
	BYTE	#%11000111
	BYTE	#%01111010
	BYTE	#%01000111
	BYTE	#%10100100
	BYTE	#%10101010
	BYTE	#%01011000
	BYTE	#%01110101
	BYTE	#%10101001
	BYTE	#%01101001
	BYTE	#%01110110
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%01101000
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10011000
	BYTE	#%01010101
	BYTE	#%10001001
	BYTE	#%10001001
	BYTE	#%01110110
	BYTE	#%10000111
	BYTE	#%10011010
	BYTE	#%01010111
	BYTE	#%10000110
	BYTE	#%10011001
	BYTE	#%01111000
	BYTE	#%01010101
	BYTE	#%10011001
	BYTE	#%01111010
	BYTE	#%01100011
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01010111
	BYTE	#%10010111
	BYTE	#%10101001
	BYTE	#%01010101
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01100111
	BYTE	#%10000110
	BYTE	#%10101001
	BYTE	#%01010101
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10000110
	BYTE	#%10011001
	BYTE	#%01000101
	BYTE	#%10010111
	BYTE	#%10011010
	BYTE	#%01101000
	BYTE	#%01110101
	BYTE	#%10101001
	BYTE	#%00111010
	BYTE	#%10000100
	BYTE	#%10101001
	BYTE	#%01111000
	BYTE	#%01110110
	BYTE	#%10101000
	BYTE	#%01001010
	BYTE	#%10010101
	BYTE	#%10010111
	BYTE	#%10001001
	BYTE	#%01000111
	BYTE	#%10101000
	BYTE	#%01011010
	BYTE	#%10000101
	BYTE	#%10010111
	BYTE	#%10001010
	BYTE	#%01010101
	BYTE	#%10101000
	BYTE	#%01001010
	BYTE	#%10010101
	BYTE	#%10010111
	BYTE	#%10001001
	BYTE	#%01100110
	BYTE	#%10110111
	BYTE	#%00111000
	BYTE	#%10011001
	BYTE	#%10000110
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10111001
	BYTE	#%01000100
	BYTE	#%01111001
	BYTE	#%10101001
	BYTE	#%01100111
	BYTE	#%01110110
	BYTE	#%10011011
	BYTE	#%01110011
	BYTE	#%01101001
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111011
	BYTE	#%10010100
	BYTE	#%10000111
	BYTE	#%10001001
	BYTE	#%01010111
	BYTE	#%10110111
	BYTE	#%01001001
	BYTE	#%10000110
	BYTE	#%10010111
	BYTE	#%10001001
	BYTE	#%01100101
	BYTE	#%11001000
	BYTE	#%01010110
	BYTE	#%01101001
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01100110
	BYTE	#%10101011
	BYTE	#%10000010
	BYTE	#%01110111
	BYTE	#%10001010
	BYTE	#%01011000
	BYTE	#%10010101
	BYTE	#%01111011
	BYTE	#%10010100
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01100111
	BYTE	#%10011000
	BYTE	#%01001010
	BYTE	#%10010101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01100110
	BYTE	#%10111000
	BYTE	#%00111001
	BYTE	#%10010111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%01110110
	BYTE	#%10101010
	BYTE	#%01010011
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01011001
	BYTE	#%10100110
	BYTE	#%01001011
	BYTE	#%10010110
	BYTE	#%10001000
	BYTE	#%10010111
	BYTE	#%01010110
	BYTE	#%11001001
	BYTE	#%01000101
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10000110
	BYTE	#%10001100
	BYTE	#%01100011
	BYTE	#%10001000
	BYTE	#%10100111
	BYTE	#%01011000
	BYTE	#%10110111
	BYTE	#%00111001
	BYTE	#%10010110
	BYTE	#%01101000
	BYTE	#%10011000
	BYTE	#%01110110
	BYTE	#%10101010
	BYTE	#%01100101
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01011000
	BYTE	#%10110110
	BYTE	#%01001010
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10011001
	BYTE	#%01110101
	BYTE	#%10101010
	BYTE	#%01100101
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01101010
	BYTE	#%10000111
	BYTE	#%01101011
	BYTE	#%01110101
	BYTE	#%10001000
	BYTE	#%10101000
	BYTE	#%01100110
	BYTE	#%10111001
	BYTE	#%01100111
	BYTE	#%01111000
	BYTE	#%01110110
	BYTE	#%10001001
	BYTE	#%10000101
	BYTE	#%01111010
	BYTE	#%10000101
	BYTE	#%01111000
	BYTE	#%10010111
	BYTE	#%01010111
	BYTE	#%10100111
	BYTE	#%01010111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001001
	BYTE	#%10000101
	BYTE	#%10001011
	BYTE	#%01110100
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01101000
	BYTE	#%11001000
	BYTE	#%01011000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001001
	BYTE	#%10000110
	BYTE	#%10001010
	BYTE	#%01110101
	BYTE	#%01110111
	BYTE	#%10010111
	BYTE	#%01101000
	BYTE	#%10100111
	BYTE	#%01101001
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110110
	BYTE	#%10101010
	BYTE	#%01110110
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01101000
	BYTE	#%10011000
	BYTE	#%01101001
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%10000110
	BYTE	#%10011001
	BYTE	#%10000111
	BYTE	#%01100111
	BYTE	#%01110111
	BYTE	#%01101000
	BYTE	#%10010111
	BYTE	#%01101001
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110110
	BYTE	#%10101000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%01100111
	BYTE	#%10000111
	BYTE	#%01111010
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10101000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10010111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10011000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110110
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110110
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10011001
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10011001
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%01100110
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001001
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110110
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000101
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10010111
	BYTE	#%01111001
	BYTE	#%01110111
	BYTE	#%10010111
	BYTE	#%01111000
	BYTE	#%01100110
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01101000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000110
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01101000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10011000
	BYTE	#%01111001
	BYTE	#%10011000
	BYTE	#%10000110
	BYTE	#%01110111
	BYTE	#%01100100
	BYTE	#%10011001
	BYTE	#%10001010
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01010101
	BYTE	#%10010110
	BYTE	#%10101000
	BYTE	#%01111010
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01100110
	BYTE	#%10010111
	BYTE	#%10101010
	BYTE	#%01101001
	BYTE	#%01110111
	BYTE	#%00110111
	BYTE	#%01100100
	BYTE	#%10111010
	BYTE	#%10011011
	BYTE	#%10000110
	BYTE	#%01111001
	BYTE	#%01000011
	BYTE	#%10010111
	BYTE	#%10101010
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01010111
	BYTE	#%01110011
	BYTE	#%10011001
	BYTE	#%10011001
	BYTE	#%10010110
	BYTE	#%10000111
	BYTE	#%01100111
	BYTE	#%01110101
	BYTE	#%10001001
	BYTE	#%10101001
	BYTE	#%01111000
	BYTE	#%01111001
	BYTE	#%01100101
	BYTE	#%01110101
	BYTE	#%10101000
	BYTE	#%10011001
	BYTE	#%10011000
	BYTE	#%01000111
	BYTE	#%01010100
	BYTE	#%10101001
	BYTE	#%10111001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01010011
	BYTE	#%10100111
	BYTE	#%10101000
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%01000110
	BYTE	#%01110101
	BYTE	#%10101010
	BYTE	#%10101010
	BYTE	#%01100111
	BYTE	#%01010111
	BYTE	#%01010101
	BYTE	#%10101001
	BYTE	#%10101001
	BYTE	#%01111000
	BYTE	#%01010110
	BYTE	#%01110101
	BYTE	#%11001000
	BYTE	#%10011010
	BYTE	#%01011010
	BYTE	#%01000111
	BYTE	#%01110110
	BYTE	#%10101000
	BYTE	#%10011010
	BYTE	#%10001001
	BYTE	#%01000111
	BYTE	#%01000011
	BYTE	#%10111000
	BYTE	#%10101001
	BYTE	#%10011000
	BYTE	#%01110111
	BYTE	#%01010100
	BYTE	#%10011001
	BYTE	#%10001010
	BYTE	#%10001000
	BYTE	#%01101001
	BYTE	#%01010100
	BYTE	#%10011000
	BYTE	#%10001011
	BYTE	#%01111001
	BYTE	#%01101001
	BYTE	#%01000100
	BYTE	#%10101001
	BYTE	#%10001011
	BYTE	#%01011000
	BYTE	#%01010111
	BYTE	#%01100101
	BYTE	#%11001010
	BYTE	#%10011001
	BYTE	#%01101000
	BYTE	#%01100111
	BYTE	#%10000100
	BYTE	#%10101000
	BYTE	#%10001001
	BYTE	#%10000111
	BYTE	#%01110110
	BYTE	#%10000101
	BYTE	#%10111001
	BYTE	#%10010110
	BYTE	#%10000101
	BYTE	#%01110101
	BYTE	#%10100101
	BYTE	#%10101001
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01100100
	BYTE	#%10010110
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110100
	BYTE	#%10111000
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01001000
	BYTE	#%01100101
	BYTE	#%11001001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01000111
	BYTE	#%10000110
	BYTE	#%10111100
	BYTE	#%10001001
	BYTE	#%10010100
	BYTE	#%01100100
	BYTE	#%10100110
	BYTE	#%10011010
	BYTE	#%01101000
	BYTE	#%01100111
	BYTE	#%01110100
	BYTE	#%10110111
	BYTE	#%01111001
	BYTE	#%01101001
	BYTE	#%01001000
	BYTE	#%01110110
	BYTE	#%10111010
	BYTE	#%10001000
	BYTE	#%01100101
	BYTE	#%00110111
	BYTE	#%10011000
	BYTE	#%10101100
	BYTE	#%10001000
	BYTE	#%10000101
	BYTE	#%01100011
	BYTE	#%10110110
	BYTE	#%10001011
	BYTE	#%01001001
	BYTE	#%01110111
	BYTE	#%10010101
	BYTE	#%10101001
	BYTE	#%10001001
	BYTE	#%01100111
	BYTE	#%00110111
	BYTE	#%10010110
	BYTE	#%10101011
	BYTE	#%10010111
	BYTE	#%01110110
	BYTE	#%00110110
	BYTE	#%10100111
	BYTE	#%10001100
	BYTE	#%01100111
	BYTE	#%01110110
	BYTE	#%01110110
	BYTE	#%10111000
	BYTE	#%10001010
	BYTE	#%01011000
	BYTE	#%01000110
	BYTE	#%10001000
	BYTE	#%10101011
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01000111
	BYTE	#%10010111
	BYTE	#%10101011
	BYTE	#%01110110
	BYTE	#%01110110
	BYTE	#%01010111
	BYTE	#%10011000
	BYTE	#%10001011
	BYTE	#%01001001
	BYTE	#%01010111
	BYTE	#%01110110
	BYTE	#%10101000
	BYTE	#%10001001
	BYTE	#%01101010
	BYTE	#%01000111
	BYTE	#%10000111
	BYTE	#%10101001
	BYTE	#%01110111
	BYTE	#%01101000
	BYTE	#%01001010
	BYTE	#%10000111
	BYTE	#%10101010
	BYTE	#%10000110
	BYTE	#%10000101
	BYTE	#%01010111
	BYTE	#%10011000
	BYTE	#%10001010
	BYTE	#%01101010
	BYTE	#%01110101
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%01111001
	BYTE	#%01011011
	BYTE	#%00110110
	BYTE	#%10000111
	BYTE	#%10111001
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01001000
	BYTE	#%10000101
	BYTE	#%10101100
	BYTE	#%10000110
	BYTE	#%01110101
	BYTE	#%01100110
	BYTE	#%10011000
	BYTE	#%01111100
	BYTE	#%01101000
	BYTE	#%01100111
	BYTE	#%01110101
	BYTE	#%10101010
	BYTE	#%01111000
	BYTE	#%01011010
	BYTE	#%01001000
	BYTE	#%10000111
	BYTE	#%10101010
	BYTE	#%01110101
	BYTE	#%01101000
	BYTE	#%01011000
	BYTE	#%10010111
	BYTE	#%10001011
	BYTE	#%01110111
	BYTE	#%10010101
	BYTE	#%01000110
	BYTE	#%10000111
	BYTE	#%10001010
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10011001
	BYTE	#%01110111
	BYTE	#%01001001
	BYTE	#%01001000
	BYTE	#%10000111
	BYTE	#%10101010
	BYTE	#%10000110
	BYTE	#%01111000
	BYTE	#%00110110
	BYTE	#%10011000
	BYTE	#%10011010
	BYTE	#%10010101
	BYTE	#%10010111
	BYTE	#%01100110
	BYTE	#%10101000
	BYTE	#%01111001
	BYTE	#%10000110
	BYTE	#%10000111
	BYTE	#%01110100
	BYTE	#%10111001
	BYTE	#%01111001
	BYTE	#%10000110
	BYTE	#%01110111
	BYTE	#%01110100
	BYTE	#%10111000
	BYTE	#%01011001
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110100
	BYTE	#%10101001
	BYTE	#%01011001
	BYTE	#%10100110
	BYTE	#%01111000
	BYTE	#%01110011
	BYTE	#%10111001
	BYTE	#%01011000
	BYTE	#%10100111
	BYTE	#%01101001
	BYTE	#%01100011
	BYTE	#%10101001
	BYTE	#%01011010
	BYTE	#%10010100
	BYTE	#%10001011
	BYTE	#%01000110
	BYTE	#%10111000
	BYTE	#%01101010
	BYTE	#%01110101
	BYTE	#%10111000
	BYTE	#%01100110
	BYTE	#%10100011
	BYTE	#%10101001
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01101010
	BYTE	#%01010110
	BYTE	#%01111001
	BYTE	#%10001010
	BYTE	#%01110111
	BYTE	#%10100110
	BYTE	#%01101010
	BYTE	#%01110101
	BYTE	#%10010111
	BYTE	#%01011000
	BYTE	#%01111000
	BYTE	#%11011000
	BYTE	#%01100110
	BYTE	#%10000101
	BYTE	#%10111001
	BYTE	#%10001000
	BYTE	#%01000110
	BYTE	#%10011010
	BYTE	#%01100111
	BYTE	#%10000110
	BYTE	#%10101001
	BYTE	#%01100110
	BYTE	#%01100110
	BYTE	#%01101101
	BYTE	#%01010110
	BYTE	#%10001000
	BYTE	#%01111001
	BYTE	#%01110111
	BYTE	#%10100110
	BYTE	#%01101010
	BYTE	#%01010111
	BYTE	#%10010111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%11000111
	BYTE	#%01100110
	BYTE	#%01110101
	BYTE	#%10101000
	BYTE	#%10000111
	BYTE	#%01011000
	BYTE	#%10011010
	BYTE	#%01100100
	BYTE	#%10000111
	BYTE	#%10001010
	BYTE	#%10000111
	BYTE	#%10000110
	BYTE	#%01001100
	BYTE	#%01100110
	BYTE	#%10000111
	BYTE	#%01101001
	BYTE	#%10001000
	BYTE	#%11000110
	BYTE	#%01110110
	BYTE	#%01100110
	BYTE	#%10011000
	BYTE	#%10000111
	BYTE	#%01011000
	BYTE	#%10111001
	BYTE	#%01110101
	BYTE	#%10010110
	BYTE	#%10001001
	BYTE	#%10010101
	BYTE	#%01110110
	BYTE	#%01011101
	BYTE	#%01010111
	BYTE	#%10001000
	BYTE	#%01101010
	BYTE	#%01111001
	BYTE	#%11000101
	BYTE	#%01001000
	BYTE	#%01110110
	BYTE	#%10101001
	BYTE	#%10000110
	BYTE	#%01001000
	BYTE	#%10101100
	BYTE	#%01110100
	BYTE	#%10000111
	BYTE	#%01111001
	BYTE	#%10000110
	BYTE	#%10100101
	BYTE	#%01001100
	BYTE	#%01110110
	BYTE	#%10010111
	BYTE	#%01101000
	BYTE	#%01011001
	BYTE	#%11000111
	BYTE	#%01110101
	BYTE	#%01110111
	BYTE	#%10101000
	BYTE	#%10010111
	BYTE	#%01100110
	BYTE	#%01111100
	BYTE	#%01100110
	BYTE	#%10000110
	BYTE	#%01101001
	BYTE	#%01111010
	BYTE	#%11000101
	BYTE	#%01001000
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10100110
	BYTE	#%01010111
	BYTE	#%10101010
	BYTE	#%10000101
	BYTE	#%10010111
	BYTE	#%01101000
	BYTE	#%10001000
	BYTE	#%10100100
	BYTE	#%01011010
	BYTE	#%10001000
	BYTE	#%10100110
	BYTE	#%10100110
	BYTE	#%01001000
	BYTE	#%10111000
	BYTE	#%01110011
	BYTE	#%10010111
	BYTE	#%01111001
	BYTE	#%10101000
	BYTE	#%10010100
	BYTE	#%01011011
	BYTE	#%01110111
	BYTE	#%10100110
	BYTE	#%10100110
	BYTE	#%01011000
	BYTE	#%10101011
	BYTE	#%01110100
	BYTE	#%01111000
	BYTE	#%01101001
	BYTE	#%01111001
	BYTE	#%10110110
	BYTE	#%01100101
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10010101
	BYTE	#%01001011
	BYTE	#%10000110
	BYTE	#%10011000
	BYTE	#%10110110
	BYTE	#%01101000
	BYTE	#%01011011
	BYTE	#%01110101
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01101011
	BYTE	#%10011010
	BYTE	#%01110011
	BYTE	#%01101001
	BYTE	#%01101011
	BYTE	#%01101010
	BYTE	#%11000101
	BYTE	#%01010110
	BYTE	#%10010110
	BYTE	#%10000111
	BYTE	#%10100110
	BYTE	#%01100110
	BYTE	#%01001101
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10010110
	BYTE	#%01101001
	BYTE	#%11000111
	BYTE	#%01110100
	BYTE	#%01110111
	BYTE	#%01101001
	BYTE	#%10011011
	BYTE	#%10100101
	BYTE	#%01001000
	BYTE	#%10001000
	BYTE	#%10010110
	BYTE	#%10100110
	BYTE	#%01011000
	BYTE	#%01011100
	BYTE	#%01110100
	BYTE	#%01101001
	BYTE	#%10010111
	BYTE	#%01101010
	BYTE	#%11000110
	BYTE	#%01110100
	BYTE	#%10010111
	BYTE	#%01011000
	BYTE	#%10011001
	BYTE	#%10000110
	BYTE	#%00111100
	BYTE	#%01110110
	BYTE	#%10010111
	BYTE	#%10110101
	BYTE	#%01100111
	BYTE	#%10011010
	BYTE	#%01110101
	BYTE	#%01100111
	BYTE	#%01101000
	BYTE	#%01111100
	BYTE	#%10110110
	BYTE	#%01010111
	BYTE	#%01110110
	BYTE	#%01110111
	BYTE	#%10011001
	BYTE	#%01100111
	BYTE	#%01001101
	BYTE	#%01110111
	BYTE	#%10000110
	BYTE	#%11000101
	BYTE	#%01101000
	BYTE	#%11011001
	BYTE	#%01100100
	BYTE	#%01011000
	BYTE	#%01100111
	BYTE	#%01111011
	BYTE	#%10100111
	BYTE	#%01011010
	BYTE	#%10000101
	BYTE	#%01110101
	BYTE	#%10101000
	BYTE	#%01100111
	BYTE	#%01011101
	BYTE	#%01100110
	BYTE	#%01101000
	BYTE	#%10100110
	BYTE	#%01111000
	BYTE	#%11010111
	BYTE	#%01100100
	BYTE	#%10000111
	BYTE	#%01100110
	BYTE	#%01101100
	BYTE	#%10011000
	BYTE	#%01011010
	BYTE	#%01110110
	BYTE	#%01110101
	BYTE	#%10101000
	BYTE	#%10000111
	BYTE	#%01101011
	BYTE	#%01101000
	BYTE	#%01011000
	BYTE	#%10100101
	BYTE	#%10000111
	BYTE	#%11011000
	BYTE	#%01100100
	BYTE	#%01101000
	BYTE	#%01100110
	BYTE	#%01101010
	BYTE	#%10111001
	BYTE	#%10001000
	BYTE	#%10000101
	BYTE	#%01100110
	BYTE	#%01111001
	BYTE	#%10011001
	BYTE	#%01011011
	BYTE	#%10001000
	BYTE	#%01010101
	BYTE	#%10000110
	BYTE	#%10100110
	BYTE	#%10001011
	BYTE	#%01101000
	BYTE	#%01001010
	BYTE	#%10010100
	BYTE	#%10010101
	BYTE	#%10101001
	BYTE	#%01101000
	BYTE	#%01111010
	BYTE	#%10000100
	BYTE	#%01100101
	BYTE	#%10011010
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01010111
	BYTE	#%01101000
	BYTE	#%10100111
	BYTE	#%10101000
	BYTE	#%10001000
	BYTE	#%01100111
	BYTE	#%01100110
	BYTE	#%10001000
	BYTE	#%01111010
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%01010111
	BYTE	#%10000101
	BYTE	#%10011000
	BYTE	#%10101000
	BYTE	#%10001000
	BYTE	#%10000110
	BYTE	#%01100101
	BYTE	#%01110111
	BYTE	#%10011001
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01011000
	BYTE	#%01100110
	BYTE	#%10000111
	BYTE	#%01111001
	BYTE	#%01111011
	BYTE	#%10001000
	BYTE	#%01100111
	BYTE	#%01100110
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%10011000
	BYTE	#%10010110
	BYTE	#%01100101
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%10100111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01100111
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01111001
	BYTE	#%10000101
	BYTE	#%10000111
	BYTE	#%01111001
	BYTE	#%00000100
	BYTE	#%01110110
	BYTE	#%10000110
	BYTE	#%01101000
	BYTE	#%01111010
	BYTE	#%01111001
	BYTE	#%01101001
	BYTE	#%10000110
	BYTE	#%01100111
	BYTE	#%01101001
	BYTE	#%10001010
	BYTE	#%01101000
	BYTE	#%01011001
	BYTE	#%01111000
	BYTE	#%01110110
	BYTE	#%01111001
	BYTE	#%01111001
	BYTE	#%10001010
	BYTE	#%01101010
	BYTE	#%01101000
	BYTE	#%10000110
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01101010
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111001
	BYTE	#%10001000
	BYTE	#%01101000
	BYTE	#%01011010
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01001010
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%10010111
	BYTE	#%10001001
	BYTE	#%01101001
	BYTE	#%01110110
	BYTE	#%10010110
	BYTE	#%10000111
	BYTE	#%10010111
	BYTE	#%01111000
	BYTE	#%01011001
	BYTE	#%01110111
	BYTE	#%10000110
	BYTE	#%10010110
	BYTE	#%10100110
	BYTE	#%10000111
	BYTE	#%01111001
	BYTE	#%01111000
	BYTE	#%10000110
	BYTE	#%10000111
	BYTE	#%10010110
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10010111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000100
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01100110
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01100110
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01100110
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%10000111
	BYTE	#%10001001
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01100111
	BYTE	#%10000110
	BYTE	#%10011001
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110110
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01100110
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01110110
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001001
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110110
	BYTE	#%01110110
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001001
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01100111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10011000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%00000100
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01111000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%00000101
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%00000011
	BYTE	#%10001000
	BYTE	#%01110111
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%10000111
	BYTE	#%10001000
	BYTE	#%00000011
	BYTE	#%01110111
	BYTE	#%01110111
	BYTE	#%10001000
	BYTE	#%01111000
	BYTE	#%10000111
	BYTE	#%01111000
	BYTE	#%01110111
	BYTE	#%00000000

###End-Bank4

	saveFreeBytes
	rewind 	4fd4
	
start_bank4
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address  
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 4ffc
   	.byte 	#<start_bank4
   	.byte 	#>start_bank4
   	.byte 	#<start_bank4
   	.byte 	#>start_bank4


***************************
********* Start of 5th bank
***************************
	Bank 5
	fill	256
###Start-Bank5
	

###End-Bank5

	saveFreeBytes
	rewind 	5fd4
	
start_bank5
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address   
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 5ffc
   	.byte 	#<start_bank5
   	.byte 	#>start_bank5
   	.byte 	#<start_bank5
   	.byte 	#>start_bank5

***************************
********* Start of 6th bank
***************************
	Bank 6
	fill	256
###Start-Bank6
	

###End-Bank6


	saveFreeBytes
	rewind 	6fd4
	
start_bank6
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address   	
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 6ffc
   	.byte 	#<start_bank6
   	.byte 	#>start_bank6
   	.byte 	#<start_bank6
   	.byte 	#>start_bank6

***************************
********* Start of 7th bank
***************************
	Bank 7
	fill	256
###Start-Bank7
	

###End-Bank7
*Routine Section
	

	saveFreeBytes
	rewind 	7fd4
	
start_bank7
	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
   	pha
   	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address   	
   	rol
   	rol
   	rol
	rol
   	and	#7	 
	tax
   	inx
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 7ffc
   	.byte 	#<start_bank7
   	.byte 	#>start_bank7
   	.byte 	#<start_bank7
   	.byte 	#>start_bank7

***************************
********* Start of 8th bank
***************************
	Bank 8
	fill	256
###Start-Bank8

*
*	temp05		: Letter01
*	temp01		: Letter02
*	temp02		: Letter03
*	temp09		: Letter04
*	temp10		: Letter05
*	temp06		: Letter06
*	temp07		: Letter07
*	temp03		: Letter08
*	temp04		: Letter09
*	temp11		: Letter10
*	temp12		: Letter11
*	temp08		: Letter12
*			
*	temp18		: Text Color
*	temp19		: ReturnIndex
*
*	The character indexes are:
************************************
*	00: 0	01: 1	02: 2	03: 3
*	04: 4	05: 5	06: 6	07: 7
*	08: 8	09: 9   10: A	11: B
*	12: C  	13: D	14: E	15: F
*	16: G	17: H	18: I	19: J
*	20: K	21: L	22: M-1 23: M-2
*	24: N	25: O	26: P	27: Q
*	28: R	29: S	30: T	31: U
*	32: V	33: W-1	34: W-2	35: X
*	36: Y	37: Z	38: 	39: <
*	40: >	41: +	42: -	43: =
*	44: *	45: /	46: %	47: _
*	48: .	49: !	50: ?	51: :
*

Bank8_DynamicText
Bank8_DynamicText_Begin

	LDX	#0			; 2
	STX	WSYNC			; 76
	STX	COLUBK			; 3
	STX	COLUPF			; 3 (6)
	STX	COLUP0			; 3 (9)
	STX	COLUP1			; 3 (12)
	
	STX	PF0			; 3 (15)
	STX	PF1			; 3 (18)
	STX	PF2			; 3 (21)
	
	STX	GRP1			; 3 (24)
	STX	GRP0			; 3 (27)
	STX	ENAM0			; 3 (30)
	STX	ENAM1			; 3 (33)
	STX	ENABL			; 3 (36)

	STX	RESP0			; 3 (39)
	STX	RESP1			; 3 (42)

	STX	REFP0			; 3 (45)
	STX	REFP1			; 3 (48)

	LDA	#$D0			; 2 (50)
	STA	HMP0			; 3 (53)
	LDA	#$E0			; 2 (55)
	STA	HMP1			; 3 (58)

	LDA	#$03			; 2 (62)
	STA	NUSIZ0			; 3 (65)
	STA	NUSIZ1			; 3 (68)

	STA	WSYNC			; 76
	STA	HMOVE			; 3

	LDA	temp18			; 3 (6)
	STA	COLUP0			; 3 (9)
	STA	COLUP1			; 3 (12)
	
	LDA	counter			; 3 
	AND	#%00000001		; 2 
	CMP	#%00000001		; 2 		
	BEQ	Bank8_DynamicText_Otherjump	; 2 
	JMP	Bank8_DynamicText_Even_Begin	; 3 
Bank8_DynamicText_Otherjump
	JMP	Bank8_DynamicText_Odd_Begin	; 3 
	
	_align	250

Bank8_DynamicText_Odd_Begin

	LDY	temp11				; 3 
	LDA	Bank8Font_Right_Line4,y	; 5 
	LDY	temp04				; 3 
	ORA	Bank8Font_Left_Line4,y		; 5  	
	TAX					; 2 

Bank8_DynamicText_Odd_Line0
	STA	WSYNC				; 76
	sleep	3

	LDY	temp01				; 3
	LDA	Bank8Font_Right_Line4,y	; 4 (7)
	LDY	temp05				; 3 (10)
	ORA	Bank8Font_Left_Line4,y		; 4 (14) 	
	STA	GRP0				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP1				; 3 (22)

	sleep	4

	LDY	temp06				; 3 (32)
	LDA	Bank8Font_Right_Line4,y	; 4 (36)
	LDY	temp10				; 3 (39)
	ORA	Bank8Font_Left_Line4,y		; 4 (43) 	
	STA	GRP0				; 3 (47)

	sleep	2

	STX	GRP0				; 3 (52)

	LDY	temp08				; 3 (55)
	LDA	Bank8Font_Right_Line3,y	; 4 (59)
	LDY	temp12				; 3 (62)
	ORA	Bank8Font_Left_Line3,y		; 4 (66) 	
	TAX					; 2 (68)

Bank8_DynamicText_Odd_Line1
	STA	WSYNC				; 76
	LDY	temp09				; 3
	LDA	Bank8Font_Right_Line3,y	; 4 (7)
	LDY	temp02				; 3 (10)
	ORA	Bank8Font_Left_Line3,y		; 4 (14) 	
	STA	GRP1				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP0				; 3 (22)

	sleep	9

	LDY	temp03				; 3 (34)
	LDA	Bank8Font_Right_Line3,y	; 4 (38)
	LDY	temp07				; 3 (41)
	ORA	Bank8Font_Left_Line3,y		; 4 (44) 	
	STA	GRP1				; 3 (47)

	sleep	2

	STX	GRP1				; 3 (52)

	LDY	temp11				; 3 (55)
	LDA	Bank8Font_Right_Line2,y	; 4 (59)
	LDY	temp04				; 3 (62)
	ORA	Bank8Font_Left_Line2,y		; 4 (66) 	
	TAX					; 2 (68)

Bank8_DynamicText_Odd_Line2
	STA	WSYNC				; 76
	LDY	temp01				; 3
	LDA	Bank8Font_Right_Line2,y	; 4 (7)
	LDY	temp05				; 3 (10)
	ORA	Bank8Font_Left_Line2,y		; 4 (14) 	
	STA	GRP0				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP1				; 3 (22)

	sleep	7

	LDY	temp06				; 3 (32)
	LDA	Bank8Font_Right_Line2,y	; 4 (36)
	LDY	temp10				; 3 (39)
	ORA	Bank8Font_Left_Line2,y		; 4 (43) 	
	STA	GRP0				; 3 (47)

	sleep	2

	STX	GRP0				; 3 (52)

	LDY	temp08				; 3 (55)
	LDA	Bank8Font_Right_Line1,y	; 4 (59)
	LDY	temp12				; 3 (62)
	ORA	Bank8Font_Left_Line1,y		; 4 (66) 	
	TAX					; 2 (68)

Bank8_DynamicText_Odd_Line3
	STA	WSYNC				; 76
	LDY	temp09				; 3
	LDA	Bank8Font_Right_Line1,y	; 4 (8)
	LDY	temp02				; 3 (11)
	ORA	Bank8Font_Left_Line1,y		; 4 (16) 	
	STA	GRP1				; 3 (19)

	LDA	#0				; 2 (21)
	STA	GRP0				; 3 (24)

	sleep	9

	LDY	temp03				; 3 (27)
	LDA	Bank8Font_Right_Line1,y	; 4 (31)
	LDY	temp07				; 3 (34)
	ORA	Bank8Font_Left_Line1,y		; 4 (38) 	
	STA	GRP1				; 3 (41)

	sleep	2

	STX	GRP1				; 3 (46)

	LDY	temp11				; 3 (49)
	LDA	Bank8Font_Right_Line0,y	; 4 (54)
	LDY	temp04				; 3 (57)
	ORA	Bank8Font_Left_Line0,y		; 4 (61) 	
	TAX					; 2 (63)

Bank8_DynamicText_Odd_Line2
	STA	WSYNC				; 76
	LDY	temp01				; 3
	LDA	Bank8Font_Right_Line0,y	; 4 (7)
	LDY	temp05				; 3 (10)
	ORA	Bank8Font_Left_Line0,y		; 4 (14) 	
	STA	GRP0				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP1				; 3 (21)

	sleep	7

	LDY	temp06				; 3 (31)
	LDA	Bank8Font_Right_Line0,y	; 4 (35)
	LDY	temp10				; 3 (38)
	ORA	Bank8Font_Left_Line0,y		; 4 (42) 	
	STA	GRP0				; 3 (45)

	sleep	2

	STX	GRP0				; 3 (50)

	sleep	12
	
	JMP	Bank8_DynamicText_Reset

	_align	250

Bank8_DynamicText_Even_Begin
	LDY	temp08				; 3 
	LDA	Bank8Font_Right_Line4,y	; 4 
	LDY	temp12				; 3 
	ORA	Bank8Font_Left_Line4,y		; 4  	
	TAX					; 2 

Bank8_DynamicText_Even_Line0
	STA	WSYNC				; 76
	sleep	3

	LDY	temp09				; 3
	LDA	Bank8Font_Right_Line4,y	; 4 (7)
	LDY	temp02				; 3 (10)
	ORA	Bank8Font_Left_Line4,y		; 4 (14) 	
	STA	GRP1				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP0				; 3 (22)

	sleep	6

	LDY	temp03				; 3 (34)
	LDA	Bank8Font_Right_Line4,y	; 4 (38)
	LDY	temp07				; 3 (41)
	ORA	Bank8Font_Left_Line4,y		; 4 (45) 	
	STA	GRP1				; 3 (48)

	sleep	2

	STX	GRP1				; 3 (53)

	LDY	temp11				; 3 (56)
	LDA	Bank8Font_Right_Line3,y	; 4 (60)
	LDY	temp04				; 3 (63)
	ORA	Bank8Font_Left_Line3,y		; 4 (67) 	
	TAX					; 2 (69)

Bank8_DynamicText_Even_Line1
	STA	WSYNC				; 76
	LDY	temp01				; 3
	LDA	Bank8Font_Right_Line3,y	; 4 (7)
	LDY	temp05				; 3 (10)
	ORA	Bank8Font_Left_Line3,y		; 4 (14) 	
	STA	GRP0				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP1				; 3 (21)

	sleep	7

	LDY	temp06				; 3 (31)
	LDA	Bank8Font_Right_Line3,y	; 4 (35)
	LDY	temp10				; 3 (38)
	ORA	Bank8Font_Left_Line3,y		; 4 (42) 	
	STA	GRP0				; 3 (45)

	sleep	2

	STX	GRP0				; 3 (50)

	LDY	temp08				; 3 (53)
	LDA	Bank8Font_Right_Line2,y	; 4 (57)
	LDY	temp12				; 3 (60)
	ORA	Bank8Font_Left_Line2,y		; 4 (64) 	
	TAX					; 2 (66)

Bank8_DynamicText_Even_Line2
	STA	WSYNC				; 76
	LDY	temp09				; 3
	LDA	Bank8Font_Right_Line2,y	; 4 (7)
	LDY	temp02				; 3 (10)
	ORA	Bank8Font_Left_Line2,y		; 4 (14) 	
	STA	GRP1				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP0				; 3 (22)

	sleep	9

	LDY	temp03				; 3 (34)
	LDA	Bank8Font_Right_Line2,y	; 4 (38)
	LDY	temp07				; 3 (41)
	ORA	Bank8Font_Left_Line2,y		; 4 (45) 	
	STA	GRP1				; 3 (48)

	sleep	2

	STX	GRP1				; 3 (53)

	LDY	temp11				; 3 (56)
	LDA	Bank8Font_Right_Line1,y	; 4 (60)
	LDY	temp04				; 3 (63)
	ORA	Bank8Font_Left_Line1,y		; 4 (67) 	
	TAX		

Bank8_DynamicText_Even_Line3
	STA	WSYNC				; 76
	LDY	temp01				; 3
	LDA	Bank8Font_Right_Line1,y	; 4 (8)
	LDY	temp05				; 3 (11)
	ORA	Bank8Font_Left_Line1,y		; 4 (16) 	
	STA	GRP0				; 3 (19)

	LDA	#0				; 2 (21)
	STA	GRP1				; 3 (24)

	sleep	7

	LDY	temp06				; 3 (27)
	LDA	Bank8Font_Right_Line1,y	; 4 (32)
	LDY	temp10				; 3 (35)
	ORA	Bank8Font_Left_Line1,y		; 4 (40) 	
	STA	GRP0				; 3 (43)

	sleep	2

	STX	GRP0				; 3 (46)

	LDY	temp08				; 3 (49)
	LDA	Bank8Font_Right_Line0,y	; 4 (54)
	LDY	temp12				; 3 (57)
	ORA	Bank8Font_Left_Line0,y		; 4 (61) 	
	TAX					; 2 (63)

Bank8_DynamicText_Even_Line4
	STA	WSYNC				; 76
	LDY	temp09				; 3
	LDA	Bank8Font_Right_Line0,y	; 4 (7)
	LDY	temp02				; 3 (10)
	ORA	Bank8Font_Left_Line0,y		; 4 (14) 	
	STA	GRP1				; 3 (17)

	LDA	#0				; 2 (19)
	STA	GRP0				; 3 (22)

	sleep	9

	LDY	temp03				; 3 (34)
	LDA	Bank8Font_Right_Line0,y	; 4 (38)
	LDY	temp07				; 3 (41)
	ORA	Bank8Font_Left_Line0,y		; 4 (45) 	
	STA	GRP1				; 3 (48)

	sleep	2

	STX	GRP1				; 3 (53)

	sleep	13

Bank8_DynamicText_Reset
	LDA	#0			; 2
	STA	GRP1			; 3 
	STA	GRP0			; 3
	STA	WSYNC			; 76
	STA	COLUP0			; 3 (9)
	STA	COLUP1			; 3 (12)
	STX	HMCLR			; 3 (30)

Bank8_ReturnFromDT
	LDX	temp19
	CPX	#255
	BNE	Bank8_ReturnNoRTS
	RTS
Bank8_ReturnNoRTS
	TXA
	INX

	TAY

	ASL		
	TAY

	LDA	Bank8_Return_JumpTable,y
   	pha
   	lda	Bank8_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump

	_align	6

Bank8_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1

		_align	52

Bank8Font_Left_Line0
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001110
	BYTE	#%00000100
	BYTE	#%00000010
	BYTE	#%00001100
	BYTE	#%00000100
	BYTE	#%00001000
	BYTE	#%00000100
	BYTE	#%00001100
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00000110
	BYTE	#%00001100
	BYTE	#%00001110
	BYTE	#%00001000
	BYTE	#%00000110
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00001000
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001000
	BYTE	#%00000111
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001110
	BYTE	#%00000000
	BYTE	#%00000010
	BYTE	#%00001000
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000000

		_align	52

Bank8Font_Left_Line1
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00000010
	BYTE	#%00001110
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001001
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00000010
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00001011
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00001110
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000100

		_align	52

Bank8Font_Left_Line2
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000110
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00001110
	BYTE	#%00000010
	BYTE	#%00000100
	BYTE	#%00000110
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00001100
	BYTE	#%00001011
	BYTE	#%00001110
	BYTE	#%00000100
	BYTE	#%00000010
	BYTE	#%00001100
	BYTE	#%00001000
	BYTE	#%00001001
	BYTE	#%00000010
	BYTE	#%00001110
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001001
	BYTE	#%00000010
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00001000
	BYTE	#%00000010
	BYTE	#%00001110
	BYTE	#%00001110
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000000

		_align	52

Bank8Font_Left_Line3
	BYTE	#%00001110
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00000100
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00000010
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00001110
	BYTE	#%00001010
	BYTE	#%00000010
	BYTE	#%00000010
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000010
	BYTE	#%00000100

		_align	52

Bank8Font_Left_Line4
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000010
	BYTE	#%00001110
	BYTE	#%00000110
	BYTE	#%00001110
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001100
	BYTE	#%00000110
	BYTE	#%00001100
	BYTE	#%00001110
	BYTE	#%00001110
	BYTE	#%00000110
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00000110
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001100
	BYTE	#%00000110
	BYTE	#%00001010
	BYTE	#%00000100
	BYTE	#%00001100
	BYTE	#%00000100
	BYTE	#%00001100
	BYTE	#%00000110
	BYTE	#%00001110
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001000
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00001010
	BYTE	#%00001110
	BYTE	#%00000000
	BYTE	#%00000010
	BYTE	#%00001000
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000010
	BYTE	#%00001010
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00001100
	BYTE	#%00000000

		_align	52

Bank8Font_Right_Line0
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%11100000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%11000000
	BYTE	#%01000000
	BYTE	#%10000000
	BYTE	#%01000000
	BYTE	#%11000000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%01100000
	BYTE	#%11000000
	BYTE	#%11100000
	BYTE	#%10000000
	BYTE	#%01100000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%10000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%10000000
	BYTE	#%01110000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%11100000
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%10000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00000000

		_align	52

Bank8Font_Right_Line1
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%00100000
	BYTE	#%11100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%10010000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%00100000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%10110000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%10000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%11100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01000000

		_align	52

Bank8Font_Right_Line2
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01100000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%11100000
	BYTE	#%00100000
	BYTE	#%01000000
	BYTE	#%01100000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%11000000
	BYTE	#%10110000
	BYTE	#%11100000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%11000000
	BYTE	#%10000000
	BYTE	#%10010000
	BYTE	#%00100000
	BYTE	#%11100000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%10100000
	BYTE	#%11000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10010000
	BYTE	#%00100000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%10000000
	BYTE	#%00100000
	BYTE	#%11100000
	BYTE	#%11100000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00000000

		_align	52

Bank8Font_Right_Line3
	BYTE	#%11100000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%11100000
	BYTE	#%10100000
	BYTE	#%00100000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%01000000
		_align	52

Bank8Font_Right_Line4
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%11100000
	BYTE	#%01100000
	BYTE	#%11100000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%11000000
	BYTE	#%01100000
	BYTE	#%11000000
	BYTE	#%11100000
	BYTE	#%11100000
	BYTE	#%01100000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%01100000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%11000000
	BYTE	#%01100000
	BYTE	#%10100000
	BYTE	#%01000000
	BYTE	#%11000000
	BYTE	#%01000000
	BYTE	#%11000000
	BYTE	#%01100000
	BYTE	#%11100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%11100000
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%10000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%10100000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%11000000
	BYTE	#%00000000

Bank8_Display_Level_Name
	LDA	LevelAndCharge
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	SEC	
	SBC	#1
	TAY
	ASL
	TAX
	
	LDA	Bank8_LevelNamePointers,x
	STA	temp01
	LDA	Bank8_LevelNamePointers+1,x
	STA	temp02

	LDA	Bank8_LevelNameLenPlus,y
	STA	temp03
	SEC
	SBC	#1
	STA	temp04

* X < Y
* LDA	X	
* CMP	Y
* BCS   else 	 
*
* X <= Y
*
* LDA	Y
* CMP	X
* BCC	else
*
* X > Y 
*
* LDA	Y
* CMP	X
* BCS	else
*
* X >= Y
*
* LDA	X
* CMP	Y
* BCC 	else
Bank8_Start_Doing_Text
	LDA	TextCounter
	BPL	Bank8_Normal_Mode
	DEC	TextCounter

	LDA	TextCounter
	BMI	Bank8_No_Zeroing
	LDA	#0
	STA	TextCounter
Bank8_No_Zeroing
	LDY	#0
	JMP	Bank8_DEC_Mode
Bank8_Normal_Mode
	LDA	counter
	AND	#%00001111
	CMP	#%00001111
	BNE	Bank8_No_Reset_For_TextCounter

	INC	TextCounter
	LDA	temp04
	CMP	TextCounter
	BCS	Bank8_No_Reset_For_TextCounter
	LDA	#0
	STA	TextCounter
Bank8_No_Reset_For_TextCounter
	LDY	TextCounter
Bank8_DEC_Mode
	LDX	#0

Bank8_No_Reset_For_TextCounter_Loop
	LDA	(temp01),y
	STA	TextBuffer_W01,x

	INX
	CPX	#13		
	BEQ	Bank8_No_Reset_For_TextCounter_End

	INY
	CPY	temp03
	BNE	Bank8_No_Reset_For_TextCounter_NoZero
	LDY	#0
Bank8_No_Reset_For_TextCounter_NoZero
	JMP	Bank8_No_Reset_For_TextCounter_Loop

Bank8_No_Reset_For_TextCounter_End
	LDA	counter
	AND	#$0F
	ORA	#$10
	STA	temp18
	
	LDA	TextBuffer_R01
*	LDA	#1
	STA	temp01

	LDA	TextBuffer_R04
*	LDA	#4
	STA	temp02

	LDA	TextBuffer_R07
*	LDA	#7
	STA	temp03

	LDA	TextBuffer_R10
*	LDA	#10
	STA	temp04

	LDA	TextBuffer_R02
*	LDA	#2
	STA	temp05

	LDA	TextBuffer_R05
*	LDA	#5
	STA	temp06

	LDA	TextBuffer_R08
*	LDA	#8
	STA	temp07

	LDA	TextBuffer_R11
*	LDA	#11
	STA	temp08

	LDA	TextBuffer_R03
*	LDA	#3
	STA	temp09

	LDA	TextBuffer_R06
*	LDA	#6
	STA	temp10

	LDA	TextBuffer_R09
*	LDA	#9
	STA	temp11

	LDA	TextBuffer_R12
*	LDA	#12
	STA	temp12

	JMP	Bank8_DynamicText

	_align	2
Bank8_LevelNamePointers
	BYTE	#<Bank8_Higan_Boredom
	BYTE	#>Bank8_Higan_Boredom

	_align	1
Bank8_LevelNameLenPlus
	BYTE	#17

	_align	14
Bank8_Higan_Boredom
	BYTE	#17
	BYTE	#18
	BYTE	#16
	BYTE	#10
	BYTE	#24
	BYTE	#38
	BYTE	#11
	BYTE	#25
	BYTE	#28
	BYTE	#14
	BYTE	#13
	BYTE	#25	
	BYTE	#22
	BYTE	#23
	BYTE	#38
	BYTE	#44
	BYTE	#38
	BYTE	#38

###End-Bank8

*****	align 256
	
bank8_Start
   	sei
   	cld
   	ldy	#0
   	lda	$D0
   	cmp	#$2C		;check RAM location #1   	
	bne	bank8_MachineIs2600
   	lda	$D1
   	cmp	#$A9		;check RAM location #2   	
	bne	bank8_MachineIs2600
   	dey
bank8_MachineIs2600
	ldx	#0
  	txa
bank8_clearmem
   	inx
   	txs
   	pha
	cpx	#$00
   	bne	bank8_clearmem	; Clear the RAM.

	LDA	$F080		; Sets two values of the SC RAM 
	STA	$80		; to Random and Counter variables
	LDA	$F081
	STA	$81

	LDY	#0		
	TYA
****	STA	$F029
bank8_ClearSCRAM
	STA 	$F000,Y
	INY
	BPL 	bank8_ClearSCRAM

	lda	#>(EnterScreenBank1-1)
**	lda	#>(EnterScreenBank2-1)
   	pha
   	lda	#<(EnterScreenBank1-1)
**   	lda	#<(EnterScreenBank2-1)
   	pha
   	pha
   	pha
**  	ldx	#2
   	ldx	#1 
  	jmp	bankSwitchJump

	saveFreeBytes
	rewind 	8fd4

bankSwitchCode
 	ldx	#$ff
   	txs
   	lda	#>(bank8_Start-1)
   	pha
   	lda	#<(bank8_Start-1)
   	pha
bankSwitchReturn
	pha
	txa
   	pha
   	tsx
   	lda	4,x	; get high byte of return address	
	rol
   	rol
   	rol
   	rol
   	and	#7	
	tax
   	inx
bankSwitchJump
   	lda	$1FF4-1,x
   	pla
   	tax
   	pla
   	rts
	rewind 8ffc	   
   	.byte 	#<bank8_Start
  	.byte 	#>bank8_Start
   	.byte 	#<bank8_Start
  	.byte 	#>bank8_Start