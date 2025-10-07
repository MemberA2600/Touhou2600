*
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
PAL_Display  =  245


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
*	5-7: Level
*
eikiX = $AE
*
*	0-6: X position
*	7  : Direction
*
eikiY = $B6
*	
*	0-3: Y Position
*	  4: No More Lives Flag
*	  5: Continue Flag
*	6-7: Difficulty
*
eikiSettings = $AF
*	0-1: 3 counter
*	2-3: Color Index
*	
*	4: Moving
*	5: Attack
*	6: Spell
*	7: Dead
*
eikiSettings2 = $B0
*
*	0-3: SpriteIndex
*	4-5: CoolDown
*	  6: Invincible flag 
*	  7: DeathSoundFlag
*
DanmakuColor = $B1
StickBuffer = $B2
eikiBackColor = $B3

ScoreColorAdder = $B4
*
*	0-2: Amplitude
*	  3: DeathScreen
*	  4: Just shoot flag / Select on Death Screen
*	  5: FreezeDanmaku Flag	
*	6-7: BombsSpriteBuffer
*
IndicatorSettings = $B5
*
*	0-2: LivesSpriteCounter
* 	3-5: BombSpriteCounter
*	6-7: LivesSpriteBuffer
*
SaveHighScore = $B7
*
*	0-6: Counter
*	  7: SaveBit
*
SpellPicture = $B8
*
*	0-3: Counter
*	4-7: Index
*
LongCounter = $B9
*
*	0-5: Counter
*	  6: Any Button is Hold
*	  7: Fire must be pressed
*
LandScape = $BA
*
*	0-2: Counter
*	  3: Auto Increment 
*	4-5: Danmaku Sound
*	  6: HoldNextLoading
*	  7: Danmaku Shot
*
LevelPointer = $BB
MessagePointer = $BC
*
*	0-5: MessageID
*	  6: IgnoreNewEventHoldFlag
*	  7: Message is Displayed
*
NewLoadDelay = $BD
*
*	0-6: Counter
*	  7: Enemy is a boss
*
EnemyX = $BE 

*
* Common Enemy Stuff
*-------------------------------
*
* Since only one enemy is present at the time, 
* we can use the same memory addresses.
*
*
DeathX = $BF

EnemySettings = $C0
*
* 	0-1: NUSIZ 
*       2-7: Enemy Type
*
EnemyBackColor = $C1
EnemySpritePointer = $C2
EnemyColorPointer = $C4

EnemySettings2 = $C6
*
*	0-1: Explosion Sprite Counter
*	  2: CheckForScore Flag
*	3-5: Free to use counter
*	6-7: Free to use state
* 


*
* Boss Stuff
*------------------------------
*
BossHP = $BF
BossSettings = $C0
*
*	0-4: Boss State
*		00: Sinking LandScape
*		01: Appear and move to the center
*		02: Arrived to center, show messages
*		03: Basic attack
*	     04-13: Spellcards
* 		14: Death
*		15: Showing the endgame screen
*	5-7: Cooldown
*
BossBackColor = $C1
BossSpriteTablePointer_L_P0 = $C2
BossSpriteTablePointer_R_P0 = $C4
BossSpriteTablePointer_L_P1 = $C6
BossSpriteTablePointer_R_P1 = $C8

BossSettings2 = $CA
*
*	0-2: Sprite Index
*	3-5: Messages left
*	6-7: FREE
*	
WastingLinesCounter = $CB
*
*	0-4: Counter
*	6-7: FREE
*

Eiki_Height = 23
Eiki_HeightPlus1 = 24
NumberOfLines = 35
StickColor = $30

*
*	For Testing: Normal Mode with default lives and bombs.

	LDA	#$52
	STA	LivesAndBombs
	LDA	#%01000000
	STA	eikiY

	LDA	LandScape
	ORA	#%00001000	
	STA	LandScape

	LDA	eikiY
	ORA	#%00100000
	STA	eikiY

	LDA	#%00100000
	STA	LevelAndCharge

	LDA	#%01000000
	STA	eikiSettings2

*
	LDA	#58
	STA	eikiX

	LDA	eikiY
	AND	#%11100000
	ORA	#5
	STA	eikiY

	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

	LDA	#%01100000
	STA	temp18
	LDA	#255
	STA	temp19
	JSR	Bank1_SoundPlayer

	LDA	#0
	STA	ScoreColorAdder
	STA	eikiSettings
	STA	StickBuffer
	STA	IndicatorSettings
	STA	SaveHighScore
	STA	LongCounter
	STA	eikiSettings2
	STA	SpellPicture
	STA	eikiBackColor
	STA	LevelPointer
	STA	EnemyX
	STA	DeathX 
	STA	EnemySettings
	STA	NewLoadDelay

***	LDA	#5
	STA	NewLoadDelay

	LDA	LevelAndCharge
	AND 	#%11100000
	ORA	#%00000001
	STA	LevelAndCharge
	AND 	#%11100000
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY
	DEY

	LDA	MessagePointer
	AND	#%01000000
	ORA	Bank1_StartMessageID,y
	STA	MessagePointer

	LDA	#NumberOfLines
	LSR
	TAX
****	DEX
	LDA	#0
Bank1_Erase_PF_2
	STA	Danmaku_Col_1W,x
	STA	Danmaku_Col_2W,x
	STA	Danmaku_Col_3W,x
	STA	Danmaku_Col_4W,x

	DEX
	BPL	Bank1_Erase_PF_2

	JSR	Bank1_EraseAllDanmaku

	LDA	#$0e
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

*
*	Next New: F05E / F0DE
*

Danmaku_NumW = $F05E
Danmaku_NumR = $F0DE

*
*	We can have a max. of 8 danmakus.
*
MaxNumOfDanmaku = 8

Danmaku_SettingsW = $F05F
Danmaku_SettingsR = $F0DF

Danmaku_PozW = $F067
Danmaku_PozR = $F0E7

*
*	Next New: F06F / F0EF
*


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

	LDA	#$0e
	STA	DanmakuColor

	LDA	SpellPicture
	AND	#$0F
	CMP	#0
	BEQ	Bank1_NoSpellPictureDisplayed

	LDA	counter
	AND	#1
	CMP	#1
	BNE	Bank1_NoSpellPictureDEC

	BIT	LongCounter
	BVC	Bank1NothingToDoWithFireButton

	BIT	INPT4
	BPL	Bank1NoReleaseNoNo

	LDA	LongCounter
	AND	#%10111111
	STA	LongCounter	

Bank1NoReleaseNoNo
Bank1NothingToDoWithFireButton

	LDA	SpellPicture
	AND	#$0F
	CMP	#%00000111
	BNE	Bank1_SpellPicNotAtHalf

	BIT	LongCounter
	BPL	Bank1_NoFirePressNeeded
	BVS	Bank1_FireWasHoldAndNotReleased
	
	BIT	INPT4
	BMI	Bank1_FireWasNotPressedButNeeded
	
****	LDA	LongCounter
****	AND	#%00111111
	LDA	#0
	STA	LongCounter
	JMP	Bank1_NoSpellPictureDEC

Bank1_NoFirePressNeeded
	LDA	LongCounter	
	CMP	#0
	BEQ	Bank1_NoLongCounterDEC	

	DEC	LongCounter
	JMP	Bank1_NoSpellPictureDEC

Bank1_NoLongCounterDEC
Bank1_SpellPicNotAtHalf
	DEC	SpellPicture
	LDA	SpellPicture
	AND	#$0F
	CMP	#0
	BNE	Bank1_NoDisableMessage	

	LDA	MessagePointer
	AND	#%01111111
	STA	MessagePointer

Bank1_NoDisableMessage	
Bank1_FireWasNotPressedButNeeded
Bank1_FireWasHoldAndNotReleased
Bank1_NoSpellPictureDEC

	JMP	Bank1_WasSpellPicture
	
Bank1_NoSpellPictureDisplayed
	LDA	#$00
	STA	eikiBackColor

	ASL	StickBuffer
*
*	Turn off Danmaku Shot Flag
*
	LDA	LandScape
	AND	#%01111111
	STA	LandScape

	LDA	ScoreColorAdder
	AND	#%00001000
	CMP	#%00001000
	BNE	Bank1_EikiNoDeathScreen
Bank1_EikiDeathScreenThings

	BIT	LongCounter 
	BVS	Bank1_EikiDeathScreenButtonHold

	LDA	SWCHA
	AND	#$F0
	CMP	#$F0
	BEQ	Bank1_EikiDeathScreenNoArrowButtonPressed

	LDA	ScoreColorAdder
	EOR	#%00010000
	STA	ScoreColorAdder

	LDA	#$82
	STA	temp18
	LDA	#255
	STA	temp19

	JSR	Bank1_SoundPlayer

	JMP	Bank1_EikiDeathScreenButtonPressed
Bank1_EikiDeathScreenNoArrowButtonPressed
	BIT	INPT4	
	BMI	Bank1_EikiDeathScreenMightBeReleased

	LDA	#$88
	STA	temp18
	LDA	#255
	STA	temp19

	JSR	Bank1_SoundPlayer

	LDA	ScoreColorAdder
	AND	#%00010000
	BNE	Bank1_Player_Selected_No

Bank1_Player_Selected_Yes
	LDA	LevelAndCharge
	ORA	#%00011111
	STA	LevelAndCharge

	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

	LDA	eikiY
	ORA	#%00100000
	AND	#%11101111
	STA	eikiY

	LDA	#0
	STA	Score_1
	STA	Score_2
	STA	Score_3
	STA	Score_4
	STA	Score_5
	STA	Score_6
	STA	SaveHighScore
	STA	LongCounter

	LDA	eikiSettings
	AND	#$0F
	STA	eikiSettings

	LDA	ScoreColorAdder
	AND	#%11110111
	STA	ScoreColorAdder
	
	LDA	eikiSettings2
	ORA	#%01000000
	STA	eikiSettings2

	LDA	eikiY
	ROL
	ROL
	ROL
	AND	#%00000011
	TAX

	LDA	LivesAndBombs
	AND	#$0F
	CMP	Bank1_BombsOnDeath,x
	BCS	Bank1_DontAddBombs__
	LDA	Bank1_BombsOnDeath,x
Bank1_DontAddBombs__
	ORA	temp01
	ORA	Bank1_LivesOnContinue,x
	STA	LivesAndBombs

	JMP	Bank1_EikiNoDeathScreen
Bank1_Player_Selected_No

	BIT	SaveHighScore
	BPL	Bank1_No_High_Score_Save
Bank1_No_High_Score_Save

	LDX	#5
Bank1_No_High_Score_Save_Loop
	LDA	Score_1,x
	STA	HScore_1,x

	DEX
	BPL	Bank1_No_High_Score_Save_Loop

Bank1_No_High_Score_Save
	LDA	#0
	STA	SaveHighScore
	STA	LongCounter
	STA	LevelAndCharge
	STA	eikiSettings
	STA	eikiSettings2
	STA	ScoreColorAdder

	lda	#>(EnterScreenBank2_NoFullReset-1)
   	pha
   	lda	#<(EnterScreenBank2_NoFullReset-1)
   	pha
   	pha
   	pha
   	ldx	#2

   	jmp	bankSwitchJump

Bank1_EikiDeathScreenButtonPressed
	LDA	LongCounter
	ORA	#%01000000
	STA	LongCounter

	JMP	Bank1_DisplayingDeathScreen
Bank1_EikiDeathScreenButtonHold

	BIT	INPT4
	BPL	Bank1_EikiDeathScreenButtonNoRelease
Bank1_EikiDeathScreenMightBeReleased
	LDA	SWCHA
	AND	#$F0
	CMP	#$F0
	BNE	Bank1_EikiDeathScreenButtonNoRelease

	LDA	LongCounter
	AND	#%10111111
	STA	LongCounter

Bank1_EikiDeathScreenButtonNoRelease
	JMP	Bank1_DisplayingDeathScreen

Bank1_EikiNoDeathScreen
	BIT 	eikiSettings2
	BVC	Bank1_NoInvincibleCountDown

	LDA	counter
	AND	#%00000011
	CMP	#%00000011
	BNE	Bank1_NoInvincibleCountDown

	LDA	LevelAndCharge
	AND	#%11100000
	STA	temp01

	LDA	LevelAndCharge	
	AND	#%00011111
	SEC
	SBC	#1
	STA	LevelAndCharge	
	CMP	#0
	BNE	Bank1_NoFullRevive
	
	LDA	eikiSettings2
	AND	#%10111111
	STA	eikiSettings2

	LDA	LevelAndCharge
Bank1_NoFullRevive
	ORA	temp01
	STA	LevelAndCharge

	JMP	Bank1_CannotAttack
*
*	Attack CountDown
*
Bank1_NoInvincibleCountDown
	LDA	eikiSettings
	AND	#%11000000
	CMP	#0
	BNE	Bank1_EikiDeadOrSpell

	BIT 	eikiSettings2
	BVC	Bank1_NoTempInv

	JMP	Bank1_CannotAttack
Bank1_NoTempInv
*
*	Special: Double Click for spell!
*
	LDA	ScoreColorAdder
	AND	#%00010000
	CMP	#%00010000
	BNE	Bank1_CannotCastSpell

	BIT 	INPT4
	BMI	Bank1_CannotCastSpell

	LDA	LivesAndBombs
	AND	#$0F
	CMP	#0
	BEQ	Bank1_CannotCastSpell
	SEC
	SBC	#1
	STA	temp01

	LDA	LivesAndBombs
	AND	#$F0
	ORA	temp01
	STA	LivesAndBombs

	LDA	ScoreColorAdder
	AND	#%00111111
	ORA	#%01000000
	STA	ScoreColorAdder

	LDA	IndicatorSettings
	AND	#%11000111
	ORA	#%00001000
	STA	IndicatorSettings

	LDA	LevelAndCharge
	ORA	#%00011111
	STA	LevelAndCharge

	LDA	eikiSettings
	ORA	#%01000000
	AND	#%11011111
	STA	eikiSettings

	LDA	eikiSettings2
	AND	#%11001111
	STA	eikiSettings2
*
*	Display Eiki Picture For 15 (?) frames
*
	LDA	#$0F
	STA	SpellPicture

	LDA	#%01100000
	STA	temp18
	LDA	#255
	STA	temp19

	JSR	Bank1_SoundPlayer

	LDA	#$88
	STA	temp18

	JSR	Bank1_SoundPlayer
	
	LDA	#%00010111
	STA	LongCounter

	JSR	Bank1_EraseAllDanmaku

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

	LDA	ScoreColorAdder
	ORA	#%00010000
	STA	ScoreColorAdder

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
	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

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

	LDA	#$82
	STA	temp18
	LDA	#255
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
	BNE	Bank1_Eiki_Whatever

	LDA	counter
	AND	#%00000111
	CMP	#%00000111
	BNE	Bank1_NoDECSpellCounter

	LDA	#$81
	STA	temp18
	LDA	#255
	STA	temp19

	JSR	Bank1_SoundPlayer
	LDA	LevelAndCharge
	AND	#%11100000
	STA	temp01	

	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

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

	JSR	Bank1_EraseAllDanmaku

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
	AND	#$F0
	STA	temp01

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
	ORA	temp01
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

	JMP	Bank1_Eiki_Whatever
Bank1_EikiDied
	LDA	LevelAndCharge
	AND	#%11100000
	STA	temp01

	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

	LDA	LevelAndCharge
	AND	#%00011111
	CLC
	ADC	#1
	STA	LevelAndCharge
	CMP	#%00011111
	BNE	Bank1_Eiki_NoRevive
*
*	NoMoreLives
*
	LDA	eikiY
	AND	#%00010000
	CMP	#%00010000
	BNE	Bank1_Eiki_Revive
*
*	SetDeathScreen
*
	LDA	ScoreColorAdder
	ORA	#%00001000
	STA	ScoreColorAdder

	JMP	Bank1_Eiki_NoRevive
Bank1_Eiki_Revive
	LDA	eikiSettings
	AND	#%01111111
	STA	eikiSettings

	LDA 	eikiSettings2
	ORA	#%01000000
	STA	eikiSettings2

	BIT	INPT4
	BPL	Bank1_Button_Pressed_On_Death_
	LDA	SWCHA
	AND	#$F0
	CMP	#$F0
	BEQ	Bank1_NoButton_Pressed_On_Death	
*
*	Set continue on "YES".
*
Bank1_Button_Pressed_On_Death_
	LDA	LongCounter
	ORA	#%01000000	
	JMP	Bank1_Button_Pressed_On_Death
Bank1_NoButton_Pressed_On_Death
	LDA	LongCounter
	AND	#%10111111
Bank1_Button_Pressed_On_Death
	STA	LongCounter

	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

	LDA	LevelAndCharge
Bank1_Eiki_NoRevive
	ORA	temp01
	STA	LevelAndCharge

Bank1_Eiki_Whatever
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
	LDA	LevelAndCharge
	AND	#%00011111
	LSR
	LSR
	LSR
	CLC
	ADC	#7
	STA	temp01

	LDA	eikiSettings2
	AND	#$F0
	ORA	temp01
	STA	eikiSettings2

	LDA	eikiSettings
	ORA	#%00001100
	STA	eikiSettings

	LDA	LevelAndCharge
	LSR
	AND	#$0F
	ORA	#$40
	STA	eikiBackColor

**	LDA	#0
**	STA	DanmakuColor

	JMP	Bank1_EikiGotSpritePointer
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

	LDA	#NumberOfLines
	LSR
	TAX
***	DEX
Bank1_Erase_PF
	LDA	#0

	STA	Danmaku_Col_1W,x
	STA	Danmaku_Col_2W,x
	STA	Danmaku_Col_3W,x
	STA	Danmaku_Col_4W,x

	DEX
	BPL	Bank1_Erase_PF

Bank1_Fill_PF_Ended

	LDA	counter
	AND	#%01111111
	CMP	#%01111111
	BNE	Bank1_DontAdd1Point

	LDX	#5	
Bank1_SaveTempsLoop
	LDA	Score_1,x
	STA	temp01,x
	DEX	
	BPL	Bank1_SaveTempsLoop

	CLC
	SED	

	LDA	Score_6
	ADC	#$01
	STA	Score_6

	LDA	Score_5
	ADC	#0
	STA	Score_5
	
	LDA	Score_4
	ADC	#0
***	ADC	#$50
	STA	Score_4	

	LDA	Score_3
	ADC	#0
***	ADC	#$03
	STA	Score_3	

	LDA	Score_2
	ADC	#0
	STA	Score_2	

	LDA	Score_1
	ADC	#0
	STA	Score_1	

	JSR	Bank1_CheckForPoints

	LDA	temp18
	CMP	#0
	BEQ	Bank1_NoSoundChange

	LDA	#255
	STA	temp19
	JSR	Bank1_SoundPlayer

Bank1_NoSoundChange

	LDA	ScoreColorAdder
	ORA	#%00000111
	STA	ScoreColorAdder

	CLD
Bank1_DontAdd1Point
Bank1_WasSpellPicture
Bank1_DisplayingDeathScreen

	LDA	eikiSettings
	AND	#%11000000
	CMP	#0
	BEQ	Bank1_MaybeDanmakuSound

	LDA	LandScape
	AND	#%11001111
	STA	LandScape
Bank1_MaybeDanmakuSound
	LDA	 LandScape
	AND	 #%00110000
	LSR
	LSR
	LSR
	LSR
	CMP	#0
	BEQ	Bank1_NoDanmakuSound

	TAY
	LDA	Bank1_DanmakuSound,y
	STA	temp18

	LDA	#255
	STA	temp19
	JSR	Bank1_SoundPlayer


	LDA	LandScape	
	AND	#%11001111
	STA	LandScape
Bank1_NoDanmakuSound
*
*	No Next Load If:
*	-The hold next loading flag is set
*	-A message is displayed
*	-Deathscreen is displayed
*	-Spellpicture is displayed
*	-If enemy is present, no load if:
*         -The enemy is not a boss
*         -The enemy is a boss and ignore flag is not set.
*

	BIT	LandScape
	BVS	Bank1_NoNextEventLoad
	
	BIT 	MessagePointer
	BMI	Bank1_NoNextEventLoad
	
	LDA	ScoreColorAdder
	AND	#%00001000
	CMP	#%00001000
	BEQ	Bank1_NoNextEventLoad

	LDA	EnemyX
	CMP	#0
	BEQ	Bank1_Bank1NoEnemyPresent

	BIT	NewLoadDelay
	BPL	Bank1_NoNextEventLoad

	BIT 	MessagePointer
	BVC	Bank1_NoNextEventLoad

Bank1_Bank1NoEnemyPresent
	LDA	SpellPicture
	AND	#$0F
	CMP	#0
	BNE	Bank1_NoNextEventLoad

	LDA	NewLoadDelay
	AND	#%01111111
	CMP	#0
	BEQ	Bank1_Bank1DelayCounterIs0
	
	SEC
	SBC	#1
	STA	temp01
	
	LDA	NewLoadDelay
	AND	#%10000000
	ORA	temp01
	STA	NewLoadDelay

	JMP	Bank1_NoNextEventLoad

Bank1_Bank1DelayCounterIs0
	JSR	Bank1_NextEvent

Bank1_NoNextEventLoad

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

Bank1_EnemyStuff
	DEC 	EnemyBackColor
	LDA	EnemyBackColor
	AND	#$0F
	CMP	#$0F
	BNE	Bank7_NoZeroEnemyBackColor

	LDA	#$00
	STA	EnemyBackColor 
Bank7_NoZeroEnemyBackColor

	BIT	MessagePointer
	BMI	Bank1_MessageGameOverSpell

	LDA	ScoreColorAdder
	AND	#%00001000
	CMP	#%00001000
	BEQ	Bank1_MessageGameOverSpell

	LDA	SpellPicture
	AND	#$0F
	CMP	#0
	BNE	Bank1_MessageGameOverSpell

	LDA	EnemyX
	CMP	#0
	BNE	Bank1_EnemyCurrent

	LDA	#<Bank6_Enemy_Sprite_Empty
	STA	EnemySpritePointer
	LDA	#>Bank6_Enemy_Sprite_Empty
	STA	EnemySpritePointer+1

	JMP	Bank1_DoneEnemyStuff
Bank1_EnemyCurrent
	JSR	Bank1_HandTheEnemy

	BIT	NewLoadDelay
	BPL	Bank1_NormalEnemyBullShit
	JMP	Bank1_BossBullShitOnly

Bank1_NormalEnemyBullShit

	LDA	EnemySettings2
	AND	#%00000100
	CMP	#%00000100
	BNE	Bank1_NoEnemyDeath

	LDA	EnemySettings2
	AND	#%11111011
	STA	EnemySettings2

	LDX	#4	
Bank1_SaveTempsLoop2
	LDA	Score_1,x
	STA	temp01,x
	DEX	
	BPL	Bank1_SaveTempsLoop2

	CLC
	SED	
	
	LDA	Score_5
	ADC	temp07
	STA	Score_5

	LDA	Score_4
	ADC	#0
	STA	Score_4	

	LDA	Score_3
	ADC	#0
	STA	Score_3	

	LDA	Score_2
	ADC	#0
	STA	Score_2	

	LDA	Score_1
	ADC	#0
	STA	Score_1	

	JSR	Bank1_CheckForPoints

	LDA	temp18
	CMP	#0
	BEQ	Bank1_NoSoundChange2

	LDA	#255
	STA	temp19
	JSR	Bank1_SoundPlayer

Bank1_NoSoundChange2

	LDA	ScoreColorAdder
	ORA	#%00000111
	STA	ScoreColorAdder

	CLD

Bank1_NoEnemyDeath
Bank1_DoneEnemyStuff

	LDA	DeathX
	CMP	#0
	BNE	Bank1_ThereIsBoom

	LDA	EnemySettings2
	ORA	#3
	STA	EnemySettings2
	JMP	Bank1_ThereWasNoBoom		

Bank1_ThereIsBoom
	LDA	counter
	AND	#3
	CMP	#3
	BNE	Bank1_DontIncrementBoom

	LDA	EnemySettings2
	AND	#%11111100
	STA	temp01

	LDA	EnemySettings2
	AND	#3
	CLC
	ADC	#1	
	TAX
	ORA	temp01
	STA	EnemySettings2
	
	AND	#3
	CMP	#3
	BNE	Bank1_DontSetXTo0	

	LDA	#0
	STA	DeathX

Bank1_BossBullShitOnly

Bank1_DontSetXTo0	
Bank1_ThereWasNoBoom	
Bank1_MessageGameOverSpell
Bank1_DontIncrementBoom

	LDA	LandScape
	AND	#%00001000
	CMP	#%00001000
	BNE	Bank1_NoLandScapeStuff

	BIT	eikiSettings
	BMI	Bank1_NoLandScapeStuff

	LDA	MessagePointer
	BMI	Bank1_NoLandScapeStuff

	LDA	counter
	AND	#7
	CMP	#7
	BNE	Bank1_NoLandScapeStuff

	LDA	LandScape
	AND	#%11111000
	STA	temp01

	LDA	LandScape
	AND	#7
	CLC
	ADC	#1
	AND	#7	
	ORA	temp01
	STA	LandScape
Bank1_NoLandScapeStuff

	LDA	eikiX			
	AND	#%01111111
	STA	temp11
	STA	temp12				; 11 

	CLC
	ADC	#4
	STA	temp13				; 7

	lda	counter
	and	#1
	tax
	LDA	Bank1M1AddX,x
	CLC
	ADC	temp11
	STA	temp14

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

	LDA	eikiSettings2
	BPL	Bank1_NoHitSound

	AND	#%01111111
	STA	eikiSettings2

	LDA	#$84
	STA	temp18
	LDA	#255
	STA	temp19
	JSR	Bank1_SoundPlayer

	BIT	eikiSettings
	BPL	Bank1_JustAnEnemyDied	

	LDA	LivesAndBombs
	AND	#$F0
	CMP	#0
	BEQ	Bank1_WasLastLife
	SEC
	SBC	#%00010000
	STA	temp01

	LDA	eikiY
	ROL
	ROL
	ROL
	AND	#%00000011
	TAX

	LDA	LivesAndBombs
	AND	#$0F
	CMP	Bank1_BombsOnDeath,x
	BCS	Bank1_DontAddBombs
	LDA	Bank1_BombsOnDeath,x
Bank1_DontAddBombs
	ORA	temp01
	STA	LivesAndBombs

	JMP	Bank1_WasNotTheLastOne
Bank1_WasLastLife
	LDA	eikiY
	ORA	#%00010000
	STA	eikiY
Bank1_WasNotTheLastOne
	LDA	IndicatorSettings
	AND	#%00111000
	ORA	#%01000001
	STA	IndicatorSettings

	LDA	ScoreColorAdder
	AND	#%11101111
	STA	ScoreColorAdder

	LDA	LevelAndCharge
	ORA	#%00011111
	STA	LevelAndCharge

Bank1_JustAnEnemyDied	
Bank1_NoHitSound
	LDA	counter
	AND	#%00000111
	CMP	#%00000111
	BNE	Bank1_NoIndicatorSpriteUpdate

	JSR	Bank1_SetIndicatorSprites
****	JSR	Bank1_CallDummy
Bank1_NoIndicatorSpriteUpdate

	LDA	eikiSettings
	AND	#%11000000
	CMP	#0
	BNE	Bank1_NoDanmakuHandleDeadOrSpell

*	LDA	eikiY
*	AND	#%11000000
*	ROL
*	ROL
*	ROL
*	TAY

**	LDA	counter
**	AND	Bank1_Danmaku_Speed_Delay,y
**	CMP	Bank1_Danmaku_Speed_Delay,y
**	BNE	Bank1_NoDanmakuHandleDeadOrSpell

	JSR	Bank1_HandleDanmaku
Bank1_NoDanmakuHandleDeadOrSpell
*
*	TestDanmakuThings
*

*	LDA	#$02
*	BIT	SWCHB
*	BNE	Bank1_NoDanmakuTestThisTime

*	LDA	counter
*	AND	#%00011111
*	CMP	#%00011111
*	BNE	Bank1_NoDanmakuTestThisTime

*	JSR	Bank1_TestDanmakuAdd
*Bank1_NoDanmakuTestThisTime

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

****	JSR	Bank1_TestLines

BossCorrector = 17

	BIT	MessagePointer
	BPL	Bank1_NoMessageDisplayed
	
	LDX	#BossCorrector 
Bank1_BossCorr1	
	STA	WSYNC
	DEX
	BPL	Bank1_BossCorr1

	JSR	Bank1_Display_Name

	LDA	MessagePointer
	AND	#%00111111
	TAX
	LDA	Bank1_TextPointer_For_Message,x
	STA	temp17

	LDA	#$1e
	STA	temp18
	
	JSR	Bank1_Display_Message
	STA	WSYNC

	JMP	Bank1_MoveOnWithMain
Bank1_NoMessageDisplayed

	BIT 	NewLoadDelay
	BMI	Bank1_BossModeOn

	LDX	#BossCorrector 
Bank1_BossCorr2
	STA	WSYNC
	DEX
	BPL	Bank1_BossCorr2

	JSR	Bank1_DrawCommonEnemies

	JMP	Bank1_MoveOnWithMain
Bank1_BossModeOn
	LDA	BossSettings
	AND	#15
	CMP	#0
	BNE	Bank1_TrueBossModeOn

	LDA	WastingLinesCounter
	AND	#$0F
	TAX
	LDA	Bank1_VerySpecialCorrectorNumber,x
	TAX

Bank1_BossCorr3
	STA	WSYNC
	DEX
	BPL	Bank1_BossCorr3


	JMP	Bank1_MoveOnWithMain
Bank1_TrueBossModeOn


	JSR	Bank1_DrawBossThings

Bank1_MoveOnWithMain
****	JSR	Bank1_TestLine

	LDA	#%00000101
	STA	CTRLPF

	LDA	ScoreColorAdder
	AND	#%00001000
	CMP	#%00001000
	BNE	Bank1_NoGameOverScreen
	
	JSR	Bank1_DisplayDeathScreen
**	STA	WSYNC
	STA	WSYNC

	JMP	Bank1_Main_Ended

