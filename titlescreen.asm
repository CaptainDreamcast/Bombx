; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

ResetGame:
	move.w #0x0,ScreenReturnValue
	move.w #0x0,gCurrentLevelID 	
	move.l #GameScreenFunction, gScreenPointer
	move.w #0x0,gTimer
	move.w #0x0,gTimerTicks
	move.w #0x0,gIsReloadingLevel
	
	rts

UpdateFlameAnimation:
	sub.w #0x1,d5

	cmp #0x0,d5
	bne @End
	
	move.w #0x8,d5
	add.w #0x1,d6

	cmp #0x4,d6
	bne @NoReset
	moveq #0x0,d6
	@NoReset:

	clr.l d3
	move.w d6,d3
	mulu.w #FlameFrameSizeB,d3
	add.l #flame_tiles,d3
	move.l d3,a0
	move.l   #FlameVRAM, d0  
    move.l   #FlameFrameSizeT, d1 
	jsr      LoadTiles     
	
	@End:
	rts
	
	
TitleScreen:

	jsr ResetScrolling
	jsr ClearPalettes
	

	lea      titlescreen_tiles, a0     
    move.l   #TitleScreenVRAM, d0  
    move.l   #TitleScreenTileSizeT, d1 
	jsr      LoadTiles     	
	
	lea      flame_tiles, a0      
    move.l   #FlameVRAM, d0 
    move.l   #FlameFrameSizeT, d1 
	jsr      LoadTiles     
	
	lea titlescreen_map, a0
	move.w   #TitleScreenMapSizeW, d0     
	move.l   #0x00, d1               ; Y offset in d1
	move.w   #TitleScreenTileID, d2  
	move.l   #0x0, d3                ; Palette ID in d3
	jsr      LoadMapPlaneA          
	
	
	move.w #0x0,d0
	jsr SetHScroll
	move.w #0x10,d0
	jsr SetVScroll

	move.l  #TitleSpriteDescs, a0		
	move.w  #0x1, d0			; 1 sprite
	jsr     LoadSpriteTables	

	lea   TitleScreenPalettes,a0
	move.l  #0x1,d0 ; palette amount
	jsr FadeInPalettes
	
	move.w #0x10, d5 ; Flame Animation ticks
	move.w #0x0, d6 ; Flame frame
	
	@GameLoop:

	
	 jsr ReadPad1 
	
     btst   #pad_button_start, d1 
	 bne    @NoStart             
	 jmp 	@End
	 @NoStart:

	jsr 	UpdateFlameAnimation
	jsr 	WaitForScreenStart  
	jsr     WaitForScreenEnd 

	jmp     @GameLoop      
	
	
	
	@End:

	lea   TitleScreenPalettes,a0
	move.l  #0x1,d0 ; palette amount
	jsr FadeOutPalettes
	
	move.w #0x0,d0
	jsr SetHScroll
	
	move.w #0x0,d0
	jsr SetVScroll
	
	jsr ResetGame
	
	rts 
	

TitleSpriteDescs:
    dc.w (0x80+135-0x10)            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0              ; Index of next sprite (linked list)
    dc.b (%00000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b FlameTileID     ; Index of first tile
    dc.w (0x80+218)            ; X coord (+ 128)
	
	