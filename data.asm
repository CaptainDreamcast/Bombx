; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya


column_amount		equ 20
row_amount 			equ 14
box_amount			equ 16
bombx_explosion_ticks equ 0x20


GameData:
gTimer 					equ (gLibrarySentinel) ; w
gTimerTicks 			equ (gTimer+wsize) ; w
gTimerBuffer			equ (gTimerTicks+wsize) ; 8 bytes
gIsReloadingLevel		equ (gTimerBuffer+(bsize*8)) ; w
gDebugFlag 				equ (gIsReloadingLevel+wsize)  ; w
gGameSentinel 			equ (gDebugFlag+wsize) 

LevelData:
gLevelMapAddress		equ (gGameSentinel) ; l
gHolesLeft				equ (gLevelMapAddress+lsize) ; w
gScreenStatus			equ (gHolesLeft+wsize) ; w
gLevelSentinel			equ (gScreenStatus+wsize) ; sentinel value

PlayerData:
gPlayerX				equ (gLevelSentinel) ; w
gPlayerY				equ (gPlayerX+wsize) ; w
gPlayerSpriteSettings 	equ (gPlayerY+wsize) ; b
gPlayerSpriteTileID 	equ (gPlayerSpriteSettings+bsize) ; b
gPlayerMovingTicks		equ (gPlayerSpriteTileID+bsize) ; w
gPlayerDX				equ (gPlayerMovingTicks+wsize) ; w
gPlayerDY				equ (gPlayerDX+wsize) ; w
gDummy					equ (gPlayerDY+wsize) ; w
gPlayerFrameAddress		equ (gDummy+wsize) ; l
gPlayerFrameAmount 		equ (gPlayerFrameAddress+lsize) ; w
gPlayerFrame            equ (gPlayerFrameAmount+wsize) ; w
gPlayerExplodingTicks   equ (gPlayerFrame+wsize) ; w
gPlayerSentinel 		equ (gPlayerExplodingTicks+wsize) ; sentinel value

BombxData:
gBombxMap				equ (gPlayerSentinel) ; 20 x 14 x w
gBombxFinishedMap		equ (gBombxMap+(wsize*column_amount*row_amount)) ;20 x 14 x w ; TODO: fix this into sth better
gBombxPositions			equ (gBombxFinishedMap+(wsize*column_amount*row_amount)) ; 16 x 2 x w
gBombxAmount			equ (gBombxPositions+(wsize*2*box_amount))  ; w
gActiveBombxAmount		equ (gBombxAmount+wsize) ; w
gMovingBombxID			equ (gActiveBombxAmount+wsize) ; w
gBombxState 			equ (gMovingBombxID+wsize) ; w*box_amount
gBombxNumber			equ (gBombxState+(wsize*box_amount)) ; w*box_amount
gBombxAnimationTicks 	equ (gBombxNumber+(wsize*box_amount)) ; w*box_amount ; used as w until necessary

ASCIIStart: equ 0x20 ; First ASCII code in table
ASCIIMap:
	dc.b 0x00   ; SPACE (ASCII code 0x20)
	dc.b 0x28   ; ! Exclamation mark
	dc.b 0x2B   ; " Double quotes
	dc.b 0x2E   ; # Hash
	dc.b 0x00   ; UNUSED
	dc.b 0x00   ; UNUSED
	dc.b 0x00   ; UNUSED
	dc.b 0x2C   ; ' Single quote
	dc.b 0x29   ; ( Open parenthesis
	dc.b 0x2A   ; ) Close parenthesis
	dc.b 0x00   ; UNUSED
	dc.b 0x2F   ; + Plus
	dc.b 0x26   ; , Comma
	dc.b 0x30   ; - Minus
	dc.b 0x25   ; . Full stop
	dc.b 0x31   ; / Slash or divide
	dc.b 0x1B   ; 0 Zero
	dc.b 0x1C   ; 1 One
	dc.b 0x1D   ; 2 Two
	dc.b 0x1E   ; 3 Three
	dc.b 0x1F   ; 4 Four
	dc.b 0x20   ; 5 Five
	dc.b 0x21   ; 6 Six
	dc.b 0x22   ; 7 Seven
	dc.b 0x23   ; 8 Eight
	dc.b 0x24   ; 9 Nine
	dc.b 0x2D   ; : Colon
	dc.b 0x00   ; UNUSED
	dc.b 0x00   ; UNUSED
	dc.b 0x00   ; UNUSED
	dc.b 0x00   ; UNUSED
	dc.b 0x27   ; ? Question mark
	dc.b 0x00   ; UNUSED
	dc.b 0x01   ; A
	dc.b 0x02   ; B
	dc.b 0x03   ; C
	dc.b 0x04   ; D
	dc.b 0x05   ; E
	dc.b 0x06   ; F
	dc.b 0x07   ; G
	dc.b 0x08   ; H
	dc.b 0x09   ; I
	dc.b 0x0A   ; J
	dc.b 0x0B   ; K
	dc.b 0x0C   ; L
	dc.b 0x0D   ; M
	dc.b 0x0E   ; N
	dc.b 0x0F   ; O
	dc.b 0x10   ; P
	dc.b 0x11   ; Q
	dc.b 0x12   ; R
	dc.b 0x13   ; S
	dc.b 0x14   ; T
	dc.b 0x15   ; U
	dc.b 0x16   ; V
	dc.b 0x17   ; W
	dc.b 0x18   ; X
	dc.b 0x19   ; Y
	dc.b 0x1A   ; Z (ASCII code 0x5A)	
	
	
  include 'assets\assets.asm'
  include 'assets\levels.asm'