Bank1_NoGameOverScreen
	LDA	SpellPicture
	AND	#$0F
	CMP	#0
	BEQ	Bank1_Eiki_Field
**	LDA	#%00000001
**	STA	SpellPicture

	JSR	Bank1_DisplaySpellCardFace
**	STA	WSYNC
	STA	WSYNC

	JMP	Bank1_Main_Ended

Bank1_Eiki_Field
	lda	#>(Bank8_Eiki_Field-1)
   	pha
   	lda	#<(Bank8_Eiki_Field-1)
Bank1_JMPto8
   	pha
   	pha
   	pha
   	ldx	#8

   	jmp	bankSwitchJump

Bank1_ResetThings

	LDA	#0
	STA	WSYNC
****	STA	PF0
	STA	PF1
	STA	PF2
	STA	GRP0
	STA	GRP1

	LDX	#2
Bank1_Waste_To_Be_Sync
	STA	WSYNC
	DEX
	BPL 	Bank1_Waste_To_Be_Sync

*	LDA	#$1E
*	STA	WSYNC
*	STA	COLUBK
*
*	Check Collisions
*

	BIT	CXM0FB
	BPL	Bank1_NotHitOnBox
	BIT	eikiSettings
	BMI	Bank1_EikiAlreadyDead
	BIT	eikiSettings
	BVS	Bank1_EikiUsedSpellSoNoHit
	BIT 	eikiSettings2
	BVS	Bank1_TemporalInvincibility

	LDA	DanmakuColor
	AND	#%00001100
	CMP	#0
	BEQ	Bank1_DanmakuIsNotDamaging

*
*	Set counter for sprite
*
	LDA	LevelAndCharge
	AND	#%11100000
	STA	LevelAndCharge

	LDA	eikiSettings
	ORA	#%10000000
	AND	#%10001111
	STA	eikiSettings

	LDA	eikiSettings2
	ORA	#%10000000
	STA	eikiSettings2

*	LDA	#$84
*	STA	temp18
*	LDA	#255
*	STA	temp19
***	JSR	Bank1_SoundPlayer
	JMP	Bank1_NoExtraSleeps

Bank1_NotHitOnBox
**	sleep	5
Bank1_EikiAlreadyDead
**	sleep	5
Bank1_EikiUsedSpellSoNoHit
**	sleep	5
Bank1_TemporalInvincibility
Bank1_DanmakuIsNotDamaging
*	STA	WSYNC
*	STA	WSYNC
	STA	WSYNC
Bank1_NoExtraSleeps

	ldx	stack
	txs	
	STA	CXCLR

Bank1_Main_Ended

	LDA	#$00
	STA	WSYNC
	STA	COLUPF

	LDA	NewLoadDelay
	BPL	Bank1_NotABossAtAll

	LDA	BossSettings
	AND	#%00111111
	CMP	#0
	BNE	Bank1_NoLandScapeOnBoss
Bank1_NotABossAtAll

	JSR	Bank1_LandScape
Bank1_NoLandScapeOnBoss
***	JSR	Bank1_TestLines
	JSR	Bank1_DrawScore
	JSR	Bank1_LivesAndBombs

	LDA	#0
	STA	WSYNC		; (76)
	STA	COLUBK	
	STA	COLUP0
	STA	COLUP1	
	STA	COLUPF	
	STA	PF0

	ldx	stack
	txs

	JMP	OverScanBank1

*Data Section 
*----------------------------------
* Here goes the data used by
* custom ScreenTop and ScreenBottom
* elments.
*

	_align	16
Bank1_VerySpecialCorrectorNumber
	BYTE	#44
	BYTE	#44
	BYTE	#44
	BYTE	#44
	BYTE	#44
	BYTE	#49
	BYTE	#49
	BYTE	#49
	BYTE	#49
	BYTE	#53
	BYTE	#53
	BYTE	#53
	BYTE	#56
	BYTE	#56
	BYTE	#58
	BYTE	#59

	_align	1
Bank1_StartMessageID
	BYTE	#0

	_align	1
Bank1_TextPointer_For_Message
	BYTE	#1

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

	_align	14

Bank1_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1
*
*	AUDC0 / AUDC1
*
	_align  11
Bank1_SoundChannels
	BYTE	#14
	BYTE	#3
	BYTE	#9
	BYTE	#2
	BYTE	#8
	BYTE	#12
	BYTE	#4
	BYTE	#1
	BYTE	#4
	BYTE	#15
	BYTE	#7
*
*	Must be between 1-15
*
	_align 	11
Bank1_Durations
	BYTE	#6
	BYTE	#10
	BYTE	#4
	BYTE	#8
	BYTE	#7
	BYTE	#10
	BYTE	#10
	BYTE	#13
	BYTE	#14
	BYTE	#3
	BYTE	#10

*
*	This os the first freq played. Cannot reach above 15.
*
	_align	11
Bank1_StartFreqs
	BYTE	#4
	BYTE	#6
	BYTE	#7
	BYTE	#3
	BYTE	#3
	BYTE	#15
	BYTE	#15
	BYTE	#14
	BYTE	#14
	BYTE	#7
	BYTE	#3
*
*	Low  Nibble: Small counter for one note.
*	High Nibble: Behaviour of the freq:
*                    0: No change
*		     1: INC (lower the voice)
*		     2: DEC (higher the voice)	
*		     3: Vibratio	
*
	_align	11
Bank1_EffectSettings
	BYTE	#$12
	BYTE	#$33
	BYTE	#$21
	BYTE	#$33
	BYTE	#$23
	BYTE	#$32
	BYTE	#$32
	BYTE	#$23
	BYTE	#$25
	BYTE	#$21
	BYTE	#$14

	_align	2
Bank1_FreqAdder
	BYTE	#8
	BYTE	#248

	_align	4
Bank1_LivesOnContinue
	BYTE	#$70
	BYTE	#$50
	BYTE	#$30
	BYTE	#$30

	_align	4
Bank1_BombsOnDeath
	BYTE	#4
	BYTE	#2
	BYTE	#2
	BYTE	#2

	_align	2
Bank1_DanmakuSound
	BYTE	#$89
	BYTE	#$89
	BYTE	#$8A
**	_align	4
**Bank1_Danmaku_Speed_Delay
**	BYTE	#7
**	BYTE	#3
**	BYTE	#3
**	BYTE	#1

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
*	4: 	FREE
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
*	0-1: One Note Duration for Channel0
*	2-3: One Note Duration for Channel1
*	4-5: Freq Changer C0
*	6-7: Freq Changer C1
*
SoundIDs = $98
*	low  nibble: channel0
*	high nibble: channel1
* 
SoundFreqs = $99
*	low  nibble: channel0
*	high nibble: channel1

SoundPlayer_BaseVol = 6

Bank1_SoundPlayer

	LDA	temp18
	BMI	Bank1_RegisterNewSound
	AND	#%01100000
	CMP	#0
	BNE	Bank1_MuteChannels
	JMP	Bank1_PlaySound

Bank1_MuteChannels
	ASL	
	STA	temp18

	BPL	Bank1_NoChannel1_Mute
	JSR	Bank1_MuteChannel1
Bank1_NoChannel1_Mute
	BIT	temp18
	BVC	Bank1_NoChannel0_Mute
	JSR	Bank1_MuteChannel0
Bank1_NoChannel0_Mute
	JMP	Bank1_ReturnFromSP

Bank1_MuteChannel1
	LDA	SoundCounters
	AND	#$0F
	STA	SoundCounters

	LDA	SoundIDs
	AND	#$0F
	STA	SoundIDs

	LDA	SoundSettings
	AND	#%00110011
	STA	SoundSettings

	LDA	#0
	STA	AUDV1

	RTS

Bank1_MuteChannel0
	LDA	SoundCounters
	AND	#$F0
	STA	SoundCounters

	LDA	SoundIDs
	AND	#$F0
	STA	SoundIDs

	LDA	SoundSettings
	AND	#%11001100
	STA	SoundSettings

	LDA	#0
	STA	AUDV0

	RTS

Bank1_RegisterNewSound
	LDA	temp18
	AND	#%00001111
	STA	temp18
	TAX

	LDA	SoundCounters
	AND	#$0F
	CMP	#0
	BNE	Bank1_NOTFoundChannel_3
	JMP	Bank1_FoundChannel
Bank1_NOTFoundChannel_3
	LDA	SoundCounters
	AND	#$F0
	CMP	#0
	BNE	Bank1_NOTFoundChannel_4
	LDY	#1
	JMP	Bank1_FoundChannel
Bank1_NOTFoundChannel_4	
	LDA	SoundSettings
	AND	#%11000000
	CMP	#0
	BEQ	Bank1_LoopIsNotRelevant
	CMP	#%11000000
	BEQ	Bank1_LoopIsNotRelevant
	
	BPL	Bank1_NOTFoundChannel_5
	JMP	Bank1_FoundChannel
Bank1_NOTFoundChannel_5	
	LDY	#1
	JMP	Bank1_FoundChannel
	
Bank1_LoopIsNotRelevant
	LDA	SoundIDs
	AND	#$0F
	CMP	temp18
	BNE	Bank1_NOTFoundChannel_1
	JMP	Bank1_FoundChannel

Bank1_NOTFoundChannel_1
	LDA	SoundIDs
	LSR
	LSR
	LSR
	LSR
	CMP	temp18
	BNE	Bank1_NOTFoundChannel_2
	LDY	#1
	JMP	Bank1_FoundChannel

Bank1_NOTFoundChannel_2
	LDA	SoundCounters
	AND	#$0F
	STA	temp01

	LDA	SoundCounters
	LSR
	LSR
	LSR
	LSR
	STA	temp01

	LDA	temp02
	CMP	temp01
	BCC	Bank1_FoundChannel
	LDY	#1

Bank1_FoundChannel

	LDA	Bank1_Durations,x
	STA	temp02

	LDA	Bank1_StartFreqs,x
	STA	temp03	

	LDA	Bank1_EffectSettings,x	
	STA	temp04

	CPY	#1
	BEQ	Bank1_SetSettingsForC1

	LDA	SoundCounters
	AND	#$F0
	ORA	temp02
	STA	SoundCounters

	LDA	SoundFreqs
	AND	#$F0
	ORA	temp03	
	STA	SoundFreqs

	LDA	SoundIDs	
	AND	#$F0
	ORA	temp18	
	STA	SoundIDs

	LDA	Bank1_SoundChannels,x
	STA	AUDC0

	LDA	SoundSettings
	AND	#%11001100
	ORA	temp04
	STA	SoundSettings

	JMP	Bank1_ReturnFromSP
	
Bank1_SetSettingsForC1
	LDA	SoundCounters
	AND	#$0F	
	STA	SoundCounters

	LDA	SoundFreqs
	AND	#$0F	
	STA	SoundFreqs

	LDA	SoundIDs
	AND	#$0F	
	STA	SoundIDs

	LDA	Bank1_SoundChannels,x
	STA	AUDC1

	LDA	SoundSettings	
	AND	#%00110011
	STA	SoundSettings

	LDA	temp04
	ASL
	ASL
	ORA	SoundSettings
	STA	SoundSettings

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
	ORA	SoundFreqs
	STA	SoundFreqs

	LDA	temp18
	ASL
	ASL
	ASL
	ASL
	ORA	SoundIDs
	STA	SoundIDs

	JMP	Bank1_ReturnFromSP

Bank1_PlaySound
Bank1_PlaySound_0

	LDA	SoundSettings
	AND	#%00000011
	SBC	#1
	CMP	#255
	BEQ	Bank1_DecrementTheBigCounter0
	STA	temp01

	LDA	SoundSettings
	AND	#%11111100
	ORA	temp01
	STA	SoundSettings
	JMP	Bank1_ReturnFromSP

Bank1_DecrementTheBigCounter0
	LDA	SoundIDs
	AND	#$0F
	TAX
	LDA	Bank1_EffectSettings,x	
	AND	#$0F
	STA	temp01

	LDA	SoundSettings
	AND	#%11111100
	ORA	temp01
	STA	SoundSettings

	LDA	SoundCounters
	AND	#$0F
	CMP	#0
	BNE	Bank1_PlaySound0
	JMP	Bank1_Sound0IsEmpty

Bank1_PlaySound0
	TAX
	DEX

	CPX	#0
	BNE	Bank1_Sound0_Generate

	JSR	Bank1_MuteChannel0
	JMP	Bank1_Sound0IsEmpty

Bank1_Sound0_Generate
	LDY	#SoundPlayer_BaseVol

	TXA
	CMP	#SoundPlayer_BaseVol
	BCS	Bank1_SaveVol0
	TAY
Bank1_SaveVol0
	STY	AUDV0

	LDA	SoundFreqs
	AND	#$0F
	TAY

	LDA	SoundSettings
	AND	#%00110000
	LSR
	LSR
	LSR
	LSR
	CMP	#0
	BEQ	Bank1_SaveFreq0
	CMP	#1
	BEQ	Bank1_INCFreq0
	CMP	#2
	BEQ	Bank1_DECFreq0

	LDA	counter
	AND	#3
	CMP	#3
	BNE	Bank1_SaveFreq0

	STY	temp01
	LDA	counter
	AND	#4
	LSR
	LSR

	TAY
	LDA	Bank1_FreqAdder,y
	CLC
	ADC	temp01
	TAY

	JMP	Bank1_SaveFreqAndVar0

Bank1_INCFreq0
	INY
	JMP	Bank1_SaveFreqAndVar0

Bank1_DECFreq0
	DEY

Bank1_SaveFreqAndVar0
	LDA	SoundFreqs
	AND	#$F0
	STA	SoundFreqs

	TYA	
	ORA	SoundFreqs
	STA	SoundFreqs
Bank1_SaveFreq0
	STY	AUDF0

	LDA	SoundCounters
	AND	#$F0
	STA	SoundCounters

	TXA
	ORA	SoundCounters
	STA	SoundCounters		

Bank1_Sound0IsEmpty
Bank1_PlaySound_1
	LDA	SoundSettings
	AND	#%00001100
	LSR
	LSR
	SBC	#1
	CMP	#255
	BEQ	Bank1_DecrementTheBigCounter1
	ASL
	ASL
	STA	temp01

	LDA	SoundSettings
	AND	#%11110011
	ORA	temp01
	STA	SoundSettings
	JMP	Bank1_ReturnFromSP

Bank1_DecrementTheBigCounter1
	LDA	SoundIDs
	AND	#$F0
	LSR
	LSR
	LSR
	LSR

	TAX
	LDA	Bank1_EffectSettings,x	
	AND	#$0F
	ASL
	ASL
	STA	temp01

	LDA	SoundSettings
	AND	#%11110011
	ORA	temp01
	STA	SoundSettings


	LDA	SoundCounters
	LSR
	LSR
	LSR
	LSR
	CMP	#0
	BNE	Bank1_PlaySound1
	JMP	Bank1_Sound1IsEmpty

Bank1_PlaySound1
	TAX
	DEX

	CPX	#0
	BNE	Bank1_Sound1_Generate
	JSR	Bank1_MuteChannel1
	JMP	Bank1_Sound1IsEmpty

Bank1_Sound1_Generate
	LDY	#SoundPlayer_BaseVol
	
	TXA
	CMP	#SoundPlayer_BaseVol
	BCS	Bank1_SaveVol1
	TAY
Bank1_SaveVol1
	STY	AUDV1

	LDA	SoundFreqs
	LSR
	LSR
	LSR
	LSR
	TAY

	LDA	SoundSettings
	AND	#%11000000
	ROR
	ROR
	ROR
	CMP	#0
	BEQ	Bank1_SaveFreq1
	CMP	#1
	BEQ	Bank1_INCFreq1
	CMP	#2
	BEQ	Bank1_DECFreq1

	LDA	counter
	AND	#3
	CMP	#3
	BNE	Bank1_SaveFreq1

	STY	temp01
	LDA	counter
	AND	#4
	LSR
	LSR

	TAY
	LDA	Bank1_FreqAdder,y
	CLC
	ADC	temp01
	TAY

	JMP	Bank1_SaveFreqAndVar1

Bank1_INCFreq1
	INY
	JMP	Bank1_SaveFreqAndVar1

Bank1_DECFreq1
	DEY

Bank1_SaveFreqAndVar1
	LDA	SoundFreqs
	AND	#$0F
	STA	SoundFreqs

	TYA
	ASL
	ASL
	ASL
	ASL	
	ORA	SoundFreqs
	STA	SoundFreqs
Bank1_SaveFreq1
	STY	AUDF1

	LDA	SoundCounters
	AND	#$0F
	STA	SoundCounters

	TXA
	ASL
	ASL
	ASL
	ASL
	ORA	SoundCounters
	STA	SoundCounters		

Bank1_Sound1IsEmpty
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

Bank1_DrawScore
	lda	#>(Bank5_Display_Score-1)
   	pha
   	lda	#<(Bank5_Display_Score-1)
Bank1_JMPto5
   	pha
   	pha
   	pha
   	ldx	#5

	LDA	#0
	STA	temp19

   	jmp	bankSwitchJump

Bank1_LivesAndBombs
	lda	#>(Bank5_ShowLivesAndBombs-1)
   	pha
   	lda	#<(Bank5_ShowLivesAndBombs-1)
   	jmp	Bank1_JMPto5

Bank1_SetIndicatorSprites
	lda	#>(Bank5_SetIndicatorSprites-1)
   	pha
   	lda	#<(Bank5_SetIndicatorSprites-1)
   	jmp	Bank1_JMPto5

Bank1_CheckForPoints
	lda	#>(Bank5_CheckForPoints-1)
   	pha
   	lda	#<(Bank5_CheckForPoints-1)
   	jmp	Bank1_JMPto5
	
Bank1_DisplaySpellCardFace
	lda	#>(Bank5_DisplaySpellCardFace-1)
   	pha
   	lda	#<(Bank5_DisplaySpellCardFace-1)
   	jmp	Bank1_JMPto5

Bank1_DisplayDeathScreen
	lda	#>(Bank5_DisplayDeathScreen-1)
   	pha
   	lda	#<(Bank5_DisplayDeathScreen-1)
   	jmp	Bank1_JMPto5
		
Bank1_LandScape
	lda	#>(Bank6_LandScape-1)
   	pha
   	lda	#<(Bank6_LandScape-1)
Bank1_JMPto6
   	pha
   	pha
   	pha
   	ldx	#6

	LDA	#0
	STA	temp19

   	jmp	bankSwitchJump

Bank1_HandleDanmaku
	lda	#>(Bank7_HandleDanmaku-1)
   	pha
   	lda	#<(Bank7_HandleDanmaku-1)
Bank1_JMPto7
   	pha
   	pha
   	pha
   	ldx	#7

	LDA	#0
	STA	temp19

   	jmp	bankSwitchJump

*Bank1_TestDanmakuAdd
*	lda	#>(Bank7_TestDanmakuAdd-1)
*  	pha
* 	lda	#<(Bank7_TestDanmakuAdd-1)
*	JMP	Bank1_JMPto7

Bank1_EraseAllDanmaku
	LDA	#0
	STA	Danmaku_NumW

	LDX	#MaxNumOfDanmaku
	DEX
Bank1_Erase_Danmakus
	STA	Danmaku_SettingsW,x
	STA	Danmaku_PozW,x
	DEX
	BPL	Bank1_Erase_Danmakus

	RTS

Bank1_NextEvent
	lda	#>(Bank7_NextEvent-1)
  	pha
 	lda	#<(Bank7_NextEvent-1)
	JMP	Bank1_JMPto7

Bank1_Display_Name
	lda	#>(Bank6_Display_Name-1)
  	pha
 	lda	#<(Bank6_Display_Name-1)
	JMP	Bank1_JMPto6

Bank1_HandTheEnemy
	lda	#>(Bank7_HandTheEnemy-1)
  	pha
 	lda	#<(Bank7_HandTheEnemy-1)
	JMP	Bank1_JMPto7

Bank1_Display_Message
*
*	temp19 = (number of bank) - 1 
*
	LDA	#0
	STA	temp19

	lda	#>(Bank8_Display_Message-1)
   	pha
   	lda	#<(Bank8_Display_Message-1)
	JMP	Bank1_JMPto8

Bank1_DrawCommonEnemies
	lda	#>(Bank6_DrawCommonEnemies-1)
  	pha
 	lda	#<(Bank6_DrawCommonEnemies-1)
	JMP	Bank1_JMPto6


Bank1_DrawBossThings
	lda	#>(Bank4_DrawBossThings-1)
   	pha
   	lda	#<(Bank4_DrawBossThings-1)
Bank1_JMPto4
   	pha
   	pha
   	pha
   	ldx	#4

	LDA	#0
	STA	temp19

   	jmp	bankSwitchJump

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

	LDA	#$00
	STA	HScore_1

	LDA	#$00
	STA	HScore_2

	LDA	#$00
	STA	HScore_3

	LDA	#$10
	STA	HScore_4

	LDA	#$00
	STA	HScore_5

	LDA	#$00
	STA	HScore_6

EnterScreenBank2_NoFullReset
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
Difficulty = $C9
*
*	0-1: Diffuculty (Easy, Normal, Hard, Lunatic)
*	  6: Joy dir hold
*	  7: First time (0 = First)
*

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

	LDA	#%01000000
	BIT	SWCHA	
	BPL	Bank2_Joy0DirHold
	BVC	Bank2_Joy0DirHold
	LDA	#0
Bank2_Joy0DirHold
	STA	temp01
	LDA	Difficulty
	ORA	temp01
	STA	Difficulty
	
	BIT	Difficulty
	BMI	Bank2_NotFirstTime
	LDA	#%10000001
	STA	Difficulty
Bank2_NotFirstTime

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
*	Give you starter bombs and three lives.
*
	CLC
	
	LDA	Difficulty
	AND	#%00000011
	TAX
	ROR
	ROR	
	ROR
	STA	eikiY

	LDA	DifficultySettings_StartValues,x
	STA	LivesAndBombs
	
*
*	Reset level to 1.	
*
	LDA	#%00100000
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
	LDA	PressedDelay
	BPL	Bank2_DontPlaySound

	LDY	SoundCounters
	CPY	#$00
	BNE	Bank2_DontPlaySound
*
*	Register 0th sound.
*
	LDA	#$80
	STA	temp18
	JSR	Bank2_Call_SoundPlayer

Bank2_DontPlaySound
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
*	temp19 is the buffer.	
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

	BIT	PressedDelay
	BMI 	Bank2_NoUpperDiff

	BIT	Difficulty
	BVS	Bank2_Joy0StillHold

	LDA	Difficulty
	AND	#%00000011
	TAX

	BIT	SWCHA
	BVS	Bank2_NoLowerDiff
	CPX	#0
	BEQ	Bank2_NoMoreToBeSelected

	DEX
	JMP	Bank2_SaveDiff
Bank2_NoLowerDiff
	BMI	Bank2_NoUpperDiff
	CPX	#3
	BEQ	Bank2_NoMoreToBeSelected

	INX	
Bank2_SaveDiff
	TXA
	ORA	#%11000000
	STA	Difficulty

	LDA	#$82
	STA	temp18
	JSR	Bank2_Call_SoundPlayer	

Bank2_NoUpperDiff
Bank2_Joy0StillHold
Bank2_NoMoreToBeSelected

	BIT	SWCHA
	BPL	Bank2_Joy0StillHold2
	BVC	Bank2_Joy0StillHold2
	LDA	Difficulty
	AND	#%10111111
	STA	Difficulty

Bank2_Joy0StillHold2	

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
**
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

	LDX	#3
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

	LDX	#4
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

**	LDX	#7
**Bank2_Wasting_More_Lines2
**	STA	WSYNC
**	DEX
**	BPL	Bank2_Wasting_More_Lines2

Bank2_DifficultySettings
	LDA	Difficulty
	AND	#%00000011
	ASL
	TAX
	STX	temp17	
	
	LDA	DifficultySettings_0_Pointers,x
	STA	temp01
	LDA	DifficultySettings_0_Pointers+1,x
	STA	temp02

	LDA	DifficultySettings_1_Pointers,x
	STA	temp03
	LDA	DifficultySettings_1_Pointers+1,x
	STA	temp04

	LDA	DifficultySettings_2_Pointers,x
	STA	temp05
	LDA	DifficultySettings_2_Pointers+1,x
	STA	temp06

	LDA	DifficultySettings_3_Pointers,x
	STA	temp07
	LDA	DifficultySettings_3_Pointers+1,x
	STA	temp08

	LDA	DifficultySettings_4_Pointers,x
	STA	temp09
	LDA	DifficultySettings_4_Pointers+1,x
	STA	temp10

	LDA	DifficultySettings_5_Pointers,x
	STA	temp11
	LDA	DifficultySettings_5_Pointers+1,x
	STA	temp12

	STA	WSYNC
	sleep	3

	LDA	#<DifficultySettings_FG_Colors
	ADC	temp17
	STA	temp13
	LDA	#>DifficultySettings_FG_Colors
	STA	temp14					

	LDA	#<Bank2_Press_Fire_Colors_BG_Normal
	STA	temp15
	LDA	#>Bank2_Press_Fire_Colors_BG_Normal
	STA	temp16					; 10 (18)

	LDA	#$02			
	STA	NUSIZ0			
	LDA	#00
	STA	NUSIZ1				; 10 (28)

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

*	LDA	#$02			
*	STA	NUSIZ0			
*	LDA	#00
*	STA	NUSIZ1			; 10

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

	_align	14

Bank2_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1

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

	_align	8
DifficultySettings_0_Pointers
	BYTE	#<DifficultySettings_0_0
	BYTE	#>DifficultySettings_0_0
	BYTE	#<DifficultySettings_0_1
	BYTE	#>DifficultySettings_0_1
	BYTE	#<DifficultySettings_0_2
	BYTE	#>DifficultySettings_0_2
	BYTE	#<DifficultySettings_0_3
	BYTE	#>DifficultySettings_0_3

	_align	8
DifficultySettings_1_Pointers
	BYTE	#<DifficultySettings_1_0
	BYTE	#>DifficultySettings_1_0
	BYTE	#<DifficultySettings_1_1
	BYTE	#>DifficultySettings_1_1
	BYTE	#<DifficultySettings_1_2
	BYTE	#>DifficultySettings_1_2
	BYTE	#<DifficultySettings_1_3
	BYTE	#>DifficultySettings_1_3

	_align	8
DifficultySettings_2_Pointers
	BYTE	#<DifficultySettings_2_0
	BYTE	#>DifficultySettings_2_0
	BYTE	#<DifficultySettings_2_1
	BYTE	#>DifficultySettings_2_1
	BYTE	#<DifficultySettings_2_2
	BYTE	#>DifficultySettings_2_2
	BYTE	#<DifficultySettings_2_3
	BYTE	#>DifficultySettings_2_3

	_align	8
DifficultySettings_3_Pointers
	BYTE	#<DifficultySettings_3_0
	BYTE	#>DifficultySettings_3_0
	BYTE	#<DifficultySettings_3_1
	BYTE	#>DifficultySettings_3_1
	BYTE	#<DifficultySettings_3_2
	BYTE	#>DifficultySettings_3_2
	BYTE	#<DifficultySettings_3_3
	BYTE	#>DifficultySettings_3_3

	_align	8
DifficultySettings_4_Pointers
	BYTE	#<DifficultySettings_4_0
	BYTE	#>DifficultySettings_4_0
	BYTE	#<DifficultySettings_4_1
	BYTE	#>DifficultySettings_4_1
	BYTE	#<DifficultySettings_4_2
	BYTE	#>DifficultySettings_4_2
	BYTE	#<DifficultySettings_4_3
	BYTE	#>DifficultySettings_4_3

	_align	8
DifficultySettings_5_Pointers
	BYTE	#<DifficultySettings_5_0
	BYTE	#>DifficultySettings_5_0
	BYTE	#<DifficultySettings_5_1
	BYTE	#>DifficultySettings_5_1
	BYTE	#<DifficultySettings_5_2
	BYTE	#>DifficultySettings_5_2
	BYTE	#<DifficultySettings_5_3
	BYTE	#>DifficultySettings_5_3

	_align	5
DifficultySettings_0_0
DifficultySettings_1_2
DifficultySettings_4_0
DifficultySettings_4_2
DifficultySettings_5_3
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0

	_align	5
DifficultySettings_0_1
DifficultySettings_0_2
DifficultySettings_0_3
	BYTE	#%00000010
	BYTE	#%00000110
	BYTE	#%00001110
	BYTE	#%00000110
	BYTE	#%00000010

	_align	5
DifficultySettings_1_0
	BYTE	#%00000011
	BYTE	#%00000010
	BYTE	#%00000011
	BYTE	#%00000010
	BYTE	#%00000011

	_align	5
DifficultySettings_1_1
	BYTE	#%00100100
	BYTE	#%00100101
	BYTE	#%00101101
	BYTE	#%00110101
	BYTE	#%00100100

	_align	5
DifficultySettings_1_3
	BYTE	#%00111001
	BYTE	#%00100010
	BYTE	#%00100010
	BYTE	#%00100010
	BYTE	#%00100010

	_align	5
DifficultySettings_2_0
	BYTE	#%10101011
	BYTE	#%00101000
	BYTE	#%00111001
	BYTE	#%00101010
	BYTE	#%10010001

	_align	5
DifficultySettings_2_1
	BYTE	#%11001010
	BYTE	#%00101010
	BYTE	#%00101100
	BYTE	#%00101010
	BYTE	#%11001100

	_align	5
DifficultySettings_2_2
	BYTE	#%01010101
	BYTE	#%01010101
	BYTE	#%01110111
	BYTE	#%01010101
	BYTE	#%01010010

	_align	5
DifficultySettings_2_3
	BYTE	#%00100101
	BYTe	#%10100101
	BYTE	#%10101101
	BYTE	#%10110101
	BYTE	#%10100100

	_align	5
DifficultySettings_3_0
	BYTE	#%00010000
	BYTE	#%10010000
	BYTE	#%00010000
	BYTE	#%00101000
	BYTE	#%10101000

	_align	5
