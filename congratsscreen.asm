; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

CongratsScreen:

	jsr ResetScrolling
	jsr ClearPalettes

	lea      congratsscreen_tiles, a0      
    move.l   #CongratsScreenVRAM, d0 
    move.l   #CongratsScreenTileSizeT, d1 
	jsr      LoadTiles            
	
	lea congratsscreen_map, a0
	move.w   #CongratsScreenMapSizeW, d0     
	move.l   #0x00, d1               ; Y offset in d1
	move.w   #CongratsScreenTileID, d2  
	move.l   #0x0, d3                ; Palette ID in d3
	jsr      LoadMapPlaneA          
	
	
	move.w #0x0,d0
	jsr SetHScroll

	move.w #0x10,d0
	jsr SetVScroll

	jsr DeactivateSprites

	lea   CongratsScreenPalettes,a0
	move.l  #0x1,d0
	jsr FadeInPalettes

	
	@GameLoop:

	 jsr ReadPad1 

	 btst   #pad_button_start, d1
	 bne    @NoStart              
	 jmp 	@End
	 @NoStart:
	
	jsr WaitForScreenStart   
	jsr     WaitForScreenEnd 

	jmp     @GameLoop    
	
	
	@End:

	jsr DeactivateSprites
	lea   CongratsScreenPalettes,a0
	move.l  #0x1,d0
	jsr FadeOutPalettes
	
	move.w #0x0,d0
	jsr SetHScroll  
	
	move.w #0x0,d0
	jsr SetVScroll
	
	move.l #TitleScreen, gScreenPointer
	
	rts 