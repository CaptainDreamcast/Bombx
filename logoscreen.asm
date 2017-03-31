; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

LogoScreen:

	jsr ClearPalettes
	
	lea      logoscreen_tiles, a0       
    move.l   #LogoScreenVRAM, d0 
    move.l   #LogoScreenTileSizeT, d1 
	jsr      LoadTiles             
	
	lea logoscreen_map, a0
	move.w   #LogoScreenMapSizeW, d0     
	move.l   #0x00, d1               ; Y offset in d1
	move.w   #LogoScreenTileID, d2  
	move.l   #0x0, d3                ; Palette ID in d3
	jsr      LoadMapPlaneA           
	
	jsr DeactivateSprites

	jsr ResetScrolling
	
	lea   LogoScreenPalettes,a0
	move.l  #0x1,d0
	jsr FadeInPalettes
	
	clr.l d6
	move.w #200,d6
	

	@GameLoop:

	 jsr ReadPad1 

	 btst   #pad_button_start, d1 
	 bne    @NoStart              
	 jmp 	@End
	 @NoStart:
	
	move.w d6, -(sp)
	
	jsr WaitForScreenStart   
	
	jsr ResetScrolling
	
	jsr     WaitForScreenEnd 

	move.w (sp)+,d6
	dbra d6,@GameLoop
	
	@End:
	clr.l d6
	
	lea   LogoScreenPalettes,a0
	move.l  #0x1,d0
	jsr FadeOutPalettes

	move.l #TitleScreen, gScreenPointer

	
	rts 