DifficultySettings_3_1
	BYTE	#%10001010
	BYTE	#%10001010
	BYTE	#%10101011
	BYTE	#%11011010
	BYTE	#%10001001

	_align	5
DifficultySettings_3_2
	BYTE	#%01010110
	BYTE	#%01010101
	BYTE	#%01100101
	BYTE	#%01010101
	BYTE	#%01100110

	_align	5
DifficultySettings_3_3
	BYTE	#%01001001
	BYTE	#%01001000
	BYTE	#%11001000
	BYTE	#%01001000
	BYTE	#%10011101

	_align	5
DifficultySettings_4_1
	BYTE	#%10111000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%10100000
	BYTE	#%00100000

	_align	5
DifficultySettings_4_3
	BYTE	#%11001100
	BYTE	#%10010000
	BYTE	#%10010000
	BYTE	#%10010000	
	BYTE	#%11001100

	_align	5
DifficultySettings_5_0
DifficultySettings_5_1
DifficultySettings_5_2
	BYTE	#%01000000
	BYTE	#%01100000
	BYTE	#%01110000
	BYTE	#%01100000
	BYTE	#%01000000

	_align	12
DifficultySettings_FG_Colors
DifficultySettings_FG_01
	BYTE	#$1e
	BYTE	#$1c
DifficultySettings_FG_02
	BYTE	#$1a	
	BYTE	#$18
DifficultySettings_FG_03
	BYTE	#$3a
	BYTE	#$38
DifficultySettings_FG_04
	BYTE	#$36
	BYTE	#$48
	BYTE	#$46
	BYTE	#$44
	BYTE	#$42

DifficultySettings_StartValues
	BYTE	#$74
	BYTE	#$52
	BYTE	#$32
	BYTE	#$32

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

	LDA	#$83
	STA	temp18
	JSR	Bank3_Call_SoundPlayer

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
	CMP	#%00011111
	BNE 	Bank3_NoPlaySound

	LDA	#$83
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
Bank3_Exit_To_Level
	LDA	eikiSettings2
	AND	#%01000000
	STA	eikiSettings2

	LDA	#0
	STA	AUDV0
	STA	AUDV1	
	
	lda	#>(EnterScreenBank1-1)
   	pha
   	lda	#<(EnterScreenBank1-1)
   	pha
   	pha
   	pha
   	ldx	#1
   	jmp	bankSwitchJump

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
	JMP	Bank3_Exit_To_Level

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

	LDA	LevelAndCharge
	LSR
	LSR
	LSR
	LSR
	LSR
	TAX
	DEX
	LDA	Bank3_TextPointer_For_LevelText,x
	STA	temp17

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

	_align	1
Bank3_TextPointer_For_LevelText
	BYTE	#0

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
Bank4_DrawBossThings
***	LDA	#255
***	LDX	#0
***	STA	WSYNC
****	STA	PF0
***	STX	COLUPF
***	LDA	BossBackColor
***	STA	COLUBK

*
*	temp01: 	Last Part of Boss HP
*	temp02: 	2nd  Part of Boss HP
*	temp03: 	3rd  Part of Boss HP
*	temp04: 	4th  Part of Boss HP
*	temp05:		Base Color

*
*
* X < Y
* LDA	X	
* CMP	Y
* BCS   else 	 
*

	LDX	#0
	STX	temp01
	STX	temp02
	STX	temp03
	STX	temp04
****	STX	PF0
	LDY	#255

	LDA	BossSettings
	AND	#%00001110
	CMP	#%00001110
	BEQ	Bank4_NoMoreLinesToSet
Bank4_HasToSetTheLines
	LDA	BossHP
Bank4_BossHPSetLoop
	CMP	#64	
	BCS	Bank4_HaveStill

	LSR
	LSR
	LSR

	TAY
	LDA	Bank4_HP_Lines,y
	STA	temp01,x

	JMP	Bank4_NoMoreLinesToSet

Bank4_HaveStill
	STY	temp01,x
	INX

	SEC
	SBC	#64

	CMP	#64
	BCS	Bank4_HaveStill2

	LSR
	LSR
	LSR

	TAY
	LDA	Bank4_HP_LinesMirrored,y
	STA	temp01,x

	JMP	Bank4_NoMoreLinesToSet
Bank4_HaveStill2
	STY	temp01,x
	INX

	SEC
	SBC	#64
	JMP	Bank4_BossHPSetLoop

Bank4_NoMoreLinesToSet

	LDA	Bank4_WasteLinesOnX,x
	TAX
Bank4_WasteLinesOnXLoop	
	STA	WSYNC
	DEX
	BPL	Bank4_WasteLinesOnXLoop	

	LDA	BossBackColor
	AND	#$0F
	STA	temp05
*
* X >= Y
*
* LDA	X
* CMP	Y
* BCC 	else
*
	CMP	#$08
	BCC	Bank4_DontDownGradeAdder
	LDA	BossBackColor
	SEC
	SBC	#4
	JMP	Bank4_MatchTheBack
Bank4_DontDownGradeAdder
	STA	temp05

	LDA	LevelAndCharge
	AND	#%11100000
	SEC
	SBC	#%00100000
	LSR
	LSR
	LSR
	LSR
	TAY	
	LDA	Bank4_Line_BaseColor,y
	CLC
	ADC	temp05
Bank4_MatchTheBack
	STA	temp05

	LDA	#%00000101
	STA	CTRLPF

	LDY	#4
	CLC

Bank4_HP_Lines_Loop
	STA	WSYNC

	LDA	temp01	
	STA	PF1		; 6 
	LDA	temp02
	STA	PF2		; 6 (12)

	LDA	temp05		;
	ADC	Bank4_LineAdder,y 
	STA	COLUPF		; 6 (18)

	ADC	#4
	TAX

***	sleep	14
	sleep	8

	SEC
	SBC	#2
	STA	COLUPF	

****	sleep	24

	LDA	temp03
***	STA	PF2
	BYTE	#$8D
	BYTE	#PF2
	BYTE	#0

	LDA	temp04
	STA	PF1

	STX	COLUPF	


	DEY
	BPL	Bank4_HP_Lines_Loop

Bank4_HP_Lines_Loop_Ended
	LDA	#0
****	LDX	BossBackColor
	LDY	#255
	STA	WSYNC

	STA	COLUPF
	STA	COLUBK
	STY	PF0
	STA	PF1
	STA	PF2
	STA	HMCLR
*
*	temp01:	P0 Pointer
*	temp03:	P1 Pointer
*	temp05:	P0 Color Pointer
*	temp07:	P1 Color Pointer
*
*

	STA	NUSIZ0
	STA	NUSIZ1

	LDA	counter
	AND	#1
	TAX

	LDA	EnemyX
	CLC
	ADC	Bank4_Shift8_P0,x
	STA	temp15

	LDA	EnemyX
	CLC
	ADC	Bank4_Shift8_P1,x
	STA	temp16

	LDX	#1
Bank4_NextHorPoz
	STA	WSYNC
	LDA	temp15,x
Bank4_DivideLoop
	sbc	#15
   	bcs	Bank4_DivideLoop
   	sta	temp15,X
   	sta	RESP0,X	
	DEX
	BPL	Bank4_NextHorPoz	

	ldx	#1
Bank4_setFine
   	lda	temp15,x
	CLC
	ADC	#16
	TAY
   	lda	Bank4_FineAdjustTable,y
   	sta	HMP0,x		
	DEX
	BPL	Bank4_setFine


	STA	WSYNC
	STA	HMOVE

	LDA 	LevelAndCharge
	AND	#%11000000
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY
	
	LDA	counter
	AND	#1
	TAX

	CPX	#1
	BNE	Bank4_Boss_EvenFrame

Bank4_Boss_Odd_Frame
	LDA	Bank4_Boss_Color_P0_R_Pointer,y
	STA	temp05

	LDA	Bank4_Boss_Color_P0_R_Pointer+1,y
	STA	temp06

	LDA	Bank4_Boss_Color_P1_L_Pointer,y
	STA	temp07

	LDA	Bank4_Boss_Color_P1_L_Pointer+1,y
	STA	temp08

	LDA	BossSettings2
	AND	#7
	ASL
	TAY	
	
	LDA	(BossSpriteTablePointer_R_P0),y
	STA	temp01
	
	LDA	(BossSpriteTablePointer_L_P1),y
	STA	temp03

	INY	

	LDA	(BossSpriteTablePointer_R_P0),y
	STA	temp02
	
	LDA	(BossSpriteTablePointer_L_P1),y
	STA	temp04
	
	JMP	Bank4_Was_Boss_Odd_Frame

Bank4_Boss_EvenFrame
	LDA	Bank4_Boss_Color_P0_L_Pointer,y
	STA	temp05

	LDA	Bank4_Boss_Color_P0_L_Pointer+1,y
	STA	temp06

	LDA	Bank4_Boss_Color_P1_R_Pointer,y
	STA	temp07

	LDA	Bank4_Boss_Color_P1_R_Pointer+1,y
	STA	temp08

	LDA	BossSettings2
	AND	#7
	ASL
	TAY	
	
	LDA	(BossSpriteTablePointer_L_P0),y
	STA	temp01
	
	LDA	(BossSpriteTablePointer_R_P1),y
	STA	temp03

	INY	

	LDA	(BossSpriteTablePointer_L_P0),y
	STA	temp02
	
	LDA	(BossSpriteTablePointer_R_P1),y
	STA	temp04

Bank4_Was_Boss_Odd_Frame

	LDY	#23
	LDX	#1
Bank4_DrawBossLoop
	STA	WSYNC

	LDA	(temp01),y
	STA	GRP0

	LDA	(temp03),y
	STA	GRP1

	LDA	(temp05),y
	STA	COLUP0

	LDA	(temp07),y
	STA	COLUP1

	DEX
	BPL	Bank4_DrawBossLoop

	LDX	#1

	DEY
	BPL	Bank4_DrawBossLoop

Bank4_DrawBossEnded
	LDA	#0
	STA	WSYNC
	STA	COLUPF
	STA	COLUBK
	STA	HMCLR
	STA	PF0
	STA	GRP0
	STA	GRP1

Bank4_ReturnFromAnything
	LDX	temp19
	CPX	#255
	BNE	Bank4_ReturnNoRTS
Bank4_Return
	RTS
Bank4_ReturnNoRTS
	TXA
	INX

	TAY

	ASL		
	TAY

	LDA	Bank4_Return_JumpTable,y
   	pha
   	lda	Bank4_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump

*
*	Data Section
*
	_align	2

Bank4_Shift8_P0
	BYTE	#0
	BYTE	#8

	_align	2

Bank4_Shift8_P1
	BYTE	#8
	BYTE	#0

	_align	16
Bank4_FineAdjustTable
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

	_align	5

Bank4_Line_BaseColor
	BYTE	#$40
	BYTE	#$D0
	BYTE	#$D0
	BYTE	#$D0
	BYTE	#$D0

	_align	4
Bank4_WasteLinesOnX
	BYTE	#1
	BYTE	#0
	BYTE	#0
	BYTE	#0

	_align	5
Bank4_LineAdder
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00

	_align	8
Bank4_HP_Lines
	BYTE	#%10000000
	BYTE	#%11000000
	BYTE	#%11100000
	BYTE	#%11110000
	BYTE	#%11111000
	BYTE	#%11111100
	BYTE	#%11111110
	BYTE	#%11111111

	_align	8
Bank4_HP_LinesMirrored
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%00000111
	BYTE	#%00001111
	BYTE	#%00011111
	BYTE	#%00111111
	BYTE	#%01111111
	BYTE	#%11111111

	_align	14
Bank4_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1

	_align	10
Bank4_Komachi_L_P0_Pointers
	BYTE	#<Bank4_Komachi_L_P0_0
	BYTE	#>Bank4_Komachi_L_P0_0
	BYTE	#<Bank4_Komachi_L_P0_1
	BYTE	#>Bank4_Komachi_L_P0_1
	BYTE	#<Bank4_Komachi_L_P0_2
	BYTE	#>Bank4_Komachi_L_P0_2
	BYTE	#<Bank4_Komachi_L_P0_3
	BYTE	#>Bank4_Komachi_L_P0_3
	BYTE	#<Bank4_Komachi_L_P0_4
	BYTE	#>Bank4_Komachi_L_P0_4

	_align	10
Bank4_Komachi_L_P1_Pointers
	BYTE	#<Bank4_Komachi_L_P1_0
	BYTE	#>Bank4_Komachi_L_P1_0
	BYTE	#<Bank4_Komachi_L_P1_1
	BYTE	#>Bank4_Komachi_L_P1_1
	BYTE	#<Bank4_Komachi_L_P1_2
	BYTE	#>Bank4_Komachi_L_P1_2
	BYTE	#<Bank4_Komachi_L_P1_3
	BYTE	#>Bank4_Komachi_L_P1_3
	BYTE	#<Bank4_Komachi_L_P1_4
	BYTE	#>Bank4_Komachi_L_P1_4

	_align	10
Bank4_Komachi_R_P0_Pointers
	BYTE	#<Bank4_Komachi_R_P0_0
	BYTE	#>Bank4_Komachi_R_P0_0
	BYTE	#<Bank4_Komachi_R_P0_1
	BYTE	#>Bank4_Komachi_R_P0_1
	BYTE	#<Bank4_Komachi_R_P0_2
	BYTE	#>Bank4_Komachi_R_P0_2
	BYTE	#<Bank4_Komachi_R_P0_3
	BYTE	#>Bank4_Komachi_R_P0_3
	BYTE	#<Bank4_Komachi_R_P0_4
	BYTE	#>Bank4_Komachi_R_P0_4

	_align	10
Bank4_Komachi_R_P1_Pointers
	BYTE	#<Bank4_Komachi_R_P1_0
	BYTE	#>Bank4_Komachi_R_P1_0
	BYTE	#<Bank4_Komachi_R_P1_1
	BYTE	#>Bank4_Komachi_R_P1_1
	BYTE	#<Bank4_Komachi_R_P1_2
	BYTE	#>Bank4_Komachi_R_P1_2
	BYTE	#<Bank4_Komachi_R_P1_3
	BYTE	#>Bank4_Komachi_R_P1_3
	BYTE	#<Bank4_Komachi_R_P1_4
	BYTE	#>Bank4_Komachi_R_P1_4

	_align	2
Bank4_Boss_Color_P0_L_Pointer
	BYTE	#<Bank4_Komachi_L_P0_Color
	BYTE	#>Bank4_Komachi_L_P0_Color

	_align	2
Bank4_Boss_Color_P0_R_Pointer
	BYTE	#<Bank4_Komachi_R_P0_Color
	BYTE	#>Bank4_Komachi_R_P0_Color

	_align	2
Bank4_Boss_Color_P1_L_Pointer
	BYTE	#<Bank4_Komachi_L_P1_Color
	BYTE	#>Bank4_Komachi_L_P1_Color

	_align	2
Bank4_Boss_Color_P1_R_Pointer
	BYTE	#<Bank4_Komachi_R_P1_Color
	BYTE	#>Bank4_Komachi_R_P1_Color


	_align	24
Bank4_Komachi_L_P0_0
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000111
	BYTE	#%00000011
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00010110
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%11100000
	BYTE	#%01111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000110
	BYTE	#%00000011
	BYTE	#%00000010

	_align	24
Bank4_Komachi_L_P1_0
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001

	_align	24
Bank4_Komachi_R_P0_0
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11111111
	BYTE	#%11101100
	BYTE	#%11011000
	BYTE	#%10001100
	BYTE	#%11111000
	BYTE	#%01110000
	BYTE	#%01110000
	BYTE	#%11111000
	BYTE	#%11111000
	BYTE	#%11111000
	BYTE	#%00100000
	BYTE	#%01010000
	BYTE	#%11111000
	BYTE	#%10101000
	BYTE	#%10101001
	BYTE	#%01110011
	BYTE	#%10101110
	BYTE	#%00001000

	_align	24
Bank4_Komachi_R_P1_0
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00010010
	BYTE	#%00100110
	BYTE	#%01110000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000110
	BYTE	#%00000100
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%01010000
	BYTE	#%01010000
	BYTE	#%10001000
	BYTE	#%01010000
	BYTE	#%10000110

	_align	24
Bank4_Komachi_L_P0_1
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00010110
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%11100000
	BYTE	#%01111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%00000011
	BYTE	#%00000001

	_align	24
Bank4_Komachi_L_P1_1
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000

	_align	24
Bank4_Komachi_R_P0_1
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11111110
	BYTE	#%11010111
	BYTE	#%11101101
	BYTE	#%11000100
	BYTE	#%01111100
	BYTE	#%01110000
	BYTE	#%01110000
	BYTE	#%11111000
	BYTE	#%11111000
	BYTE	#%11111000
	BYTE	#%00100000
	BYTE	#%01010000
	BYTE	#%11111000
	BYTE	#%10101000
	BYTE	#%11010000
	BYTE	#%10110001
	BYTE	#%10111011
	BYTE	#%10000111

	_align	24
Bank4_Komachi_R_P1_1
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00101000
	BYTE	#%00010010
	BYTE	#%00111000
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000110
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%01010000
	BYTE	#%00101000
	BYTE	#%01001000
	BYTE	#%01000100
	BYTE	#%01001000

	_align	24
Bank4_Komachi_L_P0_2
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000111
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00010110
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%11100000
	BYTE	#%01111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000110
	BYTE	#%00000011
	BYTE	#%00000000

	_align	24
Bank4_Komachi_L_P1_2
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00000000

	_align	24
Bank4_Komachi_R_P0_2
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11011000
	BYTE	#%11111100
	BYTE	#%01011100
	BYTE	#%11101100
	BYTE	#%00011000
	BYTE	#%11111000
	BYTE	#%01110000
	BYTE	#%01110000
	BYTE	#%11111000
	BYTE	#%11110000
	BYTE	#%11111000
	BYTE	#%00100000
	BYTE	#%01010000
	BYTE	#%11111000
	BYTE	#%10101000
	BYTE	#%00101100
	BYTE	#%11010110
	BYTE	#%01101110
	BYTE	#%01001100

	_align	24
Bank4_Komachi_R_P1_2
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%10100000
	BYTE	#%00010000
	BYTE	#%11100100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001110
	BYTE	#%00000110
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%01010000
	BYTE	#%11010000
	BYTE	#%00100000
	BYTE	#%10010000
	BYTE	#%10010000

	_align	24
Bank4_Komachi_L_P0_3
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000111
	BYTE	#%00001011
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%11100000
	BYTE	#%01110000
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00000000

	_align	24
Bank4_Komachi_L_P1_3
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%00000010
	BYTE	#%00000000
	BYTE	#%00000100
	BYTE	#%00000100
	BYTE	#%00001100
	BYTE	#%00001000
	BYTE	#%00011000
	BYTE	#%00000000
	BYTE	#%00110000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000000

	_align	24
Bank4_Komachi_R_P0_3
	BYTE	#%00011011
	BYTE	#%00011011
	BYTE	#%00011011
	BYTE	#%00110110
	BYTE	#%01111110
	BYTE	#%00110110
	BYTE	#%11111111
	BYTE	#%01011011
	BYTE	#%01111100
	BYTE	#%00110001
	BYTE	#%00111110
	BYTE	#%00000100
	BYTE	#%00110000
	BYTE	#%01111000
	BYTE	#%11110000
	BYTE	#%11111000
	BYTE	#%01100000
	BYTE	#%10110000
	BYTE	#%11110000
	BYTE	#%01011000
	BYTE	#%10101001
	BYTE	#%11110111
	BYTE	#%11101110
	BYTE	#%01010100

	_align	24
Bank4_Komachi_R_P1_3
	BYTE	#%00000000
	BYTE	#%00100000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%10100100
	BYTE	#%10000011
	BYTE	#%00001110
	BYTE	#%00000000
	BYTE	#%11111000
	BYTE	#%11001100
	BYTE	#%10000100
	BYTE	#%00001100
	BYTE	#%00000110
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%10100000
	BYTE	#%01010000
	BYTE	#%00001000
	BYTE	#%00010000
	BYTE	#%10001000

	_align	24
Bank4_Komachi_L_P0_4
	BYTE	#%01110110
	BYTE	#%00111111
	BYTE	#%00011011
	BYTE	#%00001111
	BYTE	#%00001111
	BYTE	#%00000111
	BYTE	#%00001111
	BYTE	#%00000111
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00111111
	BYTE	#%00001111
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%00001000
	BYTE	#%01111000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00001100
	BYTE	#%00000111
	BYTE	#%00000011
	BYTE	#%00000000

	_align	24
Bank4_Komachi_L_P1_4
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%10000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%00100000
	BYTE	#%00000000
	BYTE	#%00010000
	BYTE	#%00010000
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%11110000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000

	_align	24
Bank4_Komachi_R_P0_4
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%10000000
	BYTE	#%11000000
	BYTE	#%11100000
	BYTE	#%11111000
	BYTE	#%11010000
	BYTE	#%01101000
	BYTE	#%10010000
	BYTE	#%11110000
	BYTE	#%00000000
	BYTE	#%01110000
	BYTE	#%11110000
	BYTE	#%11110000
	BYTE	#%11111000
	BYTE	#%00110000
	BYTE	#%00110100
	BYTE	#%00111110
	BYTE	#%01101010
	BYTE	#%11010110
	BYTE	#%00111110
	BYTE	#%11011100
	BYTE	#%11001100

	_align	24
Bank4_Komachi_R_P1_4
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00101100
	BYTE	#%10010000
	BYTE	#%01100000
	BYTE	#%00000000
	BYTE	#%11111000
	BYTE	#%00001100
	BYTE	#%00000100
	BYTE	#%00001110
	BYTE	#%00000110
	BYTE	#%00000000
	BYTE	#%00001000
	BYTE	#%00000000
	BYTE	#%00010100
	BYTE	#%00101000
	BYTE	#%01000000
	BYTE	#%00100010
	BYTE	#%00000000

	_align	24
Bank4_Komachi_L_P0_Color
	BYTE	#$04
	BYTE	#$06
	BYTE	#$0e
	BYTE	#$0c
	BYTE	#$3e
	BYTE	#$3c
	BYTE	#$86
	BYTE	#$84
	BYTE	#$86
	BYTE	#$0e
	BYTE	#$0e
	BYTE	#$3a
	BYTE	#$3e
	BYTE	#$3c
	BYTE	#$0c
	BYTE	#$0a
	BYTE	#$96
	BYTE	#$98
	BYTE	#$3e
	BYTE	#$3e
	BYTE	#$46
	BYTE	#$48
	BYTE	#$46
	BYTE	#$44

	_align	24
Bank4_Komachi_L_P1_Color
	BYTE	#$32
	BYTE	#$34
	BYTE	#$36
	BYTE	#$34
	BYTE	#$34
	BYTE	#$36
	BYTE	#$34
	BYTE	#$36
	BYTE	#$34
	BYTE	#$36
	BYTE	#$34
	BYTE	#$32
	BYTE	#$34
	BYTE	#$36
	BYTE	#$38
	BYTE	#$34
	BYTE	#$34
	BYTE	#$36
	BYTE	#$96
	BYTE	#$4e
	BYTE	#$3c
	BYTE	#$d6
	BYTE	#$d8
	BYTE	#$42

	_align	24
Bank4_Komachi_R_P0_Color
	BYTE	#$04
	BYTE	#$06
	BYTE	#$0e
	BYTE	#$0c
	BYTE	#$3e
	BYTE	#$3c
	BYTE	#$88
	BYTE	#$86
	BYTE	#$88
	BYTE	#$0e
	BYTE	#$0c
	BYTE	#$0a
	BYTE	#$14
	BYTE	#$84
	BYTE	#$86
	BYTE	#$88
	BYTE	#$3a
	BYTE	#$3c
	BYTE	#$3e
	BYTE	#$3e
	BYTE	#$44
	BYTE	#$46
	BYTE	#$46
	BYTE	#$44

	_align	24
Bank4_Komachi_R_P1_Color
	BYTE	#$32
	BYTE	#$34
	BYTE	#$36
	BYTE	#$34
	BYTE	#$34
	BYTE	#$36
	BYTE	#$34
	BYTE	#$84
	BYTE	#$86
	BYTE	#$8a
	BYTE	#$3c
	BYTE	#$3e
	BYTE	#$3e
	BYTE	#$3c
	BYTE	#$0c
	BYTE	#$0c
	BYTE	#$44
	BYTE	#$42
	BYTE	#$44
	BYTE	#$0e
	BYTE	#$3c
	BYTE	#$d8
	BYTE	#$d6
	BYTE	#$42


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
	
Bank5_Display_Score
****	STA	WSYNC

	LDA	ScoreColorAdder
	AND	#7
	TAX
	ADC 	#$18
	STA	temp18

	LDA	SaveHighScore
	BPL	Bank5_NoHighScoreRainbow

	AND	#%01111111
	CMP	#0
	BEQ	Bank5_NoHighScoreRainbow

	LDA	counter
	AND	#$F0
	STA	temp01

	LDA	counter
	AND	#$0F
	TAX
	LDA	Bank5_VicaVersa,x	
	ORA	temp01
	STA	temp18
	
	DEC	SaveHighScore
	JMP	Bank5_NoDecrementGlow
Bank5_NoHighScoreRainbow
	CPX	#0
	BEQ	Bank5_NoDecrementGlow

	DEX
	LDA	ScoreColorAdder
	AND	#%11111000	
	STA	ScoreColorAdder
	TXA
	ORA	ScoreColorAdder
	STA	ScoreColorAdder
Bank5_NoDecrementGlow

	LDA	Score_1
	AND	#$0F
	STA	temp05

	LDA	Score_1
	LSR
	LSR
	LSR
	LSR
	STA	temp01

	LDA	Score_2
	AND	#$0F
	STA	temp02

	LDA	Score_2
	LSR
	LSR
	LSR
	LSR
	STA	temp09

	LDA	Score_3
	AND	#$0F
	STA	temp10

	LDA	Score_3
	LSR
	LSR
	LSR
	LSR
	STA	temp06

	LDA	Score_4
	AND	#$0F
	STA	temp07

	LDA	Score_4
	LSR
	LSR
	LSR
	LSR
	STA	temp03

	LDA	Score_5
	AND	#$0F
	STA	temp04

	LDA	Score_5
	LSR
	LSR
	LSR
	LSR
	STA	temp11

	LDA	Score_6
	AND	#$0F
	STA	temp12

	LDA	Score_6
	LSR
	LSR
	LSR
	LSR
	STA	temp08

*
*	temp19 = (number of bank) - 1 
*
	LDA	#0
	STA	temp19

	lda	#>(Bank8_DynamicText-1)
   	pha
   	lda	#<(Bank8_DynamicText-1)
   	pha
   	pha
   	pha
   	ldx	#8
   	jmp	bankSwitchJump

**Bank5_MultiplyBy10
**	CLC
**
**	STA	temp18
**	
**	ASL
**	ASL
**	ADC	temp18
**	ASL
**
**	RTS

*Bank5_Add2Score
*
**	LDA	#$FF
**	STA	$F1
**
*	CLC
*	SED	
*
*	LDA	Score_6
*	ADC	temp01
*	STA	Score_6
*
*	LDA	Score_5
*	ADC	temp02
*	STA	Score_5
*	
*	LDA	Score_4
*	ADC	temp03
*	STA	Score_4	
*
*	LDA	Score_3
*	ADC	temp04
*	STA	Score_3	
*
*	LDA	Score_2
*	ADC	temp05
*	STA	Score_2	
*
*	LDA	Score_1
*	ADC	temp06
*	STA	Score_1	
*
*	CLD

Bank5_ShowLivesAndBombs
*
*	Pointers:
*
*	temp01: JinJang
*	temp03: Star
*	temp07: NumberOfLives
*	temp09: NumberOfBombs
*	temp05: Color glow1
*	temp06: Color glow2
*
*

	LDA	LivesAndBombs
	AND	#$F0
	LSR
	STA	temp01
	LDA	#<Bank5_Numbers
	CLC
	ADC	temp01
	STA	temp07

	LDA	LivesAndBombs
	AND	#$0F
	ASL
	ASL
	ASL
	STA	temp01
	LDA	#<Bank5_Numbers
	CLC
	ADC	temp01
	STA	temp09
	
	LDA	IndicatorSettings	
	AND	#%11000000
	CMP	#0
	BNE	Bank5_AddGlowToFirst
	LDA	#0	
	sleep	6
	JMP	Bank5_NoGlowAddedToFirst
Bank5_AddGlowToFirst
	LDA	IndicatorSettings
	AND	#%00000111
	TAX
	LDA	Bank5_AdderValueOnCounter,x
Bank5_NoGlowAddedToFirst
	STA	temp05

	LDA	ScoreColorAdder	
	AND	#%11000000
	CMP	#0
	BNE	Bank5_AddGlowToSecond
	LDA	#0	
	sleep	12
	JMP	Bank5_NoGlowAddedToSecond
Bank5_AddGlowToSecond
	LDA	IndicatorSettings
	LSR
	LSR
	LSR
	AND	#%00000111
	TAX
	LDA	Bank5_AdderValueOnCounter,x
Bank5_NoGlowAddedToSecond
	STA	temp06
	
*ScoreColorAdder = $B5
*
*	0-2: Amplitude
*	3-5: Free
*	6-7: BombsSpriteBuffer
*
*IndicatorSettings = $B6
*
*	0-2: LivesSpriteCounter
* 	3-5: BombSpriteCounter
*	6-7: LivesSpriteBuffer
*
	CLC

	LDA	IndicatorSettings
	AND	#%11000000
	ROL
	ROL
	ROL
	ASL
	TAX				


	LDA	Bank5_JinJangPointers,x
	STA	temp01
	
	LDA	Bank5_JinJangPointers+1,x
	STA	temp02


	LDA	#>Bank5_Numbers
	STA	temp08
	STA	temp10			; 8 

	LDA	#0
	STA	WSYNC
	STA	HMCLR
	STA	COLUBK
	STA	PF1
	STA	PF2			; 12

	LDA	IndicatorSettings
	AND	#%00000111
	ASL
	ASL
	ASL
	ADC	temp01
