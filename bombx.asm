; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya


	include '../addons/libtari/md/wrapper.asm'
	
	include 'data.asm'

	include 'logoscreen.asm'
	include 'titlescreen.asm'
	include 'gameoverscreen.asm'
	include 'gamescreen.asm'
	include 'congratsscreen.asm'
	
	
	
	
__main:
	
	jsr SetAutoIncrement2     ; Set autoincrement to 2 bytes

	move.l #GameScreenFunction, gScreenPointer
	
	@SuperLoop:
	
	move.l gScreenPointer,a0
	jsr (a0)
	
	jsr ClearScreen
	
	jmp @SuperLoop


; End of ROM
__end: