; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

GameOverScreen:

	jsr ResetScrolling
	
	jsr ClearPalettes
	

	lea      gameoverscreen_tiles, a0       
    move.l   #GameOverScreenVRAM, d0 
    move.l   #GameOverScreenTileSizeT, d1 
	jsr      LoadTiles            
	
	lea gameoverscreen_map, a0
	move.w   #GameOverScreenMapSizeW, d0     
	move.l   #0x00, d1               ; Y offset in d1
	move.w   #GameOverScreenTileID, d2 
	move.l   #0x0, d3                ; Palette ID in d3
	jsr      LoadMapPlaneA           
	
	jsr DeactivateSprites

	lea   GameOverScreenPalettes,a0
	move.l  #0x1,d0
	jsr FadeInPalettes
	
	@GameLoop:


	 jsr ReadPad1 ; Read pad 1 state, result in d0

	 btst   #pad_button_start, d1 ; Check start button
	 bne    @NoStart              ; Branch if button off
	 jmp 	@End
	 @NoStart:
	
	jsr WaitForScreenStart   ; Wait for start of vblank
	
	jsr     WaitForScreenEnd ; Wait for end of vblank

	jmp     @GameLoop      ; Back to the top
	
		
	@End:

	lea   GameOverScreenPalettes,a0
	move.l  #0x1,d0
	jsr FadeOutPalettes

	move.l #TitleScreen, gScreenPointer

	
	rts 