***	STA	temp01			; 17 (29)
	BYTE	#$8D
	BYTE	#temp01
	BYTE	#0

	LDA	#$04
	STA	RESP0
	STA	RESP1			; 6 (43)


	STA	NUSIZ0
	STA	NUSIZ1			; 8 (37)

	LDA	#$20
	STA	HMP0
	LDA	#$30
	STA	HMP1			; 10 (53)

	CLC
	LDA	ScoreColorAdder		; 3 
	AND	#%11000000		; 2 

	STA	WSYNC			; 76
	STA	HMOVE			; 3

	ROL								
	ROL				 
	ROL
	ASL
	TAX				; 8 (11)				

	LDA	Bank5_StarPointers,x
	STA	temp03

	LDA	Bank5_StarPointers+1,x
	STA	temp04			; 16 (27)

	LDA	IndicatorSettings
	AND	#%00111000
	ADC	temp03
	STA	temp03			; 11 (38)

	LDY	#7			; 2 (40)

	CLC					

	LDA	Bank5_JingJang_Colors,y ; 5 
	ADC	temp05			; 3
	STA	COLUP0			; 3
	STA	COLUP1			; 3

	TSX	
	STX	temp17

Bank5_Indicators_Loop
	STA	WSYNC			
Bank5_Indicators_Loop_NoWSYNC

	LDA	(temp01),y		; 5
	STA	GRP0			; 3 (8)

	LDA	(temp07),y		; 5
	STA	GRP1			; 3 (16)
	
	LDA	Bank5_Star_Colors,y 	; 5 
	ADC	temp06			; 3
	TAX				; 2
	TXS				; 2 (28)

	LAX	(temp09),y		; 5 (33)
	LDA	(temp03),y		; 5 (38)
	STA	GRP0			; 3 (41)
	STX	GRP1			; 3 (44)

	TSX				; 2 (46)	

	STX	COLUP0			; 3
	STX	COLUP1			; 3 (52)

	DEY				; 2 (54)
	BMI	Bank5_Indicators_Loop_Ended 	; 2 (56)

	LDA	Bank5_JingJang_Colors,y ; 5 
	ADC	temp05			; 3
	STA	COLUP0			; 3
	STA	COLUP1			; 3 (70)

	JMP	Bank5_Indicators_Loop	; 3 (76)

Bank5_Indicators_Loop_Ended
	LDA	#0
	STA	WSYNC
	STA	GRP0
	STA	GRP1

	LDX	temp17
	TXS
	
Bank5_ReturnFromAnything
	LDX	temp19
	CPX	#255
	BNE	Bank5_ReturnNoRTS
Bank5_Return
	RTS
Bank5_ReturnNoRTS
	TXA
	INX

	TAY

	ASL		
	TAY

	LDA	Bank5_Return_JumpTable,y
   	pha
   	lda	Bank5_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump

Bank5_SetIndicatorSprites
	LDA	IndicatorSettings
	AND	#%00000111
	TAX
	CMP	#0
	BNE	Bank5_AlwaysIncrement1

	LDA	IndicatorSettings
	AND	#%11000000
	CMP	#0
	BEQ	Bank5_NoZeroTheBuffer1

	LDA	IndicatorSettings
	AND	#%00111111
	STA	IndicatorSettings

Bank5_NoZeroTheBuffer1
	JSR	Bank5_CallRandom
	ADC	Score_6
	ADC	counter
	CMP	#252
	BCC	Bank5_DontIncrement1	

Bank5_AlwaysIncrement1
	INX	
	TXA
	AND	#%00000111
	STA	temp01

	LDA	IndicatorSettings
	AND	#%11111000
	ORA	temp01
	STA	IndicatorSettings
			
Bank5_DontIncrement1

	LDA	IndicatorSettings
	AND	#%00111000
	LSR
	LSR
	LSR
	TAX
	CMP	#0
	BNE	Bank5_AlwaysIncrement2

	LDA	ScoreColorAdder
	AND	#%11000000
	CMP	#0
	BEQ	Bank5_NoZeroTheBuffer2

	LDA	ScoreColorAdder
	AND	#%00111111
	STA	ScoreColorAdder

Bank5_NoZeroTheBuffer2
	JSR	Bank5_CallRandom
	ADC	Score_6
	ADC	counter
	CMP	#5
	BCS	Bank5_DontIncrement2	

Bank5_AlwaysIncrement2
	INX	
	TXA
	ASL
	ASL
	ASL
	AND	#%00111000
	STA	temp01

	LDA	IndicatorSettings
	AND	#%11000111
	ORA	temp01
	STA	IndicatorSettings
			
Bank5_DontIncrement2

	JMP	Bank5_ReturnFromAnything

Bank5_CallRandom
	LDA	random
	lsr
	BCC 	*+4
	EOR	#$d4
	STA	random
	rts

Bank5_CheckForPoints
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

*	LDA	temp01
*	CMP	Score_1
*	BCS	Bank5_NoAddNewLife1
*	JMP	Bank5_AddNewLife
*
*Bank5_NoAddNewLife1

*
*	Add a new bomb for every 00 00 01 00 00 00 points (except the ones that gave you lives)
*	Add a new life for every 00 00 10 00 00 00 points 
*
*	If bombs are full (9), add an extra life every time you would get a bomb.
*	If lives are full (what a gamer!), you get an extra 00 00 05 00 00 00. 	
*

	SED

	LDA	#0	
	STA	temp18
	
	LDA	Score_3
	SEC
	SBC	temp03
	STA	temp07

	CMP	#0
	BEQ	Bank5_NothingChanged

	LDA	temp03
	AND	#$F0
	STA	temp12

	LDA	Score_3
	AND	#$F0
	SEC
	SBC	temp12
	CMP	#0
	BEQ	Bank5_AddExtraBomb
	
	LDA	LivesAndBombs
	STA	temp09
	AND	#$0F
	STA	temp08

	JMP	Bank5_AddExtraLife

Bank5_AddExtraBomb
	LDA	LivesAndBombs
	STA	temp09
	AND	#$0F
	STA	temp08

	LDA	temp07
	AND	#$0F
	CLC
	ADC	temp08
	CMP	#10
	BCS	Bank5_BombsOverflow
	AND	#$0F
	STA	temp08

	LDA	LivesAndBombs
	AND	#$F0
	STA	temp10

	JMP	Bank5_AddBombsToVar
Bank5_BombsOverflow
	LDA	#$09
	STA	temp08

	LDA	#$10
	JMP	Bank5_AddExtraLifeFix1
Bank5_AddExtraLife		
	LDA	temp07
Bank5_AddExtraLifeFix1
	CLC
	ADC	LivesAndBombs
	BCC	Bank5_NoLifeOverFlow

	CLC
	LDA	Score_3
	ADC	#$05
	STA	Score_3	

	LDA	Score_2
	ADC	#0
	STA	Score_2	

	LDA	Score_1
	ADC	#0
	STA	Score_1	

	LDA	#$90
Bank5_NoLifeOverFlow
	AND	#$F0
	STA	temp10
Bank5_AddBombsToVar	
	ORA	temp08
	STA	LivesAndBombs

Bank5_CheckIfIncrementedSomething
	LDA	temp09
	CMP	LivesAndBombs
	BEQ	Bank5_NothingChanged

	AND	#$F0
	CMP	temp10
	BEQ	Bank5_NewBombAnimation	

	LDA	IndicatorSettings
	AND	#%00111000
	ORA	#%10000001
	STA	IndicatorSettings

	LDA	#$86
	JMP	Bank5_WasLifeAnimation
Bank5_NewBombAnimation	
	LDA	ScoreColorAdder
	AND	#%00111111
	ORA	#%10000000	
	STA	ScoreColorAdder

	LDA	IndicatorSettings
	AND	#%11000111
	ORA	#%00001000
	STA	IndicatorSettings

	LDA	#$85
Bank5_WasLifeAnimation
	STA	temp18


Bank5_NothingChanged
	CLD

	LDA	SaveHighScore
	BMI	Bank5_DontCheckOnHighScore

	LDA	eikiY
	AND	#%00100000
	CMP	#%00100000
	BEQ	Bank5_AlreadyHadContinue

	LDX	#0
Bank5_CheckOnHighScoreLoop
	LDA	Score_1,x
	CMP	HScore_1,x
	BCC	Bank5_DontCheckOnHighScore

	LDA	HScore_1,x
	CMP	Score_1,x
	BCS	Bank5_NoSetHighScoreUpdate

	LDA	#255
	STA	SaveHighScore

	LDA	#$87
	STA	temp18

	JMP	Bank5_DontCheckOnHighScore
Bank5_NoSetHighScoreUpdate
	INX
	CPX	#6
	BNE	Bank5_CheckOnHighScoreLoop

Bank5_DontCheckOnHighScore
Bank5_AlreadyHadContinue
	JMP	Bank5_ReturnFromAnything


Bank5_DisplaySpellCardFace

	LDA	SpellPicture	
	AND	#$F0
	ASL
	TAX

	LDA	Bank5_SpellCard_Col_0,x
	STA	temp01
	LDA	Bank5_SpellCard_Col_0+1,x
	STA	temp02

	LDA	Bank5_SpellCard_Col_1,x
	STA	temp03
	LDA	Bank5_SpellCard_Col_1+1,x
	STA	temp04

	LDA	Bank5_SpellCard_Col_2,x
	STA	temp05
	LDA	Bank5_SpellCard_Col_2+1,x
	STA	temp06

	LDA	Bank5_SpellCard_Col_3,x
	STA	temp07
	LDA	Bank5_SpellCard_Col_3+1,x
	STA	temp08

	LDA	Bank5_SpellCard_Col_4,x
	STA	temp09
	LDA	Bank5_SpellCard_Col_4+1,x
	STA	temp10

	LDA	Bank5_SpellCard_Col_5,x
	STA	temp11
	LDA	Bank5_SpellCard_Col_5+1,x
	STA	temp12

	LDA	Bank5_SpellCard_Col_6,x
	STA	temp13
	LDA	Bank5_SpellCard_Col_6+1,x
	STA	temp14

	LDA	Bank5_SpellCard_Col_7,x
	STA	temp15
	LDA	Bank5_SpellCard_Col_7+1,x
	STA	temp16			


**	LDA	#0
**	STA	ENAM0
**	STA	ENAM1

	LDA	#255
	STA	PF0	
	LDA	#0
	STA	COLUPF	

	LDA	SpellPicture
	AND	#$0F
	TAX	
	LDA	Bank5_SpellCard_BG,x

	STA	WSYNC
	STA	COLUBK			; 3 
	LDA	Bank5_SpellCard_FG,x	; 5 (8)
	STA	COLUP0			; 3 (11)
	STA	COLUP1			; 3 (14)
	STA	HMCLR			; 3 (17)

	LDA	#$02
	STA	NUSIZ0	
	STA	NUSIZ1

	sleep	5

	LDA	counter

	STA	RESP0
*	BYTE	#$8D
*	BYTE	#RESP0
*	BYTE	#0
	sleep	3
	STA	RESP1


	AND	#1
	TAX
	LDY	#39

	LDA	Bank5_SpellCard_First_HMOVE_P0,x
	STA	HMP0
	LDA	Bank5_SpellCard_First_HMOVE_P1,x
	STA	HMP1

***	TSX	
***	STX	temp17

	STA	WSYNC
	STA	HMOVE		; 3
	
	CPX	#1		; 2 (5) 
	BNE	Bank5_SpellCardPicture_Even	; 2 (7)
	JMP	Bank5_SpellCardPicture_Odd	; 3 (10)

	_align	90
Bank5_SpellCardPicture_Even
	LDA	#$80
	STA	HMP0
	STA	HMP1

Bank5_SpellCardPicture_Even_Loop
	STA	WSYNC
	STA	HMOVE			; 3

	LDA	(temp03),y		; 5 (7)
	STA	GRP0			; 3 (10)

	LDA	(temp07),y		; 5 (15)
	STA	GRP1			; 3 (18)

	LAX	(temp15),y		; 5 (23)
	LDA	(temp11),y		; 5 (28)

	sleep	15

	STA	GRP0			; 3 (46)
	STX	GRP1			; 3 (49)

	sleep	13

	LDA	#0
	STA	HMP0
	STA	HMP1			; 8

Bank5_SpellCardPicture_Even_SecondLine	
	STA	HMOVE 			; 3 (74)

	LDA	(temp01),y		; 5 (3)
	STA	GRP0			; 3 (6)

	LDA	(temp05),y		; 5 (11)
	STA	GRP1			; 3 (14)	

	LAX	(temp13),y		; 5 (19)
	LDA	(temp09),y		; 5 (24)
	
	sleep	20

	STA	GRP0			; 3 (43)
	STX	GRP1			; 3 (46)

	LDA	#$80
	STA	HMP0
	STA	HMP1			; 8		

	DEY
	BPL	Bank5_SpellCardPicture_Even_Loop
	JMP	Bank5_SpellCardPicture_Ended

	_align	90
Bank5_SpellCardPicture_Odd
	LDA	#0
	STA	HMP0
	STA	HMP1	; 8 (18)
	
	_sleep	50
	sleep	2
	
Bank5_SpellCardPicture_Odd_Loop
	STA	HMOVE 	(74)	

	LDA	(temp01),y		; 5 (3)
	STA	GRP0			; 3 (6)

	LDA	(temp05),y		; 5 (11)
	STA	GRP1			; 3 (14)	

	LAX	(temp13),y		; 5 (19)
	LDA	(temp09),y		; 5 (24)
	
	sleep	20

	STA	GRP0			; 3 (43)
	STX	GRP1			; 3 (46)

	LDA	#$80
	STA	HMP0
	STA	HMP1

Bank5_SpellCardPicture_Odd_SecondLine
	STA	WSYNC
	STA	HMOVE		; 3

	LDA	(temp03),y		; 5 (8)
	STA	GRP0			; 3 (11)

	LDA	(temp07),y		; 5 (16)
	STA	GRP1			; 3 (19)

	LAX	(temp15),y		; 5 (24)
	LDA	(temp11),y		; 5 (29)

	sleep	15

	STA	GRP0			; 3 (46)
	STX	GRP1			; 3 (49)

	sleep	6
	
	LDA	#$00
	STA	HMP0
	STA	HMP1		; 8 (11)

	DEY					; 2 (69)
	BPL	Bank5_SpellCardPicture_Odd_Loop	; 2 (71)


Bank5_SpellCardPicture_Ended
	LDA	#0
	STA	WSYNC
	STA	COLUBK
	STA	GRP0
	STA	GRP1
	STA	HMCLR
	STA	PF0

***	LDX	temp17
***	TXS

	JMP	Bank5_ReturnFromAnything

Bank5_DisplayDeathScreen
*
*	The screem has 3 parts:
*
*	You Died! : Bank5_YouDiedText_0  - Bank5_YouDiedText_7
*	Continue? : Bank5_ContinueText_1 - Bank5_ContinueText_6
*	Yes No    : Bank5_YesNoText_2    - Bank5_YesNoText_5
*
*	temp01-08 : Colors
*

Bank5_DisplayDeathScreen_YouDied
	STA	HMCLR
	
	LDA	#$02	
	STA	NUSIZ0
	STA	NUSIZ1

	LDA	counter
	sleep	2

	STA	RESP0
	sleep	3
	STA	RESP1

	AND	#%00000111
	ORA	#$40
	STA	temp01

	LDA	#0
	STA	GRP0	
	STA	GRP1

*	sleep	4

**	LDA	#$F0
**	STA	HMP0
**	LDA	#$10
**	STA	HMP1


	LDA	counter
	AND	#$0F
	TAX
	LDA	Bank5_VicaVersa,x
	LSR
	ORA	#$40
	STA	temp01
	
	LDY	#12
	JSR	Bank5_WasteSomeLines

	LDY	#8
	LDX	#8
Bank5_SetDiedTextColors
	LDA	Bank5_YouDiedAmplitude,x
	ADC	temp01
	STA	temp01,x
	DEX
	BPL	Bank5_SetDiedTextColors
	
	LDA	counter
	AND	#1
	TAX

	LDA	Bank5_SpellCard_First_HMOVE_P0,x
	STA	HMP0
	LDA	Bank5_SpellCard_First_HMOVE_P1,x
	STA	HMP1

	STA	WSYNC
	STA	HMOVE

	CPX	#0
	BEQ	Bank5_YouDied_EvenLoop_Start
	JMP	Bank5_YouDied_OddLoop_Start
	
	_align	105
Bank5_YouDied_EvenLoop_Start
	LDA	#$80
	STA	HMP0
	STA	HMP1
Bank5_YouDied_EvenLoop
	STA	WSYNC		; 3 (76)
	STA	HMOVE		; 3 

*	LDA	#255
*	STA	GRP0
*	STA	GRP1		; 8 (11)
*
*	sleep	56

	LDA	Bank5_YouDiedText_1,y	; 
	STA 	GRP0			; 7 (10)

	LDA	Bank5_YouDiedText_3,y	; 
	STA 	GRP1			; 7 (17)

	BYTE	#$B9
	BYTE	#temp01
	BYTE	#0

	STA	COLUP0
	STA	COLUP1

	sleep	11

	LAX	Bank5_YouDiedText_7,y	; 4
	LDA	Bank5_YouDiedText_5,y	; 4
	STA 	GRP0			; 3 
	STX	GRP1			; 3 (49)

	sleep	11

	LDA	#0		; 2 (65)
	STA	HMP0		; 3 (68)
	STA	HMP1		; 3 (71)

Bank5_YouDied_Even_SecondLine
	STA	HMOVE		; 3 (74)

	LDA	Bank5_YouDiedText_0,y	; 
	STA 	GRP0			; 7 (8)

	LDA	Bank5_YouDiedText_2,y	; 
	STA 	GRP1			; 7 (15)

	sleep	23

	LAX	Bank5_YouDiedText_6,y	; 4
	LDA	Bank5_YouDiedText_4,y	; 4
	STA 	GRP0			; 3 
	STX	GRP1			; 3 (46)

	LDA	#$80
	STA	HMP0
	STA	HMP1

	DEY
	BPL	Bank5_YouDied_EvenLoop
	JMP	Bank5_YouDied_Ended	

	_align	168
Bank5_YouDied_OddLoop_Start
	LDA	#0
	STA	HMP0
	STA	HMP1	; 8

	_sleep	50
	sleep	2
Bank5_YouDied_OddLoop
	STA	HMOVE	; 74 (3)

	LDA	Bank5_YouDiedText_0,y	; 
	STA 	GRP0			; 7 (8)

	LDA	Bank5_YouDiedText_2,y	; 
	STA 	GRP1			; 7 (15)

	BYTE	#$B9
	BYTE	#temp01
	BYTE	#0

	STA	COLUP0
	STA	COLUP1

	sleep	12

	LAX	Bank5_YouDiedText_6,y	; 4
	LDA	Bank5_YouDiedText_4,y	; 4
	STA 	GRP0			; 3 
	STX	GRP1			; 3 (46)

	LDA	#$80
	STA	HMP0
	STA	HMP1

Bank5_YouDied_Odd_SecondLine
	STA	WSYNC
	STA	HMOVE	; 3

	LDA	Bank5_YouDiedText_1,y	; 
	STA 	GRP0			; 7 (10)

	LDA	Bank5_YouDiedText_3,y	; 
	STA 	GRP1			; 7 (17)

	sleep	21

	LAX	Bank5_YouDiedText_7,y	; 4
	LDA	Bank5_YouDiedText_5,y	; 4
	STA 	GRP0			; 3 
	STX	GRP1			; 3 (49)

	sleep	4

	LDA	#0
	STA	HMP0
	STA	HMP1	; 8	

***	sleep	53	

	DEY				; 2 (69)
	BPL	Bank5_YouDied_OddLoop	; 3 (71)

Bank5_YouDied_Ended
	LDA	#0
	STA	WSYNC
	STA	HMCLR
	STA	GRP0
	STA	GRP1
	STA	COLUP0
	STA	COLUP1
	STA	NUSIZ1

	LDA	#$02
	STA	NUSIZ0

	LDY	#2
	JSR	Bank5_WasteSomeLines

	LDA	counter
	AND	#1
	TAX

	LDA	Bank5_Continue_First_HMOVE_P0,x
	STA	HMP0
	LDA	Bank5_Continue_First_HMOVE_P1,x
	STA	HMP1

	sleep	4

	STA	RESP0
	sleep	3
	STA	RESP1

	LDA	counter
	LSR
	LSR
	AND	#$0F
	TAY
	LDA	Bank5_ContinuePoz,y
	TAY
	STA	temp01	

	JSR	Bank5_WasteSomeLines

	STX	temp10
	LDX	#5

	LDA	#25
	SEC
	SBC	temp01	
	TAY

Bank5_Continue_FillColor
	LDA	Bank5_ContinueColor,y

	STA	temp01,x
	
	DEY
	DEX
	BPL	Bank5_Continue_FillColor

	LDY	#5	
	LDX	temp10
	
	STA	WSYNC
	STA	HMOVE

	CPX	#0
	BEQ	Bank5_Continue_EvenLoop_Start
	JMP	Bank5_Continue_OddLoop_Start
	
	_align	100
Bank5_Continue_EvenLoop_Start
	LDA	#$80
	STA	HMP0
	STA	HMP1
Bank5_Continue_EvenLoop
	STA	WSYNC		; 3 (76)
	STA	HMOVE		; 3 

	LDA	Bank5_ContinueText_2,y
	STA	GRP0

	LDA	Bank5_ContinueText_4,y
	STA	GRP1	

	BYTE	#$B9
	BYTE	#temp01
	BYTE	#0

	STA	COLUP0
	STA	COLUP1

	sleep	19

	LDA	Bank5_ContinueText_6,y
	STA	GRP0			; 46

	sleep	10

	LDA	#0		; 2 (65)
	STA	HMP0		; 3 (68)
	STA	HMP1		; 3 (71)

Bank5_Continue_Even_SecondLine
	STA	HMOVE		; 3 (74)

	LDA	Bank5_ContinueText_1,y
	STA	GRP0

	LDA	Bank5_ContinueText_3,y
	STA	GRP1	

	sleep	32

	LDA	Bank5_ContinueText_5,y
	STA	GRP0			; 46

	LDA	#$80
	STA	HMP0
	STA	HMP1

	DEY
	BPL	Bank5_Continue_EvenLoop
	JMP	Bank5_Continue_Ended	

	_align	100
Bank5_Continue_OddLoop_Start
	LDA	#0
	STA	HMP0
	STA	HMP1	; 8

	_sleep	50
	sleep	2
Bank5_Continue_OddLoop
	STA	HMOVE	; 74 (3)

	LDA	Bank5_ContinueText_1,y
	STA	GRP0

	LDA	Bank5_ContinueText_3,y
	STA	GRP1	

	BYTE	#$B9
	BYTE	#temp01
	BYTE	#0

	STA	COLUP0
	STA	COLUP1

	sleep	20

	LDA	Bank5_ContinueText_5,y
	STA	GRP0			; 46

	LDA	#$80
	STA	HMP0
	STA	HMP1

Bank5_Continue_Odd_SecondLine
	STA	WSYNC
	STA	HMOVE	; 3
	
	LDA	Bank5_ContinueText_2,y
	STA	GRP0

	LDA	Bank5_ContinueText_4,y
	STA	GRP1	

	sleep	28

	LDA	Bank5_ContinueText_6,y
	STA	GRP0			; 46

	LDA	#0
	STA	HMP0
	STA	HMP1	; 8
	
	sleep	4	

	DEY				; 2 (69)
	BPL	Bank5_Continue_OddLoop	; 3 (71)

Bank5_Continue_Ended				
	LDA	#0
	STA	WSYNC
	STA	GRP0
	STA	GRP1

	LDA	counter
	LSR
	LSR
	AND	#$0F
	TAY
	LDA	Bank5_ContinuePoz,y

	STA	temp01

	LDA	#20
	SEC
	SBC	temp01
	TAY

	JSR	Bank5_WasteSomeLines

Bank5_YesNo_Start
	LDA	#$04
	STA	NUSIZ0
	STA	NUSIZ1

	LDA	ScoreColorAdder
	LSR
	LSR
	LSR
	AND	#2
	NOP

	STA	RESP0
	STA	RESP1

	TAX

	LDA	Bank5_YesNo_ColorPointers,x
	STA	temp01
	LDA 	Bank5_YesNo_ColorPointers+1,x
	STA	temp02

	LDA	Bank5_YesNo_ColorPointers+2,x
	STA	temp03
	LDA 	Bank5_YesNo_ColorPointers+3,x
	STA	temp04

	LDA	#$E0
	STA	HMP0

	LDA	#$F0
	STA	HMP1

	LDY	#5

	STA	WSYNC
	STA	HMOVE

Bank5_YesNo_Loop
	STA	WSYNC			; 76

	LDA	Bank5_YesNoText_2,y
	STA	GRP0			; 7 

	LDA	Bank5_YesNoText_3,y
	STA	GRP1			; 7 (14)
	
	LDA	(temp01),y		; 5		
	STA	COLUP0			; 3
	STA	COLUP1			; 3 (27)

	sleep	8

	LDA	Bank5_YesNoText_4,y
	STA	GRP0			; 7 (34)

	LDA	Bank5_YesNoText_5,y
	STA	GRP1			; 7 (41)

	LDA	(temp03),y		; 5		
	STA	COLUP0			; 3
	STA	COLUP1			; 3 (52)

	DEY	
	BPL	Bank5_YesNo_Loop

Bank5_DisplayDeathScreen_Reset	
	LDA	#0
	STA	WSYNC
	STA	GRP0
	STA	GRP1
	
	JMP	Bank5_ReturnFromAnything

Bank5_WasteSomeLines
	STA	WSYNC
	DEY
	BPL	Bank5_WasteSomeLines
	RTS
*
*	Data Section
*

	_align	6
Bank5_YesNo_ColorPointers
	BYTE	#<Bank5_YesNo_Yellow
	BYTE	#>Bank5_YesNo_Yellow
	BYTE	#<Bank5_YesNo_Gray
	BYTE	#>Bank5_YesNo_Gray
	BYTE	#<Bank5_YesNo_Yellow
	BYTE	#>Bank5_YesNo_Yellow

	_align	6
Bank5_YesNo_Yellow
	BYTE	#$1A
	BYTE	#$1C
	BYTE	#$1E
	BYTE	#$1E
	BYTE	#$1C
	BYTE	#$1A

	_align	6
Bank5_YesNo_Gray
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04

	_align	25
Bank5_ContinueColor
	BYTE	#$00
	BYTE	#$00
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04	
	BYTE	#$06
	BYTE	#$08
	BYTE	#$18
	BYTE	#$1A
	BYTE	#$1C		
	BYTE	#$1E
	BYTE	#$0E
	BYTE	#$0E
	BYTE	#$1E
	BYTE	#$1E
	BYTE	#$1C
	BYTE	#$1A
	BYTE	#$18
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00
	BYTE	#$00
	BYTE	#$00

	_align	16
Bank5_ContinuePoz
	BYTE	#0
	BYTE	#1
	BYTE	#2
	BYTE	#4
	BYTE	#6
	BYTE	#9
	BYTE	#12
	BYTE	#16
	BYTE	#20
	BYTE	#16
	BYTE	#12
	BYTE	#9
	BYTE	#6
	BYTE	#4
	BYTE	#2
	BYTE	#1


	_align	2
Bank5_SpellCard_First_HMOVE_P0
	BYTE	#$C0
	BYTE	#$C0	

	_align	2
Bank5_SpellCard_First_HMOVE_P1
	BYTE	#$E0
	BYTE	#$E0	

	_align	2
Bank5_Continue_First_HMOVE_P0
	BYTE	#$B0
	BYTE	#$B0	

	_align	2
Bank5_Continue_First_HMOVE_P1
	BYTE	#$D0
	BYTE	#$D0	

	_align	14

Bank5_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1

	_align	6
Bank5_StarPointers
	BYTE	#<Bank5_Star_0
	BYTE	#>Bank5_Star_0
	BYTE	#<Bank5_Star_1
	BYTE	#>Bank5_Star_1
	BYTE	#<Bank5_Star_2
	BYTE	#>Bank5_Star_2

	_align	6
Bank5_JinJangPointers
	BYTE	#<Bank5_JinJang_0
	BYTE	#>Bank5_JinJang_0
	BYTE	#<Bank5_JinJang_1
	BYTE	#>Bank5_JinJang_1
	BYTE	#<Bank5_JinJang_2
	BYTE	#>Bank5_JinJang_2

	_align  8
Bank5_JingJang_Colors
	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08
	BYTE	#$0a
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04

	_align  8
Bank5_Star_Colors
	BYTE	#$12
	BYTE	#$14
	BYTE	#$16
	BYTE	#$18
	BYTE	#$1a
	BYTE	#$18
	BYTE	#$16
	BYTE	#$14

	_align  8
Bank5_AdderValueOnCounter
	BYTE	#0
	BYTE	#3
	BYTE	#5
	BYTE	#5
	BYTE	#4
	BYTE	#3
	BYTE	#2
	BYTE	#1

	_align	64

Bank5_Star_0
	byte	#%11000011
	byte	#%01100110
	byte	#%00111100
	byte	#%01111110
	byte	#%11111111
	byte	#%00111100
	byte	#%00011000
	byte	#%00001000	; (0)
	byte	#%01100010
	byte	#%00111100
	byte	#%00011000
	byte	#%00111100
	byte	#%01111110
	byte	#%00011000
	byte	#%00001000
	byte	#%00001000	; (1)
	byte	#%00000000
	byte	#%00100100
	byte	#%00011000
	byte	#%00011000
	byte	#%00111100
	byte	#%00001000
	byte	#%00001000
	byte	#%00000000	; (2)
	byte	#%00000000
	byte	#%00000000
	byte	#%00010000
	byte	#%00011100
	byte	#%00111000
	byte	#%00001000
	byte	#%00000000
	byte	#%00000000	; (3)
	byte	#%00010000
	byte	#%00010000
	byte	#%00000000
	byte	#%00011011
	byte	#%11011000
	byte	#%00000000
	byte	#%00001000
	byte	#%00001000	; (4)
	byte	#%00001000
	byte	#%00000000
	byte	#%00000000
	byte	#%10000000
	byte	#%00000001
	byte	#%00000000
	byte	#%00000000
	byte	#%00010000	; (5)
	byte	#%10000011
	byte	#%10000000
	byte	#%00100100
	byte	#%00011000
	byte	#%00011000
	byte	#%00100100
	byte	#%00000001
	byte	#%11000001	; (6)
	byte	#%00000100
	byte	#%01000010
	byte	#%10100100
	byte	#%00011000
	byte	#%00111100
	byte	#%00011001
	byte	#%01001010
	byte	#%00100000	; (7)

	_align	64

Bank5_Star_1
	byte	#%11000011
	byte	#%01100110
	byte	#%00111100
	byte	#%01111110
	byte	#%11111111
	byte	#%00011100
	byte	#%00011000
	byte	#%00001000	; (0)
	byte	#%01000000
	byte	#%01100111
	byte	#%00111100
	byte	#%11100110
	byte	#%01100111
	byte	#%00011001
	byte	#%00011000
	byte	#%00000100	; (1)
	byte	#%00010000
	byte	#%01011010
	byte	#%00100100
	byte	#%01000011
	byte	#%11000010
	byte	#%00100100
	byte	#%01011010
	byte	#%00001000	; (2)
	byte	#%01100110
	byte	#%11000011
	byte	#%00000000
	byte	#%10000001
	byte	#%10000001
	byte	#%00000000
	byte	#%11000011
	byte	#%01100110	; (3)
	byte	#%00000000
	byte	#%00000000
	byte	#%00100100
	byte	#%00011000
	byte	#%00011000
	byte	#%00100100
	byte	#%00000000
	byte	#%00000000	; (4)
	byte	#%00011000
	byte	#%01100110
	byte	#%01000010
	byte	#%10000001
	byte	#%10000001
	byte	#%01000010
	byte	#%01100110
	byte	#%00011000	; (5)
	byte	#%00000000
	byte	#%00000000
	byte	#%00010000
	byte	#%00011000
	byte	#%00111100
	byte	#%00001000
	byte	#%00001000
	byte	#%00000000	; (6)
	byte	#%00000000
	byte	#%01000010
	byte	#%00111100
	byte	#%00011000
	byte	#%01111110
	byte	#%00011000
	byte	#%00001000
	byte	#%00000000	; (7)

	_align	64

Bank5_Star_2
	byte	#%11000011
	byte	#%01100110
	byte	#%00111100
	byte	#%01111110
	byte	#%11111111
	byte	#%00111100
	byte	#%00011000
	byte	#%00001000	; (0)
	byte	#%10000001
	byte	#%11100111
	byte	#%01111110
	byte	#%01111110
	byte	#%01111110
	byte	#%11111111
	byte	#%00111000
	byte	#%00001000	; (1)
	byte	#%11000011
	byte	#%11111111
	byte	#%01111110
	byte	#%01111110
	byte	#%01111110
	byte	#%11111111
	byte	#%11111111
	byte	#%00011100	; (2)
	byte	#%11011011
	byte	#%11100111
	byte	#%01000010
	byte	#%01111110
	byte	#%11011011
	byte	#%11011011
	byte	#%01111110
	byte	#%00111100	; (3)
	byte	#%00011000
	byte	#%01111110
	byte	#%11111111
	byte	#%11000011
	byte	#%10000001
	byte	#%11111111
	byte	#%10011001
	byte	#%01111110	; (4)
	byte	#%00011000
	byte	#%00111100
	byte	#%01111110
	byte	#%01000010
	byte	#%10000001
	byte	#%10000001
	byte	#%11111111
	byte	#%00111100	; (5)
	byte	#%01100110
	byte	#%11000011
	byte	#%10100101
	byte	#%00000000
	byte	#%00000000
	byte	#%10100101
	byte	#%11000011
	byte	#%01100110	; (6)
	byte	#%00000100
	byte	#%01000010
	byte	#%10100100
	byte	#%00011000
	byte	#%00111100
	byte	#%00011001
	byte	#%01001010
	byte	#%00100000	; (7)

	_align	64

Bank5_JinJang_0
	byte	#%00111100
	byte	#%01111010
	byte	#%11011001
	byte	#%11110001
	byte	#%11110001
	byte	#%11100101
	byte	#%01100010
	byte	#%00111100	; (0)
	byte	#%00111100
	byte	#%01100110
	byte	#%11111101
	byte	#%11110001
	byte	#%11100001
	byte	#%11011001
	byte	#%01000010
	byte	#%00111100	; (1)
	byte	#%00111100
	byte	#%01111110
	byte	#%11111011
	byte	#%10011111
	byte	#%10000111
	byte	#%10100001
	byte	#%01000010
	byte	#%00111100	; (2)
	byte	#%00111100
	byte	#%01011110
	byte	#%10011111
	byte	#%10101101
	byte	#%10100101
	byte	#%10000111
	byte	#%01000010
	byte	#%00111100	; (3)
	byte	#%00111100
	byte	#%01000110
	byte	#%10100111
	byte	#%10001111
	byte	#%10001111
	byte	#%10011011
	byte	#%01011110
	byte	#%00111100	; (4)
	byte	#%00111100
	byte	#%01000010
	byte	#%10011001
	byte	#%11000001
	byte	#%11111101
	byte	#%11111111
	byte	#%01100110
	byte	#%00111100	; (5)
	byte	#%00111100
	byte	#%01000010
	byte	#%11000101
	byte	#%11110001
	byte	#%11110001
	byte	#%11011101
	byte	#%01111110
	byte	#%00111100	; (6)
	byte	#%00111100
	byte	#%01111010
	byte	#%11110001
	byte	#%10110101
	byte	#%10110101
	byte	#%11110001
	byte	#%01100010
	byte	#%00111100	; (7)

	_align	64

Bank5_JinJang_1
	byte	#%00111100
	byte	#%01111010
	byte	#%11011001
	byte	#%11110001
	byte	#%11110001
	byte	#%11100101
	byte	#%01100010
	byte	#%00111100	; (0)
	byte	#%00011000
	byte	#%00111100
	byte	#%11111011
	byte	#%11010001
	byte	#%11110101
	byte	#%11100001
	byte	#%01100010
	byte	#%00111100	; (1)
	byte	#%00011000
	byte	#%00111100
	byte	#%01111010
	byte	#%01111010
	byte	#%11010101
	byte	#%11110001
	byte	#%01110010
	byte	#%00111100	; (2)
	byte	#%00011000
	byte	#%01100110
	byte	#%00111100
	byte	#%01110010
	byte	#%11010101
	byte	#%11110001
	byte	#%01110010
	byte	#%00111100	; (3)
	byte	#%00111100
	byte	#%00000000
	byte	#%00111100
	byte	#%01110010
	byte	#%11010101
	byte	#%11110001
	byte	#%01110010
	byte	#%00111100	; (4)
	byte	#%00011000
	byte	#%00000000
	byte	#%00011000
	byte	#%00110100
	byte	#%01110010
	byte	#%01110010
	byte	#%00110100
	byte	#%00011000	; (5)
	byte	#%00000000
	byte	#%00000000
	byte	#%00011000
	byte	#%00011000
	byte	#%00111100
	byte	#%00111100
	byte	#%00011000
	byte	#%00000000	; (6)
	byte	#%00000000
	byte	#%00011000
	byte	#%00110100
	byte	#%01110010
	byte	#%01110010
	byte	#%00100100
	byte	#%00011000
	byte	#%00000000	; (7)

	_align	64

Bank5_JinJang_2
	byte	#%00111100
	byte	#%01111010
	byte	#%11011001
	byte	#%11110001
	byte	#%11110001
	byte	#%11100101
	byte	#%01100010
	byte	#%00111100	; (0)
	byte	#%00011000
	byte	#%00111100
	byte	#%11111011
	byte	#%11010001
	byte	#%11110101
	byte	#%11100001
	byte	#%01100010
	byte	#%00111100	; (1)
	byte	#%00011000
	byte	#%00111100
	byte	#%01111010
	byte	#%11110101
	byte	#%11010001
	byte	#%11100001
	byte	#%01100010
	byte	#%01111110	; (2)
	byte	#%00011000
	byte	#%00110100
	byte	#%01110010
	byte	#%11110001
	byte	#%11010101
	byte	#%11110001
	byte	#%11111001
	byte	#%01100110	; (3)
	byte	#%00000000
	byte	#%00011000
	byte	#%00110100
	byte	#%01110010
	byte	#%11110001
	byte	#%11111111
	byte	#%01100110
	byte	#%00000000	; (4)
	byte	#%00000000
	byte	#%00000000
	byte	#%00011000
	byte	#%00111100
	byte	#%01110010
	byte	#%01111110
	byte	#%00100100
	byte	#%00000000	; (5)
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00011000
	byte	#%00111100
	byte	#%00011000
	byte	#%00000000
	byte	#%00000000	; (6)
	byte	#%00000000
	byte	#%00011000
	byte	#%00110100
	byte	#%01110010
	byte	#%01110010
	byte	#%00100100
	byte	#%00011000
	byte	#%00000000	; (7)

	_align	80

Bank5_Numbers
	byte	#%00111100
	byte	#%01100110
	byte	#%01001110
	byte	#%01001010
	byte	#%01010010
	byte	#%01110010
	byte	#%01100110
	byte	#%00111100	; (0)
	byte	#%00111100
	byte	#%00011000
	byte	#%00011000
	byte	#%00011000
	byte	#%01111000
	byte	#%00111000
	byte	#%00011000
	byte	#%00011000	; (1)
	byte	#%01111110
	byte	#%01100010
	byte	#%00110000
	byte	#%00011000
	byte	#%00001100
	byte	#%00000110
	byte	#%01101110
	byte	#%00111100	; (2)
	byte	#%00111100
	byte	#%01001110
	byte	#%00000110
	byte	#%00011100
	byte	#%00011100
	byte	#%00000110
	byte	#%01001110
	byte	#%00111100	; (3)
	byte	#%00001100
	byte	#%00001100
	byte	#%00001100
	byte	#%01111110
	byte	#%01101100
	byte	#%01100000
	byte	#%00110000
	byte	#%00011000	; (4)
	byte	#%00111000
	byte	#%01101100
	byte	#%00000110
	byte	#%00110110
	byte	#%01111100
	byte	#%01000000
	byte	#%01011110
	byte	#%01111110	; (5)
	byte	#%00111100
	byte	#%01100110
	byte	#%01000010
	byte	#%01110110
	byte	#%01111100
	byte	#%01000000
	byte	#%01100110
	byte	#%00111100	; (6)
	byte	#%00110000
	byte	#%00110000
	byte	#%00110000
	byte	#%00011000
	byte	#%00001100
	byte	#%00000110
	byte	#%01110110
	byte	#%01111110	; (7)
	byte	#%00111100
	byte	#%01000110
	byte	#%01100010
	byte	#%00011100
	byte	#%00111000
	byte	#%01000110
	byte	#%01100010
	byte	#%00111100	; (8)
	byte	#%00111100
	byte	#%01100110
	byte	#%00000010
	byte	#%00000110
	byte	#%00111110
	byte	#%01000110
	byte	#%01100010
	byte	#%00111100	; (9)

	_align	16

Bank5_VicaVersa	
Bank5_SpellCard_FG
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

	_align	16
Bank5_SpellCard_BG
	BYTE	#$0E
	BYTE	#$0C
	BYTE	#$0A
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08
	BYTE	#$0A
	BYTE	#$0C
	BYTE	#$0E

	_align	2
Bank5_SpellCard_Col_0
	BYTE	#<Bank5_Eiki64px_00
	BYTE	#>Bank5_Eiki64px_00

	_align	2
Bank5_SpellCard_Col_1
	BYTE	#<Bank5_Eiki64px_01
	BYTE	#>Bank5_Eiki64px_01

	_align	2
Bank5_SpellCard_Col_2
	BYTE	#<Bank5_Eiki64px_02
	BYTE	#>Bank5_Eiki64px_02

	_align	2
Bank5_SpellCard_Col_3
	BYTE	#<Bank5_Eiki64px_03
	BYTE	#>Bank5_Eiki64px_03

	_align	2
Bank5_SpellCard_Col_4
	BYTE	#<Bank5_Eiki64px_04
	BYTE	#>Bank5_Eiki64px_04

	_align	2
Bank5_SpellCard_Col_5
	BYTE	#<Bank5_Eiki64px_05
	BYTE	#>Bank5_Eiki64px_05

	_align	2
Bank5_SpellCard_Col_6
	BYTE	#<Bank5_Eiki64px_06
	BYTE	#>Bank5_Eiki64px_06

	_align	2
Bank5_SpellCard_Col_7
	BYTE	#<Bank5_Eiki64px_07
	BYTE	#>Bank5_Eiki64px_07

	_align	40
Bank5_Eiki64px_00
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000	

	_align	40
Bank5_Eiki64px_01
	BYTE	#%00000011
	BYTE	#%00000011
	BYTE	#%00000010
	BYTE	#%00000110
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000011
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000

	_align	40
Bank5_Eiki64px_02
	BYTE	#%10000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000011
	BYTE	#%00111111
	BYTE	#%01011110
	BYTE	#%00111111
	BYTE	#%11101010
	BYTE	#%11110001
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000110
	BYTE	#%00001100
	BYTE	#%00011000
	BYTE	#%00110000
	BYTE	#%00100000
	BYTE	#%01100000
	BYTE	#%01101100
	BYTE	#%11101100
	BYTE	#%01101000
	BYTE	#%01111110
	BYTE	#%01101110
	BYTE	#%00110110
	BYTE	#%00110111
	BYTE	#%00011111
	BYTE	#%00000111
	BYTE	#%00000000
	BYTE	#%00000011
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000000	

	_align	40
Bank5_Eiki64px_03
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%10100000
	BYTE	#%00000000
	BYTE	#%11010000
	BYTE	#%11010000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00000011
	BYTE	#%00000000
	BYTE	#%00000011
	BYTE	#%01000111
	BYTE	#%00001110
	BYTE	#%00011111
	BYTE	#%00111111
	BYTE	#%00111101
	BYTE	#%00011000
	BYTE	#%00011010
	BYTE	#%00001010
	BYTE	#%01000111
	BYTE	#%01001000
	BYTE	#%01110000
	BYTE	#%00110111
	BYTE	#%00000000
	BYTE	#%11001110
	BYTE	#%11011110
	BYTE	#%10000001
	BYTE	#%11110000
	BYTE	#%01111111
	BYTE	#%10111111
	BYTE	#%00000011
	BYTE	#%01000011
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00000000	

	_align	40
Bank5_Eiki64px_04
	BYTE	#%11010101
	BYTE	#%00001010
	BYTE	#%00100101
	BYTE	#%00110000
	BYTE	#%00000000
	BYTE	#%11100000
	BYTE	#%11000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%11000000
	BYTE	#%11000000
	BYTE	#%11111000
	BYTE	#%11110000
	BYTE	#%11111000
	BYTE	#%11111110
	BYTE	#%11001111
	BYTE	#%11111111
	BYTE	#%11101111
	BYTE	#%11101101
	BYTE	#%11111000
	BYTE	#%11111000
	BYTE	#%11111010
	BYTE	#%11101110
	BYTE	#%00101000
	BYTE	#%01111001
	BYTE	#%11111111
	BYTE	#%11111100
	BYTE	#%11100000
	BYTE	#%00001001
	BYTE	#%01111101
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%00011111
	BYTE	#%01111010
	BYTE	#%10101110
	BYTE	#%11111100
	BYTE	#%01110100
	BYTE	#%11101100
	BYTE	#%00110000	

	_align	40
Bank5_Eiki64px_05
	BYTE	#%11100000
	BYTE	#%11000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000001
	BYTE	#%10000100
	BYTE	#%01000011
	BYTE	#%00001111
	BYTE	#%00111110
	BYTE	#%01000000
	BYTE	#%00000100
	BYTE	#%00000101
	BYTE	#%00000101
	BYTE	#%00001111
	BYTE	#%00011100
	BYTE	#%00010000
	BYTE	#%00010010
	BYTE	#%00010110
	BYTE	#%10000100
	BYTE	#%10000000
	BYTE	#%11000001
	BYTE	#%10000000
	BYTE	#%10100100
	BYTE	#%10111100
	BYTE	#%01111100
	BYTE	#%11111100
	BYTE	#%11011100
	BYTE	#%00000001
	BYTE	#%00100110
	BYTE	#%11000000
	BYTE	#%00000000
	BYTE	#%00111110
	BYTE	#%11111110
	BYTE	#%11011100
	BYTE	#%00000100
	BYTE	#%10000010
	BYTE	#%00000001
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01100000	

	_align	40
Bank5_Eiki64px_06
	BYTE	#%00111000
	BYTE	#%00110000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%10000001
	BYTE	#%00000011
	BYTE	#%10001111
	BYTE	#%00111000
	BYTE	#%01100000
	BYTE	#%11100000
	BYTE	#%11000000
	BYTE	#%10000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%11001100
	BYTE	#%01010100
	BYTE	#%01001100
	BYTE	#%01111100
	BYTE	#%01110000
	BYTE	#%01100000
	BYTE	#%11100000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%10000000
	BYTE	#%00000000
	BYTE	#%00000000	

	_align	40
Bank5_Eiki64px_07
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%01110000
	BYTE	#%11110000
	BYTE	#%11100000
	BYTE	#%10000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000
	BYTE	#%00000000	

	_align	9
Bank5_YouDiedAmplitude
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$06
	BYTE	#$04
	BYTE	#$02
	BYTE	#$00
	BYTE	#0
	
	_align	9
Bank5_YouDiedText_0
	BYTE	#%00001111
	BYTE	#%00000110
	BYTE	#%00000110
	BYTE	#%00000110
	BYTE	#%00001111
	BYTE	#%00011001
	BYTE	#%00010000
	BYTE	#%00111001
	BYTE	#0

	_align	6
Bank5_ContinueText_1
	BYTE	#%00000001
	BYTE	#%00000010
	BYTE	#%00000010
	BYTE	#%00000010
	BYTE	#%00000001
	BYTE	#%00000000

	_align	9
Bank5_YouDiedText_1
	BYTE	#%00001110
	BYTE	#%00010001
	BYTE	#%00110001
	BYTE	#%00110001
	BYTE	#%00110001
	BYTE	#%10110001
	BYTE	#%10010001
	BYTE	#%11001110
	BYTE	#0

	_align	6
Bank5_YesNoText_2
	BYTE	#%11100111
	BYTE	#%01001000
	BYTE	#%11101111
	BYTE	#%10101001
	BYTE	#%10100110
	BYTE	#%10100000

	_align	6
Bank5_ContinueText_2
	BYTE	#%10011001
	BYTE	#%00100101
	BYTE	#%00100101
	BYTE	#%00100101
	BYTE	#%10011001
	BYTE	#%00000000

	_align	9
Bank5_YouDiedText_2
	BYTE	#%00011110
	BYTE	#%00010010
	BYTE	#%10110011
	BYTE	#%10100001
	BYTE	#%10100001
	BYTE	#%10100001
	BYTE	#%00110011
	BYTE	#%00110011
	BYTE	#0

	_align	6
Bank5_YesNoText_3
	BYTE	#%01100000
	BYTE	#%00010000
	BYTE	#%00100000
	BYTE	#%01000000
	BYTE	#%00110000
	BYTE	#%00000000

	_align	6
Bank5_ContinueText_3
	BYTE	#%00100100
	BYTE	#%00100100
	BYTE	#%01100100
	BYTE	#%10100100
	BYTE	#%00101110
	BYTE	#%00000000

	_align	9
Bank5_YouDiedText_3
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#%00000001
	BYTE	#0

	_align	6
Bank5_YesNoText_4
	BYTE	#%00001000
	BYTE	#%00001000
	BYTE	#%00001001
	BYTE	#%00001010
	BYTE	#%00001100
	BYTE	#%00001000

	_align	6
Bank5_ContinueText_4
	BYTE	#%10100100
	BYTE	#%10100101
	BYTE	#%10101101
	BYTE	#%10110101
	BYTE	#%10100101
	BYTE	#%00000000

	_align	9
Bank5_YouDiedText_4
	BYTE	#%11100011
	BYTE	#%10010001
	BYTE	#%00001000
	BYTE	#%00011000
	BYTE	#%00011000
	BYTE	#%00001000
	BYTE	#%10010001
	BYTE	#%11100011
	BYTE	#0

	_align	6
Bank5_YesNoText_5
	BYTE	#%10011000
	BYTE	#%10100100
	BYTE	#%10100100
	BYTE	#%10100100
	BYTE	#%10011000
	BYTE	#%10000000

	_align	6
Bank5_ContinueText_5
	BYTE	#%11001110
	BYTE	#%00101000
	BYTE	#%00101100
	BYTE	#%00101000
	BYTE	#%00101110
	BYTE	#%00000000

	_align	9
Bank5_YouDiedText_5
	BYTE	#%11101111
	BYTE	#%11001100
	BYTE	#%10001000
	BYTE	#%10001110
	BYTE	#%10001110
	BYTE	#%10001000
	BYTE	#%11001100
	BYTE	#%11101111
	BYTE	#0

	_align	6
Bank5_ContinueText_6
	BYTE	#%01000000
	BYTE	#%00000000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%00010000
	BYTE	#%11100000

	_align	9
Bank5_YouDiedText_6
	BYTE	#%10111100
	BYTE	#%00110010
	BYTE	#%00100001
	BYTE	#%00100011
	BYTE	#%00100011
	BYTE	#%00100001
	BYTE	#%00110010
	BYTE	#%10111100
	BYTE	#0

	_align	9
Bank5_YouDiedText_7
	BYTE	#%00111000
	BYTE	#%00000000
	BYTE	#%00010000
	BYTE	#%00111000
	BYTE	#%00111000
	BYTE	#%00111000
	BYTE	#%00111000
	BYTE	#%00111000
	BYTE	#0

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

LandScape_Lines = 4
LandScape_Lines_From = 14


Bank6_LandScape
	LDA	#$F0
	STA	PF0

	LDA	#$00
	STA	COLUPF

	LDA	#%00000101
	STA	CTRLPF

	LDA	WastingLinesCounter
	AND	#15
	STA	temp17

	LDA	#LandScape_Lines_From
	SEC
	SBC	temp17
	STA	temp17

	LDA	#LandScape_Lines
	STA	temp01

	CLC

	LDA 	LevelAndCharge
	AND	#%11100000
	ROL
	ROL
	ROL
	ROL
	TAX
	DEX
	LDA	Bank6_LandScape_BaseColor,x
	STA	temp02

	LDA	LandScape
	AND	#%00000111
	CLC
	ADC	#LandScape_Lines
	TAX

Bank6_LandScape_Loop
	LDA	Bank6_LandScape_Amplitude,x
	CLC
	ADC	temp02
	STA	temp03

	LDA	#5
	SEC
	SBC	temp01
	TAY
	DEY

Bank6_LandScape_SubLoop
	STA	WSYNC
	
	LDA	temp03
	STA	COLUBK

	DEC	temp17	
	DEY
	BPL	Bank6_LandScape_SubLoop

	DEX
	DEC	temp01

	LDA	temp17
	BPL	Bank6_LandScape_Loop

Bank6_LandScape_Ended
	LDA	#0
	STA	WSYNC
	STA	PF2
	STA	COLUBK

Bank6_ReturnFromAnything
	LDX	temp19
	CPX	#255
	BNE	Bank6_ReturnNoRTS
Bank6_Return
	RTS
Bank6_ReturnNoRTS
	TXA
	INX

	TAY

	ASL		
	TAY

	LDA	Bank6_Return_JumpTable,y
   	pha
   	lda	Bank6_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump

Bank6_Return
	RTS

Bank6_Display_Name
*
*	temp01 - 02: Pointer for text P0-0.
*	temp03 - 04: Pointer for text P1-0.
*	temp05 - 06: Pointer for text P0-1.
*	temp07 - 08: Pointer for text P1-1.
*	temp09 - BaseColor
*
	LDA	#$01
	STA	NUSIZ0
	STA	NUSIZ1
	
	LDA	SpellPicture
	AND	#$F0
	LSR
	LSR
	LSR
	TAX	
	
	LDA	Bank6_Character_Names_Pointers_0,x
	STA	temp01
	LDA	Bank6_Character_Names_Pointers_0+1,x
	STA	temp02

	LDA	Bank6_Character_Names_Pointers_1,x
	STA	temp03
	LDA	Bank6_Character_Names_Pointers_1+1,x
	STA	temp04

	LDA	Bank6_Character_Names_Pointers_2,x
	STA	temp05
	LDA	Bank6_Character_Names_Pointers_2+1,x
	STA	temp06

	LDA	Bank6_Character_Names_Pointers_3,x
	STA	temp07
	LDA	Bank6_Character_Names_Pointers_3+1,x
	STA	temp08

	STA	WSYNC
	STA	HMCLR

	TXA
	LSR
	TAX
	LDA	Bank6_Character_Text_BaseColors,x
	STA	temp09

	LDA	SpellPicture
	AND	#$0F
	LSR
	TAX	
	LDA	Bank6_Character_Text_BaseColor_Adders,x
	ORA	temp09
	STA	temp09

	LDY	#4
	STA	RESP0
	STA	RESP1

	LDA	counter
	AND	#1
	TAX	

	LDA	#$00
	STA	HMP0
	
	LDA	#$10
	STA	HMP1

	STA	WSYNC
	STA	HMOVE

**	LDA	#255
**	STA	GRP0
**	STA	GRP1

**	LDA	#$88
**	STA	COLUP0
**	LDA	#$1e
**	STA	COLUP0

Bank6_Display_Name_Loop
	STA	WSYNC	

	LDA	(temp01),y
	STA	GRP0		; 8

	LDA	(temp03),y
	STA	GRP1		; 8 (16)

	LDA	Bank6_Character_Text_Colors,y	; 4 (20)
	CLC					; 2 (22)
	ADC	temp09				; 3 (25)
	STA	COLUP0				 
	STA	COLUP1				; 6 (31)

	sleep	2

	LAX	(temp07),y
	LDA	(temp05),y			; 10 (41)
	STA	GRP0		
	STX	GRP1	
	
	DEY
	BPL	Bank6_Display_Name_Loop

Bank6_Display_Name_Ended
	LDA	#0
	STA	WSYNC
	STA	HMCLR
	STA	GRP0
	STA	GRP1

	JMP	Bank6_ReturnFromAnything

Bank6_DrawCommonEnemies
*
*	The enemy should be player 1, so the explosion would overlap the sprites as P0.
*
*	temp03 - temp04: Death Sprite Pointers
*
	LDX	#0
	STX	NUSIZ0

	LDA	EnemyX
	CMP	#16
	BCS	Bank6_WasNormal

	LDA	EnemySettings
	AND	#3
	CMP	#$02
	BCC	Bank6_WasNormal2
	
	STX	NUSIZ1
	LDA	EnemyX
	CLC
	ADC	#36
	STA	temp02

	JMP	Bank6_WasStrange
Bank6_WasNormal
	LDA	EnemySettings
	AND	#3
Bank6_WasNormal2
	STA	NUSIZ1

	LDA	EnemyX
	STA	temp02

Bank6_WasStrange
	LDA	DeathX
	STA	temp01

	LDA	#%00000101
	STA	CTRLPF

	LDA	#0
	STA	COLUPF

	LDA	#255
	STA	PF0

	LDA	EnemySettings2
	AND	#3
	ASL
	TAX

	LDA	Bank6_Death_Sprite_Pointers,x
	STA	temp03

	LDA	Bank6_Death_Sprite_Pointers+1,x
	STA	temp04

	LDX	#1
Bank6_NextHorPoz
	STA	WSYNC
	LDA	temp01,x
Bank6_DivideLoop
	sbc	#15
   	bcs	Bank6_DivideLoop
   	sta	temp01,X
   	sta	RESP0,X	
	DEX
	BPL	Bank6_NextHorPoz	

	ldx	#1
Bank6_setFine
   	lda	temp01,x
	CLC
	ADC	#16
	TAY
   	lda	Bank6_FineAdjustTable,y
   	sta	HMP0,x		
	DEX
	BPL	Bank6_setFine

	STA	WSYNC
	STA	HMOVE

	LDY	#7
	LDA	EnemyBackColor	
	STA	WSYNC
	STA	COLUBK

	LDA	DeathX
	CMP	#0
	BEQ	Bank6_WasteSomeLoop
	DEY

Bank6_WasteSomeLoop
	STA	WSYNC

	DEY	
	BPL	Bank6_WasteSomeLoop

	LDY	#11
	
Bank6_Display_Common_Enemy_Loop
	STA	WSYNC
	
	LDA	(EnemySpritePointer),y
	STA	GRP1

	LDA	(temp03),y
	STA	GRP0

	LDA	(EnemyColorPointer),y
	STA	COLUP1
	
	LDA	Bank6_Common_Enemy_Death_Colors,y
	STA	COLUP0

	DEY
	BPL	Bank6_Display_Common_Enemy_Loop

Bank6_DrawCommonEnemies_Ended
	LDA	#0
	STA	WSYNC
	STA	HMCLR
	STA	PF0
	STA	COLUBK
	STA	COLUPF
	STA	GRP0
	STA	GRP1
	STA	NUSIZ1
	STA	NUSIZ0
	STA	CTRLPF

	JMP	Bank6_ReturnFromAnything

*
*	Data Section
*

	_align	16
Bank6_FineAdjustTable
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

	_align	8
Bank6_Character_Text_BaseColor_Adders	
	BYTE	#$04
	BYTE	#$04
	BYTE	#$04
	BYTE	#$04
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08
	BYTE	#$0A

	_align	8
Bank6_Character_Text_BaseColors
	BYTE	#$80
	BYTE	#$40
	BYTE	#$70
	BYTE	#$10
	BYTE	#$40
	BYTE	#$80
	BYTE	#$90
	BYTE	#$00
	BYTE	#$30

	_align	5
Bank6_Character_Text_Colors
	BYTE	#$00
	BYTE	#$02
	BYTE	#$04
	BYTE	#$02
	BYTE	#$04

	_align	12
Bank6_Character_Names_Pointers_0
	BYTE	#<Bank6_Character_Names_ShikiEiki_0
	BYTE	#>Bank6_Character_Names_ShikiEiki_0
	BYTE	#<Bank6_Character_Names_Komachi_0
	BYTE	#>Bank6_Character_Names_Komachi_0
	BYTE	#<Bank6_Character_Names_Reimu_0
	BYTE	#>Bank6_Character_Names_Reimu_0
	BYTE	#<Bank6_Character_Names_Cirnobyl_0
	BYTE	#>Bank6_Character_Names_Cirnobyl_0
	BYTE	#<Bank6_Character_Names_Rumia_0
	BYTE	#>Bank6_Character_Names_Rumia_0
	BYTE	#<Bank6_Character_Names_Sariel_0
	BYTE	#>Bank6_Character_Names_Sariel_0

	_align	12
Bank6_Character_Names_Pointers_1
	BYTE	#<Bank6_Character_Names_ShikiEiki_1
	BYTE	#>Bank6_Character_Names_ShikiEiki_1
	BYTE	#<Bank6_Character_Names_Komachi_1
	BYTE	#>Bank6_Character_Names_Komachi_1
	BYTE	#<Bank6_Character_Names_Reimu_1
	BYTE	#>Bank6_Character_Names_Reimu_1
	BYTE	#<Bank6_Character_Names_Cirnobyl_1
	BYTE	#>Bank6_Character_Names_Cirnobyl_1
	BYTE	#<Bank6_Character_Names_Rumia_1
	BYTE	#>Bank6_Character_Names_Rumia_1
	BYTE	#<Bank6_Character_Names_Sariel_1
	BYTE	#>Bank6_Character_Names_Sariel_1

	_align	12
Bank6_Character_Names_Pointers_2
	BYTE	#<Bank6_Character_Names_ShikiEiki_2
	BYTE	#>Bank6_Character_Names_ShikiEiki_2
	BYTE	#<Bank6_Character_Names_Komachi_2
	BYTE	#>Bank6_Character_Names_Komachi_2
	BYTE	#<Bank6_Character_Names_Reimu_2
	BYTE	#>Bank6_Character_Names_Reimu_2
	BYTE	#<Bank6_Character_Names_Cirnobyl_2
	BYTE	#>Bank6_Character_Names_Cirnobyl_2
	BYTE	#<Bank6_Character_Names_Rumia_2
	BYTE	#>Bank6_Character_Names_Rumia_2
	BYTE	#<Bank6_Character_Names_Sariel_2
	BYTE	#>Bank6_Character_Names_Sariel_2

	_align	12
Bank6_Character_Names_Pointers_3
	BYTE	#<Bank6_Character_Names_ShikiEiki_3
	BYTE	#>Bank6_Character_Names_ShikiEiki_3
	BYTE	#<Bank6_Character_Names_Komachi_3
	BYTE	#>Bank6_Character_Names_Komachi_3
	BYTE	#<Bank6_Character_Names_Reimu_3
	BYTE	#>Bank6_Character_Names_Reimu_3
	BYTE	#<Bank6_Character_Names_Cirnobyl_3
	BYTE	#>Bank6_Character_Names_Cirnobyl_3
	BYTE	#<Bank6_Character_Names_Rumia_3
	BYTE	#>Bank6_Character_Names_Rumia_3
	BYTE	#<Bank6_Character_Names_Sariel_3
	BYTE	#>Bank6_Character_Names_Sariel_3

	_align	5
Bank6_Character_Names_Sariel_0
	BYTE	#%11001010
	BYTE	#%00101010
	BYTE	#%01001110
	BYTE	#%10001010
	BYTE	#%01100100

	_align	5
Bank6_Character_Names_Rumia_0
	BYTE	#%10100100
	BYTE	#%10101010
	BYTE	#%11001010
	BYTE	#%10101010
	BYTE	#%11001010

	_align	5
Bank6_Character_Names_Cirnobyl_0
	BYTE	#%01101010
	BYTE	#%10001010
	BYTE	#%10001011
	BYTE	#%10001010
	BYTE	#%01101011

	_align	5
Bank6_Character_Names_Reimu_0
	BYTE	#%10101110
	BYTE	#%10101000
	BYTE	#%11001100
	BYTE	#%10101000
	BYTE	#%11001110

	_align	5
Bank6_Character_Names_Komachi_0
	BYTE	#%10010010
	BYTE	#%10100101
	BYTE	#%11000101
	BYTE	#%10100101
	BYTE	#%10010010

	_align	5
Bank6_Character_Names_ShikiEiki_0
	BYTE	#%11001010
	BYTE	#%00101010
	BYTE	#%01001110
	BYTE	#%10001010
	BYTE	#%01101010

	_align	5
Bank6_Character_Names_Sariel_1
	BYTE	#%10101011
	BYTE	#%10101010
	BYTE	#%11001011
	BYTE	#%10101010
	BYTE	#%11001011

	_align	5
Bank6_Character_Names_Rumia_1
	BYTE	#%10001010
	BYTE	#%10001010
	BYTE	#%10101010
	BYTE	#%11011010
	BYTE	#%10001010

	_align	5
Bank6_Character_Names_Cirnobyl_1
	BYTE	#%10100100
	BYTE	#%10100101
	BYTE	#%00101101
	BYTE	#%10110101
	BYTE	#%00100100

	_align	5
Bank6_Character_Names_Reimu_1
	BYTE	#%10100010
	BYTE	#%10100010
	BYTE	#%10101010
	BYTE	#%10110110
	BYTE	#%10100010

	_align	5
Bank6_Character_Names_Komachi_1
	BYTE	#%01000101
	BYTE	#%01000101
	BYTE	#%01010101
	BYTE	#%01101101
	BYTE	#%01000100

	_align	5
Bank6_Character_Names_ShikiEiki_1
	BYTE	#%10100101
	BYTE	#%10101001
	BYTE	#%10110001
	BYTE	#%10101001
	BYTE	#%10100101

	_align	5
Bank6_Character_Names_Sariel_2
	BYTE	#%10111000
	BYTE	#%00100010
	BYTE	#%00100000
	BYTE	#%00100010
	BYTE	#%10100000

	_align	5
Bank6_Character_Names_Rumia_2
	BYTE	#%10100000
	BYTE	#%10101000
	BYTE	#%11100000
	BYTE	#%10101000
	BYTE	#%01000000

	_align	5
Bank6_Character_Names_Cirnobyl_2
	BYTE	#%10011000
	BYTE	#%01010100
	BYTE	#%01011000
	BYTE	#%01010101
	BYTE	#%10011001

	_align	5
Bank6_Character_Names_Reimu_2
	BYTE	#%01000000
	BYTE	#%10101000
	BYTE	#%10100000
	BYTE	#%10101000
	BYTE	#%10100000

	_align	5
Bank6_Character_Names_Komachi_2
	BYTE	#%01001101
	BYTE	#%01010001
	BYTE	#%11010001
	BYTE	#%01010001
	BYTE	#%10001101

	_align	5
Bank6_Character_Names_ShikiEiki_2
	BYTE	#%01110101
	BYTE	#%01000101
	BYTE	#%01100101
	BYTE	#%01000101
	BYTE	#%01110101

	_align	5
Bank6_Character_Names_Cirnobyl_3
	BYTE	#%10011100
	BYTE	#%10010001
	BYTE	#%10010000
	BYTE	#%01010001
	BYTE	#%01010000

	_align	5
Bank6_Character_Names_Komachi_3
	BYTE	#%01010000
	BYTE	#%01010100
	BYTE	#%11010000
	BYTE	#%01010100
	BYTE	#%01010000

	_align	5
Bank6_Character_Names_ShikiEiki_3
	BYTE	#%00101000
	BYTE	#%01001001
	BYTE	#%10001000
	BYTE	#%01001001
	BYTE	#%00101000

	_align	6
Bank6_LandScape_BaseColor
	BYTE	#$40
	BYTE	#$D0
	BYTE	#$D0
	BYTE	#$D0
	BYTE	#$D0
	BYTE	#$D0

	_align	12
Bank6_LandScape_Amplitude
	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08

	BYTE	#$06
	BYTE	#$08
	BYTE	#$06
	BYTE	#$04

	BYTE	#$02
	BYTE	#$04
	BYTE	#$06
	BYTE	#$08

	_align	14
Bank6_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1

	_align	8
Bank6_Death_Sprite_Pointers
	BYTE	#<Bank6_Common_Enemy_Death_0
	BYTE	#>Bank6_Common_Enemy_Death_0
	BYTE	#<Bank6_Common_Enemy_Death_1
	BYTE	#>Bank6_Common_Enemy_Death_1
	BYTE	#<Bank6_Common_Enemy_Death_2
	BYTE	#>Bank6_Common_Enemy_Death_2
	BYTE	#<Bank6_Common_Enemy_Death_3
	BYTE	#>Bank6_Common_Enemy_Death_3

	_align	12
Bank6_Common_Enemy_Death_0
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00100100
	byte	#%01000010
	byte	#%00011000
	byte	#%00011000
	byte	#%01000010
	byte	#%00100100
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000	

	_align	12
Bank6_Common_Enemy_Death_1
	byte	#%00000000
	byte	#%00000000
	byte	#%10000001
	byte	#%01011010
	byte	#%00000000
	byte	#%01000010
	byte	#%01000010
	byte	#%00000000
	byte	#%01011010
	byte	#%10000001
	byte	#%00000000
	byte	#%00000000	

	_align	12
Bank6_Common_Enemy_Death_2
	byte	#%01100110
	byte	#%10000001
	byte	#%00011000
	byte	#%00000000
	byte	#%00100100
	byte	#%10000001
	byte	#%10000001
	byte	#%00100100
	byte	#%00000000
	byte	#%00011000
	byte	#%10000001
	byte	#%01100110	

	_align	12
Bank6_Common_Enemy_Death_Colors
	byte	#$02
	byte	#$04
	byte	#$06
	byte	#$04
	byte	#$08
	byte	#$0a
	byte	#$0a
	byte	#$08
	byte	#$04
	byte	#$06
	byte	#$04
	byte	#$02

	_align	12
Bank6_Common_Enemy_Soul_0
	byte	#%00000000
	byte	#%00111100
	byte	#%01100110
	byte	#%11111111
	byte	#%11111111
	byte	#%10011001
	byte	#%11111111
	byte	#%01111110
	byte	#%01111110
	byte	#%00111100
	byte	#%00011000
	byte	#%00001000
	
	_align	12
Bank6_Common_Enemy_Soul_1
	byte	#%00111100
	byte	#%01100110
	byte	#%11000011
	byte	#%11111111
	byte	#%10011001
	byte	#%10111101
	byte	#%11111111
	byte	#%11111111
	byte	#%01111110
	byte	#%00111100
	byte	#%00011110
	byte	#%00000111	

	_align	12
Bank6_Common_Enemy_Soul_2
	byte	#%00000000
	byte	#%00000000
	byte	#%00111100
	byte	#%01111110
	byte	#%11100111
	byte	#%11111111
	byte	#%10011001
	byte	#%11111111
	byte	#%01111110
	byte	#%00111100
	byte	#%00111000
	byte	#%01110000	

	_align	12
Bank6_Soul_Colors
	byte	#$46
	byte	#$48
	byte	#$4a
	byte	#$4c
	byte	#$4e
	byte	#$4c
	byte	#$4a
	byte	#$4c
	byte	#$4e
	byte	#$4c
	byte	#$4a
	byte	#$48

	_align	12
Bank6_Skull_Sprite_0
	byte	#%00000000	
	byte	#%11000011
	byte	#%10000001
	byte	#%00011000
	byte	#%00100100
	byte	#%00111100
	byte	#%01100110
	byte	#%01011010
	byte	#%01111110
	byte	#%00111100
	byte	#%10000001
	byte	#%11000011

	_align	12
Bank6_Skull_Sprite_1
	byte	#%00000000	
	byte	#%01100110
	byte	#%10011001
	byte	#%10100101
	byte	#%00000000
	byte	#%00000000
	byte	#%00111100
	byte	#%01100110
	byte	#%01011010
	byte	#%11111111
	byte	#%10111101
	byte	#%01100110
	byte	#%00000000	

	_align	12
Bank6_Skull_Sprite_2
	byte	#%00100100
	byte	#%01100110
	byte	#%11011011
	byte	#%00111100
	byte	#%01100110
	byte	#%01011010
	byte	#%01111110
	byte	#%00111100
	byte	#%11000011
	byte	#%01100110
	byte	#%00100100


	_align	12
Bank6_Skull_Colors
	byte	#$9E
	byte	#$9C
	byte	#$9A
	byte	#$AC
	byte	#$AE
	byte	#$AE
	byte	#$AE
	byte	#$AE
	byte	#$AC
	byte	#$9A
	byte	#$9C
	byte	#$9E

	_align	24
Bank6_Ghost_Sprite_0
	byte	#%00001000	
	byte	#%00010000
	byte	#%00011000
	byte	#%01001010
	byte	#%01011010
	byte	#%01111110
	byte	#%00111100
	byte	#%00011000
	byte	#%00111100
	byte	#%01100110
	byte	#%01011010
	byte	#%00111100
Bank6_Character_Names_Sariel_3
Bank6_Character_Names_Rumia_3
Bank6_Character_Names_Reimu_3
Bank6_Enemy_Sprite_Empty
Bank6_Common_Enemy_Death_3
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000

	_align	12
Bank6_Ghost_Sprite_1
	byte	#%00011000	
	byte	#%00100000
	byte	#%00110000
	byte	#%00011000
	byte	#%00011000
	byte	#%00111100
	byte	#%01111100
	byte	#%11011011
	byte	#%00100100
	byte	#%01111110
	byte	#%01011010
	byte	#%00111100

	_align	12
Bank6_Ghost_Sprite_2
	byte	#%00001100	
	byte	#%00011010
	byte	#%00110000
	byte	#%00111000
	byte	#%00111000
	byte	#%10111101
	byte	#%11100111
	byte	#%00100100
	byte	#%01111110
	byte	#%01011010
	byte	#%00111100
	byte	#%00000000

	_align	19
Bank6_Ghost_Sprite_3
	byte	#%01110000	
	byte	#%11000000
	byte	#%11100000
	byte	#%01111000
	byte	#%00100100
	byte	#%00100100
	byte	#%11100111
	byte	#%10111101
	byte	#%01011010
	byte	#%01111110
	byte	#%00111100
	byte	#%00000000

	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
*	byte	#%00000000
*	byte	#%00000000
*	byte	#%00000000
*	byte	#%00000000
*	byte	#%00000000
*	byte	#%00000000

	_align	12
Bank6_Ghost_Colors
	byte	#$12
	byte	#$14
	byte	#$16
	byte	#$18
	byte	#$1A
	byte	#$1C
	byte	#$1E
	byte	#$1E
	byte	#$1C
	byte	#$1A
	byte	#$18
	byte	#$16

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
*
*	We can have a max. number of danmaku of 8 on screen, depending on
*	the difficulty.
*	Every type of danmaku have a cost value. 
*	You can have at least one danmaku on screen, even if
*	it has a larger value than the limit, but by the second one,
*	the sum shouldn't exceed the limit.
*
*	We can only add one danmaku in a frame.
*
*	Each danmaku is stored on two bytes on SARA:
*
*	Danmaku_Settings:
*	-----------------
*	0-3: Danmaku Y (0-16)
*	4-7: Danmaku Type (we can have 15 types)
*
*	Danmaku_Poz:
*	------------
*	0-4: Danmaku X (0-32)
*	5-7: Danmaku Extra Settings
*
*	X or Y settings are sometimes controllers for a type.
*
*	Danmaku_SettingsW 
*	Danmaku_SettingsR 
*
*	Danmaku_PozW 
*	Danmaku_PozR 
*
*	Danmaku	Type	#0:
*	-------------------
*	Empty, nothing, really.
*
*	Danmaku Type	#1:
*	--------------------
*	A single danmaku block that move to a constant direction.
*	This is the most common one, used by most enemies.
*
*	Can be used for falling shoots or Cirno's Perfect Freeze.
*	But basically good for any straight patterns.
*
*	X and Y positions are used as they should.
*	Danmaku Extra Settings are used for direction.
*
*	0: Up
*	1: Up / Right
*	2: Right
*	3: Down / Right
*	4: Down
*	5: Down / Left
*	6: Left
*	7: Up / Left	
*
*	Danmaku Type	#2:
*	--------------------
*	A single danmaku that follows you for a short time, and as the counter
*	depletes, it turns into a danmaku type #1.
*
*	Can be used for harder-to-dodge all purpose shoots.
*
*	Danmaku Type	#3:
*	--------------------
*	A spreadshot of five single danmaku. The shape if fixed, based on the Y.
*	Has a value of 3. Extra settings don't matter at all.
*

*Bank7_TestDanmakuAdd
*
*	JSR	Bank7_CallRandom
*	AND	#%00000011
*	CMP	#%00000011

*	BEQ	Bank7_TestAdd2
	
*Bank7_TestAdd1
*	LDA	#$1F
*	STA	temp01
*
*	JSR	Bank7_CallRandom
*	AND	#%00011111
*	STA	temp02
*
*	JSR	Bank7_Fall_On_Eiki
*
*	ORA	temp02
*	STA	temp02
*
*	JMP	Bank7_AddDanmaku
*
*Bank7_TestAdd2
*	JSR	Bank7_CallRandom
*	AND	#$0F
*	ORA	#$20
*	STA	temp01	
*
*	JSR	Bank7_CallRandom
*	AND	#%00011111
*	ORA	#%11100000
*	STA	temp02
*
*	JMP	Bank7_AddDanmaku


*
*	temp01: Type and Y.
*	If temp08 =  255, just fall directly down.
*	If temp09 != 0, dont randomize the caster.
*
Bank7_SummonedAtEnemyX

**	LDA	#36
**	STA	temp04

	BIT	NewLoadDelay
	BMI	Bank7_BossIsDifferent

	LDA	EnemySettings
	AND	#3
	ASL
	TAY

	LDA	Bank7_EnemyNUSIZDanmakuXPointers,y
	STA	temp05

	LDA	Bank7_EnemyNUSIZDanmakuXPointers+1,y
	STA	temp06

	LDY	temp09
	CPY	#0	
	BEQ	Bank7_RandomShoot
	
	DEY

	LDA	#36	
	CLC
	SBC	Bank7_EnemyPlainDanmakuX,y
	JMP	Bank7_NoRandomShoot
Bank7_RandomShoot
	JSR	Bank7_CallRandom	
	AND	#3
	TAY

	LDA	#36	
	CLC
	SBC	(temp05),y
Bank7_NoRandomShoot
	STA	temp04

	JMP	Bank7_WasNoBossNope
Bank7_BossIsDifferent	






Bank7_WasNoBossNope
	LDA	EnemyX
	SEC
	SBC	temp04
	LSR
	LSR
*
*	Must be 0-31
*
	CMP	#32
	BCC   	Bank7_SeemsLikeOK2Me
	JMP	Bank7_ReturnFromAnything

Bank7_SeemsLikeOK2Me
	STA	temp02

	LDA	temp08
	CMP	#255
	BNE	Bank7_Calculate_Angle

	LDA	#$80
	JMP	Bank7_Fixed_Angle
Bank7_Calculate_Angle
	JSR	Bank7_Fall_On_Eiki
Bank7_Fixed_Angle

	ORA	temp02
	STA	temp02

	JMP	Bank7_AddDanmaku
*
*	Input: temp02
*
Bank7_Fall_On_Eiki
	LDA	eikiX
	AND	#%01111111
	STA	temp03

	LDA 	temp02
	ASL
	ASL
	SEC
	SBC	#8
	SEC
	SBC	temp03

	CLC
	ADC	#8
	BPL	Bank7_Fall_On_Not_Right

	LDA	#$60
	RTS
Bank7_Fall_On_Not_Right	
	CMP	#8
	BCS	Bank7_Fall_On_Not_Down

	LDA	#$80
	RTS
Bank7_Fall_On_Not_Down
	LDA	#$A0
	RTS

Bank7_EikiY_To_PFy
	LDA 	eikiY
	AND	#$0F
	STA	temp04

	LDA	#NumberOfLines
	SEC	
	SBC	temp04

	CLC
	ADC	#HitBoxMinus
	SEC
	SBC	#21
	LSR
	RTS

Bank7_EikiX_To_PFx
	LDA	eikiX
	AND	#%01111111
	CLC	
	ADC	#8

	LSR
	LSR

	RTS

	JMP	Bank7_ReturnFromAnything
*
*	temp01 and temp02 contains the exact data!
*
*
Bank7_AddDanmaku
	BIT	LandScape

	BPL	Bank7_TheVeryFirstOnFrame
	JMP	Bank7_ReturnFromAnything

Bank7_TheVeryFirstOnFrame
*
* X <= Y
*
* LDA	Y
* CMP	X
* BCC	else
*

	LDA	temp01
	AND	#$F0
	LSR
	LSR
	LSR
	LSR
	TAY

	LDA	Bank7_DanmakuSound,y
	STA	temp03

	LDA	Bank7_Danmaku_Value,y
	TAY

	LDA	Danmaku_NumR
	CMP	#0
	BEQ	Bank7_FirstDanmaku

	TYA
	CLC
	ADC	Danmaku_NumR
	STA	temp17

	LDA	eikiY
	AND	#%11000000
	ROL
	ROL
	ROL
	TAY

	LDA	Bank7_Max_Number_Of_Danmaku,y
	CMP	temp17
***	BCC	Bank7_AddDanmakuRTS
	BCS	Bank7_NoMaxNumExceeded	
	JMP	Bank7_ReturnFromAnything
Bank7_NoMaxNumExceeded		
	LDA	temp17
	JMP	Bank7_SaveDanmakuNum
Bank7_FirstDanmaku
	TYA
Bank7_SaveDanmakuNum
	STA	Danmaku_NumW

	LDX	#0
Bank7_AddDanmakuToMemory
	LDA	Danmaku_SettingsR,x
	AND	#$F0
	CMP	#0
	BEQ	Bank7_FoundEmptyOne
	INX
	CPX	#8
	BNE	Bank7_AddDanmakuToMemory
	JMP	Bank7_ReturnFromAnything

Bank7_FoundEmptyOne
	LDA	temp01
	STA	Danmaku_SettingsW,x

	LDA	temp02
	STA	Danmaku_PozW,x	

	LDA	LandScape
	AND	#%01001111
	ORA	#%10000000	
	ORA	temp03
	STA	LandScape
	JMP	Bank7_ReturnFromAnything

Bank7_HandleDanmaku

	LDX	#255

Bank7_HandleNextOne
	INX
	CPX	#8
	BNE	Bank7_StillHaveSomeLeft
	JMP	Bank7_ReturnFromAnything
Bank7_StillHaveSomeLeft

	LDA	Danmaku_SettingsR,x
	AND	#$F0
	CMP	#0
	BEQ	Bank7_HandleNextOne

	LSR
	LSR
	LSR
	TAY
	
	LDA	Bank7_DanmakuType_Pointers,y
	STA	temp01

	LDA	Bank7_DanmakuType_Pointers+1,y
	STA	temp02

	JMP 	(temp01)

*	CMP	#$10
*	BEQ	Bank7_DanmakuType1
*
*	CMP	#$20
*	BNE	Bank7_Not_DanmakuType2
*	JMP	Bank7_DanmakuType2
*
*Bank7_Not_DanmakuType2
*	JMP	Bank7_HandleNextOne

Bank7_DanmakuType1
	CLC
	LDA	eikiY
	AND	#%11000000
	ROL
	ROL
	ROL
	TAY

	LDA	ScoreColorAdder
	AND	#%00100000
	CMP	#%00100000
	BEQ	Bank7_JustDrawItPrep

	LDA	counter
	AND	Bank7_Danmaku_Speed_Delay,y
	CMP	Bank7_Danmaku_Speed_Delay2,y
	BEQ	Bank7_DoNoJustDrawIt

Bank7_JustDrawItPrep
	LDA	Danmaku_SettingsR,x
	AND	#$0F
	STA	temp08

	LDA	Danmaku_PozR,x
	AND	#%00011111
	STA	temp09

	JMP	Bank7_JustDrawIt
Bank7_DoNoJustDrawIt

	LDA	Danmaku_PozR,x
	AND	#%11100000

	LSR
	LSR
	LSR
	LSR
	LSR

	TAY
 
	LDA	#1
	STA	temp09

	LDA	Bank7_DanmakuType1_MoveX,y
	STA	temp01

	LDA	Bank7_DanmakuType1_MoveY,y
	STA	temp02

	LDA	Danmaku_SettingsR,x
	AND	#$F0
	STA	temp03

	LDA	Danmaku_PozR,x
	AND	#%11100000
	STA	temp04

	LDA	Danmaku_SettingsR,x
	AND	#$0F
	CLC
	ADC	temp02
	BMI	Bank7_RemoveDanmaku
	CMP	#16	
	BEQ	Bank7_RemoveDanmaku
	STA	temp08

	ORA	temp03
	STA	Danmaku_SettingsW,x	

	LDA	Danmaku_PozR,x
	AND	#%00011111
	CLC
	ADC	temp01
	BMI	Bank7_RemoveDanmaku
	CMP	#32	
	BEQ	Bank7_RemoveDanmaku
	STA	temp09

	ORA	temp04
	STA	Danmaku_PozW,x	

Bank7_JustDrawIt
	JSR	Bank7_DisplayDanmakuPixel
	JMP	Bank7_HandleNextOne
*
*	If temp09 = 255: Read the value.
*
Bank7_RemoveDanmaku

	LDA	temp09
	CMP	#0
	BNE	Bank7_RemoveDanmakuSkip

	LDA	Danmaku_SettingsW,x

	LSR
	LSR
	LSR
	LSR
	TAY

	LDA	Bank7_Danmaku_Value,y
	STA	temp09
Bank7_RemoveDanmakuSkip

	LDA	#0
	STA	Danmaku_SettingsW,x
	STA	Danmaku_PozW,x

	LDA	Danmaku_NumR
	SEC
	SBC	temp09
	STA	Danmaku_NumW

	JMP	Bank7_HandleNextOne

Bank7_DanmakuType2
	CLC
	LDA	eikiY
	AND	#%11000000
	ROL
	ROL
	ROL
	TAY

	LDA	ScoreColorAdder
	AND	#%00100000
	CMP	#%00100000
	BNE	Bank7_DanTyp2_CheckOnCounter
	JMP	Bank7_JustDrawItPrep
Bank7_DanTyp2_CheckOnCounter
	LDA	counter
	AND	Bank7_Danmaku_Speed_Delay,y
	CMP	Bank7_Danmaku_Speed_Delay2,y
	BEQ	Bank7_DoNoJustDrawIt_2
	JMP	Bank7_JustDrawItPrep

Bank7_DoNoJustDrawIt_2
	LDA	eikiX
	AND	#%01111111
	STA	temp03

	LDA 	Danmaku_PozR,x
	AND	#%00011111
	ASL
	ASL
	SEC
	SBC	#8
	SEC
	SBC	temp03

	CLC
	ADC	#8
	BPL	Bank7_Follow_Eiki_Not_Right

	LDA	#1
	JMP	Bank7_GotFollowerX
Bank7_Follow_Eiki_Not_Right	
	CMP	#8
	BCS	Bank7_Follow_Eiki_Not_Zero
	LDA	#0
	JMP	Bank7_GotFollowerX
Bank7_Follow_Eiki_Not_Zero
	LDA	#255
Bank7_GotFollowerX
	STA	temp03

	LDA 	eikiY
	AND	#$0F
	STA	temp04

	LDA	#NumberOfLines
	SEC	
	SBC	temp04

	CLC
	ADC	#HitBoxMinus
	SEC
	SBC	#21
	LSR

	STA	temp04

	LDA	Danmaku_SettingsR,x
	AND	#$0F

	SEC
	SBC	temp04
	CLC
	ADC	#2

	BPL	Bank7_Follow_Eiki_Not_Up
	
	LDA	#1
	JMP	Bank7_Follow_Eiki_SetY

Bank7_Follow_Eiki_Not_Up
	CMP	#2
	BCS	Bank7_Follow_Eiki_Not_Middle

	LDA	#0
	JMP	Bank7_Follow_Eiki_SetY

Bank7_Follow_Eiki_Not_Middle
	LDA	#255
Bank7_Follow_Eiki_SetY
	STA	temp04

	LDA 	Danmaku_PozR,x
	AND	#%11100000
	STA	temp05
	CMP	#0
	BNE	Bank7_Follow_Eiki_Counter_Not_Depleted
	
	INC	temp03
	INC	temp04

	LDA	temp04
	ASL
	CLC
	ADC	temp04
	ADC	temp03
	TAY

	LDA	Bank7_Danmaku_Type2_Morph,y
	CMP	#255
	BNE	Bank7_NoRandomForDir

	JSR	Bank7_CallRandom
	AND	#%01110000
Bank7_NoRandomForDir
	ASL
	STA	temp05

	LDA	Danmaku_PozR,x
	AND	#%00011111
	ORA	temp05
	STA	Danmaku_PozW,x

	LDA	Danmaku_SettingsR,x
	AND	#$0F
	ORA	#$10
	STA	Danmaku_SettingsW,x

	LDA	Danmaku_NumR
	SEC
	SBC	#1
	STA	Danmaku_NumW

	JMP	Bank7_DanmakuType1

Bank7_Follow_Eiki_Counter_Not_Depleted
	LDA	Danmaku_SettingsR,x
	AND	#$0F
	STA	temp08
	CLC
	ADC	temp04
	BMI	Bank7_Follow_Eiki_DontChangeY
* X < Y
* LDA	X	
* CMP	Y
* BCS   else 
	CMP	#16
	BCS	Bank7_Follow_Eiki_DontChangeY	
	STA	temp08
	ORA	#$20	
	STA	Danmaku_SettingsW,x
Bank7_Follow_Eiki_DontChangeY

	LDA	Danmaku_PozR,x
	AND	#%00011111
	STA	temp09
	CLC
	ADC	temp03
	
	BMI	Bank7_Follow_Eiki_DontChangeX
	CMP	#32
	BCS	Bank7_Follow_Eiki_DontChangeX
	STA	temp09	

Bank7_Follow_Eiki_DontChangeX
	LDA	temp05
	SEC
	SBC	#%00100000
	STA	temp05

	ORA	temp09
	STA	Danmaku_PozW,x

	JSR	Bank7_DisplayDanmakuPixel
	JMP	Bank7_HandleNextOne

Bank7_DanmakuType3
*
*	Danmaku_Settings:
*	-----------------
*	0-3: Danmaku Y (0-16)
*	4-7: Danmaku Type (we can have 15 types)
*
*	Danmaku_Poz:
*	------------
*	0-4: Danmaku X (0-32)
*	5-7: Danmaku Extra Settings
*
	CLC
	LDA	eikiY
	AND	#%11000000
	ROL
	ROL
	ROL
	TAY

	LDA	Danmaku_SettingsR,x
	STA	temp06

	LDA	counter
	AND	Bank7_Danmaku_Speed_Delay,y
	CMP	Bank7_Danmaku_Speed_Delay2,y
	BNE	Bank7_DanmakuType3_C_1
	
	LDA	temp06
	SEC
	SBC	#1
	CMP	#$2F
	BNE	Bank7_DanmakuType3_C

	LDA	#3
	STA	temp09

	JMP	Bank7_RemoveDanmaku

Bank7_DanmakuType3_C
	STA	temp06
Bank7_DanmakuType3_C_1
	LDA	Danmaku_SettingsR,x
	AND	#$0F
	STA	temp08

	LDA	#15
	SEC
	SBC	temp08
	STA	temp16

	LDA	#1
	STA	temp10

	LDA	Danmaku_PozR,x
	AND	#%00011111
	STA	temp07
	STA	temp09
	
	JSR	Bank7_DisplayDanmakuPixel

Bank7_DanmakuType3_Loop
	LDA	temp07	
	SEC
	SBC	temp16
	STA	temp09

	CMP	#32
	BCS	Bank7_Skip_Danmaku3_0

	JSR	Bank7_DisplayDanmakuPixel
Bank7_Skip_Danmaku3_0

	LDA	temp07	
	CLC
	ADC	temp16
	STA	temp09

	CMP	#32
	BCS	Bank7_Skip_Danmaku3_1

	JSR	Bank7_DisplayDanmakuPixel
Bank7_Skip_Danmaku3_1

	DEC	temp10
	BMI	Bank7_DanmakuType3_Loop_End

	ASL	temp16
	JMP	Bank7_DanmakuType3_Loop

Bank7_DanmakuType3_Loop_End
	LDA	temp06
	STA	Danmaku_SettingsW,x

	JMP	Bank7_HandleNextOne

*
*	Inputs: temp08: Y, temp09: X
*	Indicator X should not be used!
*
Bank7_DisplayDanmakuPixel
* X <= Y
*
* LDA	Y
* CMP	X
* BCC	else

	LDY	#0
	LDA	temp09
Bank7_GetColumnLoop
	CMP	#8
	BCC	Bank7_DisplayDanmakuPixelGotX

	INY

	SEC
	SBC	#8
	JMP	Bank7_GetColumnLoop

Bank7_DisplayDanmakuPixelGotX
	STA	temp02
	STY	temp05
		
	TYA
	AND	#1
	ASL
	TAY

	LDA	Bank7_DanmakuPixelORA_Pointers,y
	STA	temp03
	LDA	Bank7_DanmakuPixelORA_Pointers+1,y
	STA	temp04	

	LDY	temp05
	LDA	Bank7_MultiBy18,y
	CLC
	ADC	temp08
	ADC	#2	
	TAY
	STA	temp01

	LDY	temp02
	LDA	(temp03),y
	
	LDY	temp01
	ORA	Danmaku_Col_1R,y
	STA	Danmaku_Col_1W,y

	RTS

Bank7_NextEvent
	LDA	LevelAndCharge
	AND	#%11100000
	LSR
	LSR
	LSR
	LSR

	SEC
	SBC	#2

	TAX

	LDA	Bank7_LevelArrayPointers,x
	STA	temp01

	LDA	Bank7_LevelArrayPointers+1,x
	STA	temp02

	LDY	LevelPointer

	LDA	(temp01),y

	BMI	Bank7_ItsARealEvent
	STA	NewLoadDelay

	JMP	Bank7_IncrementLevelPointer
Bank7_ItsARealEvent
	AND	#%01111111
	CMP	#127
	BNE	Bank7_NotATestReset
	LDA	#0
	STA	LevelPointer
	JMP	Bank7_NextEvent

Bank7_NotATestReset
	CMP	#1
	BNE	Bank7_NotAMessageToBeDisplayed

	LDA	MessagePointer
	ORA	#%10000000
	STA	MessagePointer
	AND	#%00111111
	TAY
	LDA	Bank7_SpellPictureValsForMessages,y
	STA	SpellPicture

	LDA	LongCounter
	ORA	#%10000000

	BIT	INPT4
	BMI	Bank7_NotPressedFireOnSet

	ORA	#%01000000
Bank7_NotPressedFireOnSet
	STA	LongCounter

	LDA	LandScape
	AND	#%11001111
	ORA	#%00010000
	STA	LandScape

	LDA	#%10111100
	STA	TextCounter

	JMP	Bank7_IncrementLevelPointer
Bank7_NotAMessageToBeDisplayed
*
*	From here, its likely that some enemy will be summoned.
*
	SEC
	SBC	#2
	TAY

*
* X >= Y
*
* LDA	X
* CMP	Y
* BCC 	else
*		
	CPY	#120
	BCC	Bank7_No_Boss_Summoned
	JMP	Bank7_Set_Boss_Things
Bank7_No_Boss_Summoned
	LDA	NewLoadDelay
	AND	#%01111111
	STA	NewLoadDelay

	LDA	Bank7_EnemyTypeAndStartNUSIZ,y
	STA	EnemySettings	
	AND	#3
	STA	temp01

	LDA	EnemySettings2
	AND	#3
	STA	EnemySettings2

	LDA	EnemySettings
	LSR
	LSR
	TAY
*
*LandScape = $BA
*
*	0-2: Counter
*	  3: Auto Increment 
*	4-5: Danmaku Sound
*	  6: HoldNextLoading
*	  7: Danmaku Shot
*
*MessagePointer = $BC
*
*	0-5: MessageID
*	  6: IgnoreNewEventHoldFlag
*	  7: Message is Displayed
*
*EnemyX = $BE 
*DeathX = $BF

StartOnTheRight = 158

	LDA	LandScape
	AND	#%10110111
	ORA	Bank7_SetFlagsORA,y
	STA	LandScape

	LDA	MessagePointer
	AND	#%10111111
	STA	MessagePointer

	LDA	Bank7_StartX,y
	CMP	#0
	BEQ	Bank7_ItsOnTheLeft

	CMP	#255
	BNE	Bank7_JustSaveX
*
*	These ones should be NUSIZ = $00 by default.
*
	JSR	Bank7_CallRandom
	AND	#127
	CLC
	ADC	#31

* CMP	Y
* BCS   else 

	CMP	#40
	BCS	Bank7_RandomXLargerThan41
	
	LDA	#40
	JMP	Bank7_JustSaveX
Bank7_RandomXLargerThan41
	JMP	Bank7_JustSaveX

Bank7_ItsOnTheLeft
	LDY	temp01
	LDA	Bank7_StartXOnTheLeftBasedOnNUSIZ,y

Bank7_JustSaveX
	STA	EnemyX
*
*	Bit 7 should be 0 anyway, since this is not a boss.
*
	JMP	Bank7_IncrementLevelPointer

Bank7_Set_Boss_Things
*
*	Don't have to store boss index, since it would be equal to the level number - 1.
*

	SEC
	SBC	#120
	TAY

	LDA	NewLoadDelay
	ORA	#%10000000
	STA	NewLoadDelay

*
*	Bit 3: Auto Increment of Landscape
*	Bit 6: Hold Increment of EventPointer
*
	LDA	LandScape
	AND	#%10110111
	ORA	#%01000000
	STA	LandScape

	LDA	#0
	STA	BossSettings
	STA	BossSettings2
	STA	BossHP
	STA	WastingLinesCounter

	JSR	Bank7_CallRandom
	AND	#1
	CMP	#1
	BEQ	Bank7_StartBossXOnTheRight

****	LDA	#24
	LDA	#31
	JMP	Bank7_StartedBossOnLeft
Bank7_StartBossXOnTheRight
	LDA	#StartOnTheRight
***	ADC	#16
Bank7_StartedBossOnLeft
	STA	EnemyX

Bank7_IncrementLevelPointer
	INC 	LevelPointer
Bank7_ReturnFromAnything
	LDX	temp19
	CPX	#255
	BNE	Bank7_ReturnNoRTS
Bank7_Return
	RTS
Bank7_ReturnNoRTS
	TXA
	INX

	TAY

	ASL		
	TAY

	LDA	Bank7_Return_JumpTable,y
   	pha
   	lda	Bank7_Return_JumpTable+1,y
   	pha
   	pha
   	pha

   	jmp	bankSwitchJump

Bank7_EikiWouldHit
*
*	Check if Eiki's shot would hit the target.
*
*	Input:	
*	--------------
*	temp02:	The X to check
*	temp03: Adder (8 for normal, 16 for boss)
*	temp05: Base to add or remove
*	
*	Output:
*	--------------
*	Y: 0 if nope, no changeIfOK
*

	LDA	eikiX
	AND	#%01111111
	CLC
	ADC	#43
	STA	temp01

	LDA	temp02
	SEC	
	SBC	temp05

	CMP	temp01
	BCS	Bank7_EnemyXOutOfBounds

	LDA	temp02
	CLC
	ADC	temp03
	CMP	temp01
	BCC	Bank7_EnemyXOutOfBounds

	RTS
Bank7_EnemyXOutOfBounds
	LDY	#0
	RTS


Bank7_HandTheEnemy

	LDA	#0
	STA	temp07

	LDA 	NewLoadDelay
	BMI	Bank7_HandleTheBoss
*
*	Check if one was shot.
*	

	LDA	#12
	BIT	eikiSettings
	BVS	Bank7_EikiDoesMagic

	LDA	StickBuffer
	BPL	Bank7_NoBulletOnTop
	LDA	#6
Bank7_EikiDoesMagic
	STA	temp05

	LDY	#0

	LDA	#8
	STA	temp03

	LDA	EnemySettings
	AND	#3
	STA	temp04

	LDA	EnemyX
	STA	temp02

	LDY	#1
	JSR	Bank7_EikiWouldHit
	CPY	#1		
	BEQ	Bank7_FirstHit

	LSR	temp04
	BCC	Bank7_SkipSecondSprite

	LDA	EnemyX	
	CLC
	ADC	#16
	STA	temp02
	
	LDY	#2
	JSR	Bank7_EikiWouldHit
	CPY	#2		
	BEQ	Bank7_FirstHit

Bank7_SkipSecondSprite
	LSR	temp04
	BCC	Bank7_SkipThirdSprite

	LDA	EnemyX	
	CLC
	ADC	#32
	STA	temp02

	LDY	#3	
	JSR	Bank7_EikiWouldHit
	CPY	#3		
	BNE	Bank7_NoneWasHit

Bank7_FirstHit	
	LDA	temp02
	STA	DeathX

	LDA	#$1e
	STA	EnemyBackColor

	LDA	EnemySettings2
	AND	#%11111100
	STA	EnemySettings2

	LDA	eikiSettings2
	ORA	#%10000000
	STA	eikiSettings2
*
*	temp07 is used to set the points.
*	Points = temp07 * 100
*
*	Points:	 
*	-Red Soul:	100
*	-Skull:		200
*	-Ghost:		300
*
	LDA	EnemySettings
	LSR
	LSR
	TAX
	LDA	Bank7_PointsOnType,x
	STA	temp07

	LDA	EnemySettings2
	ORA	#4
	STA	EnemySettings2

	LDA	EnemySettings
	AND	#3

	CMP	#$00
	BNE	Bank7_ThereAreOthers
	JMP	Bank7_RemoveCommonEnemy

Bank7_ThereAreOthers
	CMP	#$03
	BEQ	Bank7_ThereWere3

	CPY	#1
	BNE	Bank7_NoNeedToChangeX
	
	TAY
	LDA	Bank7_ThereWere2_ChangeX,y
	STA	temp01

	LDA	EnemyX
	CLC
	ADC	temp01
	STA	EnemyX
Bank7_NoNeedToChangeX

	LDA 	EnemySettings
	AND	#%11111100
	STA	EnemySettings

	JMP	Bank7_ContinueAsUsual
Bank7_ThereWere3
	DEY

	LDA 	EnemySettings
	AND	#%11111100
	ORA	Bank7_GetNewNUSIZIf3,y
	STA	EnemySettings

	LDA 	EnemyX
	CLC
	ADC	Bank7_ChangeXIf3,y
	STA	EnemyX

Bank7_NoneWasHit
Bank7_NoBulletOnTop
Bank7_SkipThirdSprite
Bank7_ContinueAsUsual

	LDA 	EnemySettings
	LSR
	LSR
	STA	temp09
	ASL
	TAY

	LDA	Bank7_BehavePointers,y
	STA	temp01
	LDA	Bank7_BehavePointers+1,y
	STA	temp02
	JMP	(temp01)

Bank7_Behavour_0

ReverseRandomNum = 130
ShootRandomNum = 165

	CLC
*
*	Get the difficulty.
*
	LDA	eikiY
	ROL
	ROL
	ROL
	AND	#3
	TAY

	LDA	counter
	AND	Bank7_Counter_Skips,y
	CMP	Bank7_Counter_Skips,y	
	BNE	Bank7_NoChangeInSettings	
*
*	Uses the counter to make the movement more life-like.
*	Values: 
*	     0: Go forwards	
*	     1: Go backwards
*	     2:	Shoot danmaku 
*	     3: Stand still 
*

	LDA	EnemySettings2
	AND	#%00111000
	CMP	#0
	BEQ	Bank7_Behavour_0_Do_A_New_Step
	SEC
	SBC	#%00001000
	STA	temp01

	LDA	EnemySettings2
	AND	#%11000111
	ORA	temp01
	STA	EnemySettings2

	CLC
	AND	#%11000000	
	ROL
	ROL
	ROL
	
	TAY	
	LDA	Bank7_FakeRandoms_0,y
	JMP	Bank7_FakeRandoms

Bank7_Behavour_0_Do_A_New_Step
	LDA	EnemySettings2
	ORA	#%00111000
	STA	EnemySettings2

	JSR	Bank7_CallRandom
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

Bank7_FakeRandoms
	CMP	#ReverseRandomNum	
	BCS	Bank7_Behavour_0_Random_LargerThan_1

	LDY	temp09
	CPY	#0
	BNE	Bank7_Behavour_0_Move_L
	JMP	Bank7_Behavour_0_Move_R

Bank7_Behavour_0_Move_L
***	LDY	temp09

	LDA	EnemySettings2
	AND	#%00111111
**	ORA	#%01000000
	ORA	Bank7_Move_L_Change_Bits,y
	STA	EnemySettings2

	DEC	EnemyX

	LDA	EnemySettings
	AND	#3
	TAX	
	LDA	Bank7_StartXOnTheLeftBasedOnNUSIZ,x
	CMP	EnemyX	
	BCC	Bank7_NoRemoveBehave0

	CPY	#0
	BNE	Bank7_RemoveCommonEnemy

Bank7_Behavour_0_Move_R
***	LDY	temp09

	LDA	EnemySettings2
	AND	#%00111111
	ORA	Bank7_Move_R_Change_Bits,y
	STA	EnemySettings2

	INC	EnemyX
	LDA	EnemyX

	CMP 	#StartOnTheRight
	BCC	Bank7_NoRemoveBehave0

	CPY	#0
	BEQ	Bank7_RemoveCommonEnemy
	JMP	Bank7_Behavour_0_Move_L

Bank7_RemoveCommonEnemy
	LDA	#0
	STA	EnemyX
	STA	EnemySettings

	LDA	NewLoadDelay
	AND	#%01111111
	STA	NewLoadDelay

	LDA	LandScape
	AND	#%10111111
	ORA	#%00001000
	STA	LandScape

	LDA	#<Bank6_Enemy_Sprite_Empty
	STA	EnemySpritePointer
	LDA	#>Bank6_Enemy_Sprite_Empty
	STA	EnemySpritePointer+1

	JMP	Bank7_ReturnFromAnything
Bank7_Behavour_0_Random_LargerThan_1
	TAY

	LDA	EnemySettings
	AND	#3	
	TAX

	TYA
	CMP	Bank7_SecondNumForCMPOnNUSIZ,x	
	BCS	Bank7_Behavour_0_Random_LargerThan_2

	LDY	temp09
	CPY	#0
	BEQ	Bank7_Behavour_0_Move_L
	JMP	Bank7_Behavour_0_Move_R
	
Bank7_Behavour_0_Random_LargerThan_2

	BIT	EnemySettings2
	BVS	Bank7_DanmakuAlreadyShootBe0	

	LDA	EnemySettings2
	AND	#%00111111
	ORA	#%10000000
	STA	EnemySettings2

Bank7_DanmakuAlreadyShootBe0	
Bank7_NoRemoveBehave0
Bank7_NoChangeInSettings
	LDA	eikiSettings
	AND	#3
	ASL
	TAY	
	
	LDA	Bank7_Soul_Sprite_Pointers,y
	STA 	EnemySpritePointer
	LDA	Bank7_Soul_Sprite_Pointers+1,y
	STA 	EnemySpritePointer+1

	LDA	#<Bank6_Soul_Colors
	STA 	EnemyColorPointer
	LDA	#>Bank6_Soul_Colors
	STA 	EnemyColorPointer+1

	LDA	EnemySettings2
	AND	#%11111000
	CMP	#%10111000
	BNE	Bank7_NoNewDanmakuBe0

	LDA	EnemySettings2
	ORA	#%01000000
	STA	EnemySettings2

	LDA	#0
	STA	temp08
	STA	temp09

	LDA	#$1F
	STA	temp01

	JMP	Bank7_SummonedAtEnemyX
Bank7_NoNewDanmakuBe0

**	LDA	EnemyX
**	SEC
**	SBC	#36
**	LSR
**	LSR
**
**	STA	temp09
**
**	LDA	#15
**	STA	temp08
**
**	JSR	Bank7_DisplayDanmakuPixel	

	JMP	Bank7_ReturnFromAnything

Bank7_Behavour_1
*EnemySettings2 = $C6
*
*	0-1: Explosion Sprite Counter
*	  2: CheckForScore Flag
*	3-5: Free to use counter
*	6-7: Free to use state
* 

	CLC

	LDA	eikiY
	AND	#%11000000
	ROL
	ROL
	ROL
	TAX	

	LDA	counter
	AND	#1
	CMP	#1
	BEQ	Bank7_SkullSMove
	JMP	Bank7_Behavour_1_Gone

Bank7_SkullSMove

	LDY	temp09
	CPY	#2

	BNE	Bank7_Behavour_1_Go_DEC
	
	LDA	EnemyX
	CLC
	ADC	Bank7_Enemy_Speed_On_Diff,x
	STA 	EnemyX

	CMP 	#StartOnTheRight
	BCC	Bank7_Behavour_1_Gone
	JMP	Bank7_RemoveCommonEnemy

Bank7_Behavour_1_Go_DEC

	LDA	EnemyX
	SEC
	SBC	Bank7_Enemy_Speed_On_Diff,x
	STA 	EnemyX
	
	LDA	EnemySettings
	AND	#3	
	TAY
	
	LDA	Bank7_StartXOnTheLeftBasedOnNUSIZ,y
	CMP	EnemyX	
	BCC	Bank7_Behavour_1_Gone

	JMP	Bank7_RemoveCommonEnemy

Bank7_Behavour_1_Gone
	LDA	eikiSettings
	AND	#3
	ASL
	TAY	
	
	LDA	Bank7_Skull_Sprite_Pointers,y
	STA 	EnemySpritePointer
	LDA	Bank7_Skull_Sprite_Pointers+1,y
	STA 	EnemySpritePointer+1

	LDA	#<Bank6_Skull_Colors
	STA 	EnemyColorPointer
	LDA	#>Bank6_Skull_Colors
	STA 	EnemyColorPointer+1

	LDA	EnemySettings2
	AND	#%00111000
	CMP	#0
	BEQ	Bank7_SkullsCanShoot	

	LDA	counter
	AND	#1
	CMP	#1
	BNE	Bank7_NoSkullShot

	LDA	EnemySettings2
	SEC
	SBC	#%00001000
	STA	EnemySettings2

	JMP	Bank7_NoSkullShot
Bank7_SkullsCanShoot
	LDA	EnemySettings
	AND	#3
	STA	temp04

	LDA	#8
	STA	temp03

	LDA	#0
	STA	temp05

	LDA	EnemyX
	STA	temp02

	LDY	#1
	JSR	Bank7_EikiWouldHit
	CPY	#1		
	BEQ	Bank7_Skull_EnemyShoots

	LSR	temp04
	BCC	Bank7_NoSecondSkull

	LDA	EnemyX
	CLC
	ADC	#16	
	STA	temp02

	LDY	#2
	JSR	Bank7_EikiWouldHit
	CPY	#2		
	BEQ	Bank7_Skull_EnemyShoots

Bank7_NoSecondSkull
	LSR	temp04
	BCC	Bank7_NoSkullShot

	LDA	EnemyX
	CLC
	ADC	#32	
	STA	temp02

	LDY	#3
	JSR	Bank7_EikiWouldHit
	CPY	#3		
	BNE	Bank7_NoSkullShot

Bank7_Skull_EnemyShoots
	LDA	EnemySettings2
	AND	#%11000111
	ORA	Bank7_SkullShootCounterOnDiff,x
	STA	EnemySettings2

	LDA	#255
	STA	temp08
	STY	temp09

	LDA	#$1F
	STA	temp01
	JMP	Bank7_SummonedAtEnemyX

Bank7_NoSkullShot
	JMP	Bank7_ReturnFromAnything

Bank7_Behavour_2
*EnemySettings2 = $C6
*
*	0-1: Explosion Sprite Counter
*	  2: CheckForScore Flag
*	3-5: Free to use counter
*	6-7: Free to use state
* 
*	Counter is used for rise, sprite animation and sink.
*	States: 0: Rise, 1: Shoot, 2: Sink
*
	LDA	eikiY
	ROL
	ROL
	ROL
	AND	#3
	TAY

	LDA	counter
	AND	Bank7_Counter_Skips,y
	CMP	Bank7_Counter_Skips,y	
	BEQ	Bank7_GhostUpdate

	LDA	EnemySettings2
	AND	#%11000000
	JMP	Bank7_StillGhost

Bank7_GhostUpdate
	LDA	EnemySettings2
	AND	#%00111000
	CMP	#%00111000
	BEQ	Bank7_Increment_Ghost_Pointer	

	LDA	EnemySettings2
	CLC
	ADC	#%00001000
	JMP	Bank7_Save_Ghost_Settings
Bank7_Increment_Ghost_Pointer	
	LDA	EnemySettings2
	AND	#%11000111
	CLC
	ADC	#%01000000
Bank7_Save_Ghost_Settings
	STA	EnemySettings2

	AND	#%11000000
	CMP	#%11000000
	BNE	Bank7_StillGhost

	JMP	Bank7_RemoveCommonEnemy

Bank7_StillGhost
	CLC

	ROL
	ROL
	ROL
	ASL	

	TAY

	LDA	#<Bank6_Ghost_Colors
	STA	EnemyColorPointer

	LDA	#>Bank6_Ghost_Colors
	STA	EnemyColorPointer+1

	LDA	Bank7_Ghost_Pointers,y
	STA	temp01

	LDA	Bank7_Ghost_Pointers+1,y
	STA	temp02	
	
	JMP	(temp01),y

Bank7_Ghost_Behave_0
	LDA	EnemySettings2
	AND	#%00111000
	LSR
	LSR
	LSR
	STA	temp01

	LDA	#11
	SEC
	SBC 	temp01
	STA	temp01

	LDA	#>Bank6_Ghost_Sprite_0
	STA	EnemySpritePointer+1
	
	LDA	#<Bank6_Ghost_Sprite_0
	CLC
	ADC	temp01
	STA	EnemySpritePointer

	JMP	Bank7_ReturnFromAnything

Bank7_Ghost_Behave_1
	LDA	EnemySettings2
	AND	#%00110000
	LSR
	LSR
	LSR
	TAY

	LDA	Bank7_Ghost_Sprite_Pointers,y
	STA	EnemySpritePointer

	LDA	Bank7_Ghost_Sprite_Pointers+1,y
	STA	EnemySpritePointer+1

	LDA	EnemySettings2
	AND	#%00111000
	CMP	#%00111000
	BNE	Bank7_Ghost_Behave_1_No_Danmaku

	LDY	#1
	LDA	#255
	STA	temp08
	STY	temp09

	LDA	#$3F
	STA	temp01
	JMP	Bank7_SummonedAtEnemyX
Bank7_Ghost_Behave_1_No_Danmaku
	JMP	Bank7_ReturnFromAnything

Bank7_Ghost_Behave_2
	LDA	EnemySettings2
	AND	#%00111000
	LSR
	LSR
	LSR
	STA	temp01

	LDA	#>Bank6_Ghost_Sprite_3
	STA	EnemySpritePointer+1
	
	LDA	#<Bank6_Ghost_Sprite_3
	CLC
	ADC	temp01
	STA	EnemySpritePointer

	JMP	Bank7_ReturnFromAnything

Bank7_SetBossSprite
	ORA	BossSettings2
	STA	BossSettings2

	LDA	LevelAndCharge
	AND	#%11100000
	SEC
	SBC	#%00100000
	LSR
	LSR
	LSR
	LSR
	TAY

	LDA	Bank7_Boss_L_P0_PointerLists,y
	STA	BossSpriteTablePointer_L_P0

	LDA	Bank7_Boss_L_P0_PointerLists+1,y
	STA	BossSpriteTablePointer_L_P0+1

	LDA	Bank7_Boss_R_P0_PointerLists,y
	STA	BossSpriteTablePointer_R_P0

	LDA	Bank7_Boss_R_P0_PointerLists+1,y
	STA	BossSpriteTablePointer_R_P0+1

	LDA	Bank7_Boss_L_P1_PointerLists,y
	STA	BossSpriteTablePointer_L_P1

	LDA	Bank7_Boss_L_P1_PointerLists+1,y
	STA	BossSpriteTablePointer_L_P1+1

	LDA	Bank7_Boss_R_P1_PointerLists,y
	STA	BossSpriteTablePointer_R_P1

	LDA	Bank7_Boss_R_P1_PointerLists+1,y
	STA	BossSpriteTablePointer_R_P1+1

	RTS

Bank7_HandleTheBoss
***	JMP	Bank7_ReturnFromAnything

	LDA	BossSettings2
	AND	#%11111000
	STA	BossSettings2

	LDA	BossSettings
	AND	#$0F
	ASL
	TAY	

	LDA	Bank7_Boss_State_Pointers,y
	STA	temp01

	LDA	Bank7_Boss_State_Pointers+1,y
	STA	temp02	

	JMP	(temp01)
*
*	Sink the Landscape
*
Bank7_Boss_State_0
LandScape_Lines_From1 = 15

	LDA	counter
	AND	#1
	CMP	#1
	BNE	Bank7_Nothing_Changes

	INC	WastingLinesCounter
	LDA	WastingLinesCounter
	CMP	#LandScape_Lines_From1
	BNE	Bank7_Nothing_Changes

	LDA	#0
	STA	Bank7_Nothing_Changes
	INC	BossSettings
Bank7_Nothing_Changes

	JMP	Bank7_ReturnFromAnything
*
*	Summoned, fill HP and move to the center.
*
Bank7_Boss_State_1
BossMiddle = 96

	LDA	EnemyX
	CMP	#BossMiddle
	BEQ	Bank7_Boss_At_Center
*
* X < Y
* LDA	X	
* CMP	Y
* BCS   else 	 
*
	BCS	Bank7_BossGoesFromLeft	
	INC	EnemyX
	LDA	#4	

	JSR	Bank7_SetBossSprite
	JMP	Bank7_BossWasNotAtCenter
Bank7_BossGoesFromLeft
	DEC	EnemyX
	LDA	#3	
	JSR	Bank7_SetBossSprite

Bank7_Boss_At_Center

	LDA	eikiSettings
	AND	#3
	JSR	Bank7_SetBossSprite

Bank7_BossWasNotAtCenter

	LDA	BossHP
	CMP	#255
	BEQ	Bank7_HP_Is_Full

	LDA	BossHP
	CLC
	ADC	#4
	
	BCC	Bank7_Fix255
	LDA	#255
Bank7_Fix255
	STA	BossHP

Bank7_HP_Is_Full
	LDA	EnemyX
	CMP	#BossMiddle
	BNE	Bank7_NoINCofState

	LDA	BossHP
	CMP	#255
	BNE	Bank7_NoINCofState

*****	INC	BossSettings

Bank7_NoINCofState

	JMP	Bank7_ReturnFromAnything

Bank7_CallRandom
	LDA	random
	lsr
	BCC 	*+4
	EOR	#$d4
	STA	random
	rts
*
*	Data Structure for the level array.
*	One level can have 255 lines.
*
*	0XXXXXXX - This means a wait of a max of 127 frames. 
*	1YYYYYYY - This means YYYYY (max 127 kind) of events.
*
*	Types:
*	-------
*	000: 	End of Level
*	001: 	Display a character message based on MessagePointer. The pointer is incremented after afterwards.
*
*	002: 	Summons a basic soul enemy on the right	
*	003: 	Summons a basic soul enemy on the left	
*	004: 	Summons two basic souls close on the right
*	005: 	Summons two basic souls close on the left
*	006: 	Summons two basic souls with a gap on the right
*	007: 	Summons two basic souls with a gap on the left
*	008: 	Summons three basic souls the right
*	009: 	Summons three basic souls the left
*
*	010:	Summons two skulls with small gap on the right
*	011:	Summons two skulls with small gap on the left
*	012:	Summons two skulls with large gap on the right
*	013:	Summons two skulls with large gap on the left
*	014:	Summons three skulls on the right
*	015:	Summons three skulls on the left
*
*	016:	Summons a ghost at random
*
*	120: 	Summons Komachi
*	121:	Summons Reimu
*	122:	Summons Cirnobyl
*	123:	Summons Rumia
*	124:	Summons Sariel
*
*	127:    Init LevelCounter to Zero (only for testing)
*
*	SpellPictureValues:
*	-------------------
*	 00:	Eiki
*	 01:	Komachi
*	 02:	Reimu
*	 03: 	Cirnobyl
*	 04:	Rumia
*	 05:	Sariel
*


*
*	Data Section
*

	_align	2
Bank7_Boss_L_P0_PointerLists
	BYTE	#<Bank4_Komachi_L_P0_Pointers
	BYTE	#>Bank4_Komachi_L_P0_Pointers

	_align	2
Bank7_Boss_R_P0_PointerLists
	BYTE	#<Bank4_Komachi_R_P0_Pointers
	BYTE	#>Bank4_Komachi_R_P0_Pointers

	_align	2
Bank7_Boss_L_P1_PointerLists
	BYTE	#<Bank4_Komachi_L_P1_Pointers
	BYTE	#>Bank4_Komachi_L_P1_Pointers

	_align	2
Bank7_Boss_R_P1_PointerLists
	BYTE	#<Bank4_Komachi_R_P1_Pointers
	BYTE	#>Bank4_Komachi_R_P1_Pointers

	_align	2
Bank7_Boss_State_Pointers
	BYTE	#<Bank7_Boss_State_0
	BYTE	#>Bank7_Boss_State_0
	BYTE	#<Bank7_Boss_State_1
	BYTE	#>Bank7_Boss_State_1

	_align	8
Bank7_DanmakuType_Pointers
	BYTE	#0
	BYTE	#0
	BYTE	#<Bank7_DanmakuType1
	BYTE	#>Bank7_DanmakuType1
	BYTE	#<Bank7_DanmakuType2
	BYTE	#>Bank7_DanmakuType2
	BYTE	#<Bank7_DanmakuType3
	BYTE	#>Bank7_DanmakuType3

	_align	8
Bank7_Ghost_Sprite_Pointers
	BYTE	#<Bank6_Ghost_Sprite_0
	BYTE	#>Bank6_Ghost_Sprite_0
	BYTE	#<Bank6_Ghost_Sprite_1
	BYTE	#>Bank6_Ghost_Sprite_1
	BYTE	#<Bank6_Ghost_Sprite_2
	BYTE	#>Bank6_Ghost_Sprite_2
	BYTE	#<Bank6_Ghost_Sprite_3
	BYTE	#>Bank6_Ghost_Sprite_3

	_align	6
Bank7_Ghost_Pointers
	BYTE	#<Bank7_Ghost_Behave_0
	BYTE	#>Bank7_Ghost_Behave_0
	BYTE	#<Bank7_Ghost_Behave_1
	BYTE	#>Bank7_Ghost_Behave_1
	BYTE	#<Bank7_Ghost_Behave_2
	BYTE	#>Bank7_Ghost_Behave_2

	_align	4
Bank7_SkullShootCounterOnDiff
	BYTE	#%00111000
	BYTE	#%00100000
	BYTE	#%00010000
	BYTE	#%00001000

	_align	4
Bank7_Enemy_Speed_On_Diff
	BYTE	#1
	BYTE	#2
	BYTE	#2
	BYTE	#3

	_align	3
Bank7_GetNewNUSIZIf3
	BYTE	#$01
	BYTE	#$02
	BYTE	#$01

	_align	3
Bank7_ChangeXIf3
	BYTE	#16
	BYTE	#0
	BYTE	#0

	_align	3
Bank7_ThereWere2_ChangeX
	BYTE	#0
	BYTE	#16
	BYTE	#32

	_align	6
Bank7_Soul_Sprite_Pointers
	BYTE	#<Bank6_Common_Enemy_Soul_0
	BYTE	#>Bank6_Common_Enemy_Soul_0
	BYTE	#<Bank6_Common_Enemy_Soul_1
	BYTE	#>Bank6_Common_Enemy_Soul_1
	BYTE	#<Bank6_Common_Enemy_Soul_2
	BYTE	#>Bank6_Common_Enemy_Soul_2

	_align	6
Bank7_Skull_Sprite_Pointers
	BYTE	#<Bank6_Skull_Sprite_0
	BYTE	#>Bank6_Skull_Sprite_0
	BYTE	#<Bank6_Skull_Sprite_1
	BYTE	#>Bank6_Skull_Sprite_1
	BYTE	#<Bank6_Skull_Sprite_2
	BYTE	#>Bank6_Skull_Sprite_2

*
*	Behaviours:
*	0: Soul goes slowly from left to right, disappears as it reaches the StartOnTheRight value. 
*          Summons a basic danmaku random times. Sprite independent of the direction
*	1: Soul goes slowly from right to left, disappears as it reaches the left start poz based on NUSIZ. 
*          Summons a basic danmaku random times. Sprite independent of the direction
*
*	2: Skull goes left to right really fast, the one above Eiki shoots a danmaku.
*	3: Skull goes rigth to left really fast, the one above Eiki shoots a danmaku.
*
*	4: Ghost appears at random X, rising, shoots a spreadshot, then sinks back.
*

	_align	8
Bank7_EnemyNUSIZDanmakuXPointers
	BYTE	#<Bank7_EnemyNUSIZDanmakuX_00
	BYTE	#>Bank7_EnemyNUSIZDanmakuX_00
	BYTE	#<Bank7_EnemyNUSIZDanmakuX_01
	BYTE	#>Bank7_EnemyNUSIZDanmakuX_01
	BYTE	#<Bank7_EnemyNUSIZDanmakuX_02
	BYTE	#>Bank7_EnemyNUSIZDanmakuX_02
	BYTE	#<Bank7_EnemyNUSIZDanmakuX_03
	BYTE	#>Bank7_EnemyNUSIZDanmakuX_03

	_align	2
Bank7_Move_R_Change_Bits
	BYTE	#0
	BYTE	#64

	_align	2
Bank7_Move_L_Change_Bits
	BYTE	#64
	BYTE	#0

	_align	4
Bank7_EnemyNUSIZDanmakuX_00
	BYTE	#0
	BYTE	#0
	BYTE	#0
	BYTE	#0

	_align	4
Bank7_EnemyNUSIZDanmakuX_01
	BYTE	#0
	BYTE	#16
	BYTE	#0
	BYTE	#16

	_align	4
Bank7_EnemyNUSIZDanmakuX_02
	BYTE	#0
	BYTE	#32
	BYTE	#0
	BYTE	#32

	_align	4
Bank7_EnemyNUSIZDanmakuX_03
	BYTE	#0
	BYTE	#16
	BYTE	#32
	BYTE	#16

	_align	3
Bank7_EnemyPlainDanmakuX
	BYTE	#0
	BYTE	#16
	BYTE	#32

	_align	4  
Bank7_FakeRandoms_0
	BYTE	#0
	BYTE	#131
	BYTE	#255
	BYTE	#255

	_align	4
Bank7_Counter_Skips
	BYTE	#3
	BYTE	#1
	BYTE	#1
	BYTE	#0

	_align	4
Bank7_SecondNumForCMPOnNUSIZ
	BYTE	#165
	BYTE	#157
	BYTE	#157
	BYTE	#149

	_align	10
Bank7_BehavePointers
	BYTE	#<Bank7_Behavour_0
	BYTE	#>Bank7_Behavour_0
	BYTE	#<Bank7_Behavour_0
	BYTE	#>Bank7_Behavour_0

	BYTE	#<Bank7_Behavour_1
	BYTE	#>Bank7_Behavour_1
	BYTE	#<Bank7_Behavour_1
	BYTE	#>Bank7_Behavour_1

	BYTE	#<Bank7_Behavour_2
	BYTE	#>Bank7_Behavour_2

	_align	4
Bank7_StartXOnTheLeftBasedOnNUSIZ
	BYTE	#33
	BYTE	#17
	BYTE	#1
	BYTE	#1

	_align  4
Bank7_PointsOnType
	BYTE	#1
	BYTE	#1
	BYTE	#2
	BYTE	#3

*
*	If 0, start on the left depending on NUSIZ
*	If 255, calculate random.
*
*	Based on EnemyTypeAndStartNUSIZ.
*

	_align  5
Bank7_StartX
 	BYTE	#0
 	BYTE	#StartOnTheRight
 	BYTE	#0
 	BYTE	#StartOnTheRight
	BYTE	#255
*
*	Bit 3: Auto Increment of Landscape
*	Bit 6: Hold Increment of EventPointer
*
*	Based on EnemyTypeAndStartNUSIZ.
*
*
*	Based on the levelArray value.
*
	_align	5
Bank7_SetFlagsORA
	BYTE	#%01001000
	BYTE	#%01001000
	BYTE	#%01001000
	BYTE	#%01001000
	BYTE	#%01001000
*
*	Type #00: Soul(s), 	moving from left to right
*	Type #01: Soul(s), 	moving from rigth to left
*	Type #02: Skulls,  	moving from left to right
*	Type #03: Skulls, 	moving from rigth to left
*	Type #04: Ghost		appear at random, rises and sinks
*
*	Based on levelArray.
*
	_align	14
Bank7_EnemyTypeAndStartNUSIZ
	BYTE	#%00000000	; One soul on the left 			%10000010	1
	BYTE	#%00000100	; One soul on the right			%10000011	1
	BYTE	#%00000001	; Two souls on the left (small gap)	%10000100	3	
	BYTE	#%00000101	; Two souls on the right(small gap)	%10000101	0
	BYTE	#%00000010	; Two souls on the left (huge gap)	%10000110	0
	BYTE	#%00000110	; Two souls on the right(huge gap)	%10000111	1
	BYTE	#%00000011	; Three souls on the left		%10001000	1
	BYTE	#%00000111	; Three souls on the right		%10001001	1
	BYTE	#%00001001	; Two skulls on the left (small gap)	%10001010	1
	BYTE	#%00001101	; Two skulls on the right (small gap)	%10001011	1
	BYTE	#%00001010	; Two skulls on the left (huge gap)	%10001100	2
	BYTE	#%00001110	; Two skulls on the right (huge gap)	%10001101	1
	BYTE	#%00001011	; Three skulls on the left 		%10001110	1
	BYTE	#%00001111	; Three skulls on the right 		%10001111	1
	BYTE	#%00010000	; Ghost summoned at random		%10010000	3 	

	_align	1
Bank7_SpellPictureValsForMessages
	BYTE	#$0F

	_align	2
Bank7_LevelArrayPointers
	BYTE	#<Bank7_LevelArray_1
	BYTE	#>Bank7_LevelArray_1

	_align	128
Bank7_LevelArray_1
	BYTE	#%10000001	; Display next
	BYTE	#16

****	Testing
**	BYTE	#%10010000	; Ghost summoned at random

	BYTE	#%10000011	; Summon a soul from left to right
	BYTE	#16
	BYTE	#%10000010	; Summon a soul from right to left
	BYTE	#8
	BYTE	#%10000111	; Summons two souls on the right with huge gap
	BYTE	#2
	BYTE	#%10000100	; Summons two souls on left (small gap)
	BYTE	#%10001000	; Summons three souls on left
	BYTE	#%10001011	; Two skulls on the right (small gap)
	BYTE	#%10001111	; Three skulls on the right 
	BYTE	#%10001110	; Three skulls on the left 
	BYTE	#%10001100	; Two skulls on the left (huge gap)	
	BYTE	#%10001001	; Three souls on the right
	BYTE	#%10000100	; Two souls on the left (small gap)
	BYTE	#32
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#16
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#8
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#%10001101	; Two skulls on the right (huge gap)
	BYTE	#%10001100	; Two skulls on the left (huge gap)
	BYTE	#%10001001	; Three souls on the right
	BYTE	#%10000100	; Summons two souls on left (small gap)
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#8
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#8
	BYTE	#%10000101	; Two souls on the right(small gap)
	BYTE	#%10000110	; Two souls on the left (huge gap)
	BYTE	#8
	BYTE	#%10001100	; Two skulls on the left (huge gap)
	BYTE	#%10001101	; Two skulls on the right (huge gap)
	BYTE	#%10001111	; Three skulls on the right 
	BYTE	#%10001110	; Three skulls on the left 
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#8
	BYTE	#%10010000	; Ghost summoned at random
	BYTE	#16
	BYTE	#%11111010	; Summon Komachi (LVL 1 boss)

	BYTE	#127
	BYTE	#%11111111	; Test Reset

	_align	4
Bank7_DanmakuSound
	BYTE	#0
	BYTE	#%00010000
	BYTE	#%00010000
	BYTE	#%00100000

	_align	9
Bank7_Danmaku_Type2_Morph
	BYTE	#$70
	BYTE	#$00
	BYTE	#$10

	BYTE	#$60
	BYTE	#$FF
	BYTE	#$20
	
	BYTE	#$50
	BYTE	#$40
	BYTE	#$30

	_align	4
Bank7_Danmaku_Speed_Delay
	BYTE	#7
	BYTE	#3
	BYTE	#3
	BYTE	#1

	_align	4
Bank7_Danmaku_Speed_Delay2
	BYTE	#6
	BYTE	#2
	BYTE	#2
	BYTE	#0

	_align	4
Bank7_DanmakuPixelORA_Pointers
	BYTE 	#<Bank7_DanmakuPixelORA1
	BYTE 	#>Bank7_DanmakuPixelORA1
	BYTE 	#<Bank7_DanmakuPixelORA2
	BYTE 	#>Bank7_DanmakuPixelORA2

	_align	8
Bank7_DanmakuPixelORA1
	BYTE	#%10000000
	BYTE	#%01000000
	BYTE	#%00100000
	BYTE	#%00010000
	BYTE	#%00001000
	BYTE	#%00000100
	BYTE	#%00000010
	BYTE	#%00000001

	_align	8
Bank7_DanmakuPixelORA2
	BYTE	#%00000001
	BYTE	#%00000010
	BYTE	#%00000100
	BYTE	#%00001000
	BYTE	#%00010000
	BYTE	#%00100000
	BYTE	#%01000000
	BYTE	#%10000000
	
	_align	4
Bank7_MultiBy18
	BYTE	#0
	BYTE	#18
	BYTE	#36
	BYTE	#54


	_align	4
Bank7_DanmakuCol_LowBytes
	BYTE	#<Danmaku_Col_1W
	BYTE	#<Danmaku_Col_2W
	BYTE	#<Danmaku_Col_3W
	BYTE	#<Danmaku_Col_4W

	_align	8
Bank7_DanmakuType1_MoveX
	BYTE	#0
	BYTE	#1
	BYTE	#1
	BYTE	#1
	BYTE	#0
	BYTE	#255
	BYTE	#255
	BYTE	#255
	
	_align	8
Bank7_DanmakuType1_MoveY
	BYTE	#1
	BYTE	#1
	BYTE	#0
	BYTE	#255
	BYTE	#255
	BYTE	#255
	BYTE	#0
	BYTE	#1

	_align	4
Bank7_Danmaku_Value
	BYTE	#0
	BYTE	#1
	BYTE	#2
	BYTE	#3

	_align	4
Bank7_Max_Number_Of_Danmaku
	BYTE	#4
	BYTE	#5
	BYTE	#6
	BYTE	#8

	_align	14

Bank7_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1	

###End-Bank7

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
*	36: Y	37: Z	38: 	39: ,
*	40: '	41: +	42: -	43: =
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

	_align	14

Bank8_Return_JumpTable
	BYTE	#>Bank1_Return-1
	BYTE	#<Bank1_Return-1
	BYTE	#>Bank2_Return-1
	BYTE	#<Bank2_Return-1
	BYTE	#>Bank3_Return-1
	BYTE	#<Bank3_Return-1
	BYTE	#>Bank4_Return-1
	BYTE	#<Bank4_Return-1
	BYTE	#>Bank5_Return-1
	BYTE	#<Bank5_Return-1
	BYTE	#>Bank6_Return-1
	BYTE	#<Bank6_Return-1
	BYTE	#>Bank7_Return-1
	BYTE	#<Bank7_Return-1

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

	BYTE	#%00001000
	BYTE	#%00000000
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

	BYTE	#%00001000
	BYTE	#%00000000
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

	BYTE	#%00000000
	BYTE	#%00000000
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

	BYTE	#%00000000
	BYTE	#%00001000
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

	BYTE	#%00000000
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

	BYTE	#%10000000
	BYTE	#%00000000
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

	BYTE	#%10000000
	BYTE	#%00000000
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

	BYTE	#%00000000
	BYTE	#%00000000
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

	BYTE	#%00000000
	BYTE	#%10000000
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

	BYTE	#%00000000
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
Bank8_Display_Message
	LDA	temp17
	TAY
	ASL
	TAX
	
	LDA	Bank8_TextPointers,x
	STA	temp01
	LDA	Bank8_TextPointers+1,x
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

Bank8_Eiki_Field

	LDY	#0
	LDX	eikiBackColor
	CPX	#0
	BEQ	Bank8_NoPF0Stuff
	STY	DanmakuColor
	STY	COLUPF
	LDY	#255
Bank8_NoPF0Stuff

	LDX	eikiBackColor
	LDA	#0
	STA	WSYNC
	STX	COLUBK
	STA	COLUPF
	STA	HMCLR
	STY	PF0		; 9

	LDA	#%00000101
	STA	CTRLPF			; 3
*
*	Set sprite
*
	BIT	eikiSettings2
	BVC	Bank8_NoIncInvisibility
	LDA	counter
	AND	#%00000011
	CMP	#%00000011
	BNE	Bank8_NoIncInvisibility

	LDA	#<Bank8_Empty
	STA	temp01
	STA	temp03
	LDA	#>Bank8_Empty
	STA	temp02
	STA	temp04				; 18

	JMP	Bank8_InvisibleSprite
Bank8_NoIncInvisibility
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

Bank8_InvisibleSprite

*	LDA	#$1e
*	STA	COLUBK

Bank8_HorPos
*
*	Based on X, it will save
*	the position on strobe and also,
*	it will save the value on temp11-temp15
*
*
*  MinX = 39
** MaxX = 159
NumOfLoop=3

	LDX	#NumOfLoop
Bank8_NextHorPoz
	STA	WSYNC
	LDA	temp11,x
Bank8_DivideLoop
	sbc	#15
   	bcs	Bank8_DivideLoop
   	sta	temp11,X
   	sta	RESP0,X	
	DEX
	BPL	Bank8_NextHorPoz	

*
*	Set Basics
*

	LDA	#$20
	STA	NUSIZ1

	LDA	#$10
	STA	NUSIZ0

**	LDA	#%00000101
**	STA	CTRLPF			; 3

	ldx	#NumOfLoop
Bank8_setFine
   	lda	temp11,x
	CLC
	ADC	#16
	TAY
   	lda	Bank8_FineAdjustTable,y
   	sta	HMP0,x		
	DEX
	BPL	Bank8_setFine

	LDA	eikiY
	AND	#%00001111
	STA	temp14
	CLC
	ADC	#Eiki_Height
	STA	temp19	
	SEC
	SBC	#HitBoxMinus 
	CLC
	SBC	temp14
	STA	temp12


	STA	WSYNC
	STA	HMOVE

*	LDA	#0
*	STA	COLUBK

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
	
	STA	CXCLR

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
	LDA	Bank8_VicaVersa,x
	STA	temp14

	LDA	DanmakuColor
	STA	COLUPF

	BIT	eikiSettings
	BVS	Bank8_Eiki_Before_Magic__

	LDA	#StickColor		; 2
	ORA	temp14			; 3
	STA	COLUP0			; 3

	sleep	13

	JMP	Bank8_Eiki_Before_Loop	; 3 
Bank8_Eiki_Before_Magic__
	LDA	counter			; 3
	AND	#$F0			; 2 
	ORA	temp14			; 3
	STA	COLUP1			; 3
	
	LDA	#$0F			; 2
	SEC				; 2
	SBC	temp14			; 3
	STA	COLUP0			; 3


	JMP	Bank8_Eiki_Before_Loop	; 3 

*
*	Danmaku_Col_1R
*	Danmaku_Col_2R 
*	Danmaku_Col_3R 
*	Danmaku_Col_4R
*

	_align	125

Bank8_Eiki_Before_Loop
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
	BVC	Bank8_Eiki_Before_No_Magic	; 2 (25)

	LDA	counter
	LSR
	SBC	temp16		; 3 (28)
	AND	#%00000011	; 2 (33)

	JMP	Bank8_Eiki_Before_Was_Magic ; 2 (37) 

Bank8_Eiki_Before_No_Magic	 
	sleep	3
	LDA	#0		; 2 (27)
	ASL	temp15		; 5 (33)
	ROL			; 2 (35)

Bank8_Eiki_Before_Was_Magic
	TAY			; 2 (39)

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)

	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)
	
***	TXS			; 2 (55)

***	sleep	2

	BIT 	eikiSettings		; 2 (66)
	BVS	Bank8_Eiki_Before_Was_Magic2	; 2 (68)

	sleep	12

	LDA	Bank8_FakeMissile,y 	     ; 4 (74)
	JMP	Bank8_Eiki_Before_Was_No_Magic2 ; 3 (1)

Bank8_Eiki_Before_Was_Magic2

	sleep	4
***	sleep	9
	LDA	#255
	STA	GRP1
	LDA	#2
	STA	ENAM1

	LDA	Bank8_Magic_Pattern_0,y ; 4 (70)
***	LDA	Bank8_Magic_Pattern_1,y ; 4 (74)
***	STX	GRP0			; 3 (1)
***	LDA	#%10100101
***	sleep	2
Bank8_Eiki_Before_Was_No_Magic2
	STA	GRP0			; 3 (4)	

***	TSX			; 2 (6)
	sleep	2
Bank8_Eiki_Before_SecondLine
	LDA	Danmaku_Col_1R,x
	STA	PF1

	LDA	Danmaku_Col_2R,x
	STA	PF2		; 14 (20)

***	sleep	19
	LDA	#Eiki_HeightPlus1	; 2 (22)
	DCP	temp19			; 5 (27)
	BCC	Bank8_NoEiki_StayHere 	; 2 (29)

	LDY	#Eiki_HeightPlus1	; 2 (31)
**	STA	CXCLR			; 3 (34)
**	sleep	2
	LDA	#0
	STA	ENAM1
	JMP	Bank8_GoForEiki		; 3 (39)
***	JMP	Bank8_ResetThings
Bank8_NoEiki_StayHere
	sleep	9

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)

	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)

	DEC	temp16
	BPL	Bank8_Eiki_Before_Loop
	
	_align	145

Bank8_Eiki_Loop
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

Bank8_Eiki_Loop_Secondline
	
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

	sleep	7
**	LDA	#0
**	STA	ENAM1
**	sleep	2

Bank8_GoForEiki	

	LDA	Danmaku_Col_3R,x
	STA	PF2		; 7 (46)
	
	LDA	Danmaku_Col_4R,x
	STA	PF1		; 7 (53)

	LDX	stack		; 3 (56)
	TXS			; 2 (58)

	DEC	temp16		; 5 (63)
	DEY			; 2 (65)
	BPL	Bank8_Eiki_Loop	; 2 (67)
	
	LDY	#1

Bank8_OnlyDanmaku_Loop
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
	BPL	Bank8_OnlyDanmaku_Loop	

	LDY	#1

	DEC	temp16
	BPL	Bank8_OnlyDanmaku_Loop
*
*	Return to Bank1
*
	lda	#>(Bank1_ResetThings-1)
   	pha
   	lda	#<(Bank1_ResetThings-1)
   	pha
   	pha
   	pha
   	ldx	#1

   	jmp	bankSwitchJump

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
*	36: Y	37: Z	38: 	39: ,
*	40: '	41: +	42: -	43: =
*	44: *	45: /	46: %	47: _
*	48: .	49: !	50: ?	51: :
*

	_align	4
Bank8_TextPointers
	BYTE	#<Bank8_Level1_Name
	BYTE	#>Bank8_Level1_Name
	BYTE	#<Bank8_Level1_Message1
	BYTE	#>Bank8_Level1_Message1

	_align	1
Bank8_LevelNameLenPlus
	BYTE	#17
	BYTE	#63
*
* Higan Boredom
*
	_align	17
Bank8_Level1_Name
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
*
*	Shikieiki:
*	Lately, no evil souls have come. What could have happened?
*

	_align	63
Bank8_Level1_Message1
	BYTE	#21
	BYTE	#10
	BYTE	#30
	BYTE	#14
	BYTE	#21
	BYTE	#36
	BYTE	#39

	BYTE	#38

	BYTE	#24
	BYTE	#25

	BYTE	#38

	BYTE	#14
	BYTE	#32
	BYTE	#18
	BYTE	#21		

	BYTE	#38

	BYTE	#29
	BYTE	#25
	BYTE	#31
	BYTE	#21
	BYTE	#29

	BYTE	#38

	BYTE	#17
	BYTE	#10
	BYTE	#32
	BYTE	#14

	BYTE	#38

	BYTE	#12
	BYTE	#25
	BYTE	#22
	BYTE	#23
	BYTE	#14
	BYTE	#48

	BYTE	#38

	BYTE	#33
	BYTE	#34
	BYTE	#17
	BYTE	#10	
	BYTE	#30

	BYTE	#38

	BYTE	#12
	BYTE	#25
	BYTE	#31
	BYTE	#21
	BYTE	#13

	BYTE	#38

	BYTE	#17
	BYTE	#10
	BYTE	#32
	BYTE	#14

	BYTE	#38

	BYTE	#17
	BYTE	#10
	BYTE	#26
	BYTE	#26
	BYTE	#14
	BYTE	#24
	BYTE	#14
	BYTE	#13
	BYTE	#50

	BYTE	#38
	BYTE	#44
	BYTE	#38

	_align	24
Bank8_Empty
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000

	_align	16
Bank8_FineAdjustTable
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

	_align	16

Bank8_VicaVersa	
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

	_align	2

Bank8_FakeMissile
	BYTE	#%00000000
	BYTE	#%01100110

	_align	4
Bank8_Magic_Pattern_0
	BYTE 	#%01111110
	BYTE 	#%11111111
	BYTE 	#%01111110
	BYTE 	#%00111100

*
*	Height      = 24
*
	

	_align	24
Boom_Sprite_0
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00011000
	byte	#%00100100
	byte	#%00100100
	byte	#%00011000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000	


	_align	24
Boom_Sprite_1
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00011000
	byte	#%01000010
	byte	#%00000000
	byte	#%10011001
	byte	#%10011001
	byte	#%00000000
	byte	#%01000010
	byte	#%00011000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000	

	_align	24
Boom_Sprite_2
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00100100
	byte	#%01000010
	byte	#%00000000
	byte	#%10000001
	byte	#%10100101
	byte	#%00100100
	byte	#%01011010
	byte	#%00000100
	byte	#%00100000
	byte	#%01011010
	byte	#%00100100
	byte	#%10100101
	byte	#%10000001
	byte	#%00000000
	byte	#%01000010
	byte	#%00100100
	byte	#%00000000
	byte	#%00000000

	_align	24
Boom_Sprite_3
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00011000
	byte	#%01000010
	byte	#%00000000
	byte	#%10011001
	byte	#%10000001
	byte	#%00100100
	byte	#%01000010
	byte	#%01000010
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%00000000
	byte	#%01000010
	byte	#%01000010
	byte	#%00100100
	byte	#%10000001
	byte	#%10011001
	byte	#%00000000
	byte	#%01000010
	byte	#%00011000	; (3)

	_align	24
Boom_Color
	byte	#$0a
	byte	#$08
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0c
	byte	#$0a
	byte	#$08
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0e
	byte	#$0c
	byte	#$0a
	byte	#$08
	byte	#$0a
	byte	#$0c
	byte	#$0e
	byte	#$0c
	byte	#$0a
	byte	#$08
	byte	#$0a
	byte	#$0c
	byte	#$0e

	_align	22
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
	byte	#<Boom_Sprite_0
	byte	#>Boom_Sprite_0
	byte	#<Boom_Sprite_1
	byte	#>Boom_Sprite_1
	byte	#<Boom_Sprite_2
	byte	#>Boom_Sprite_2
	byte	#<Boom_Sprite_3
	byte	#>Boom_Sprite_3

	_align	22
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
	byte	#<Boom_Sprite_0
	byte	#>Boom_Sprite_0
	byte	#<Boom_Sprite_1
	byte	#>Boom_Sprite_1
	byte	#<Boom_Sprite_2
	byte	#>Boom_Sprite_2
	byte	#<Boom_Sprite_3
	byte	#>Boom_Sprite_3

	_align	8
Eiki_Sprite_Color_Pointers_P0
	byte 	#<Eiki_Color_Stand_Move_P0
	byte	#>Eiki_Color_Stand_Move_P0
	byte 	#<Eiki_Color_Attack_P0
	byte	#>Eiki_Color_Attack_P0
	byte 	#<Eiki_Color_Spell_P0
	byte	#>Eiki_Color_Spell_P0
	byte	#<Boom_Color
	byte	#>Boom_Color

	_align	8
Eiki_Sprite_Color_Pointers_P1
	byte 	#<Eiki_Color_Stand_Move_P1
	byte	#>Eiki_Color_Stand_Move_P1
	byte 	#<Eiki_Color_Attack_P1
	byte	#>Eiki_Color_Attack_P1
	byte 	#<Eiki_Color_Spell_P1
	byte	#>Eiki_Color_Spell_P1
	byte	#<Boom_Color
	byte	#>Boom_Color

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
 	ldx	#1
**   	ldx	#2 
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