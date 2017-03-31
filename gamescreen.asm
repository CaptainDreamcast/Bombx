; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

	include 'movement.asm'
	include 'gamescreen_init.asm'
	include 'level.asm'
	include 'bombx_logic.asm'
	
GameScreenFunction:

	jsr GameScreenInit
	jsr ResetScrolling
	jsr ClearPalettes
	
	; Load font
	lea      PixelFont, a0       
    move.l   #PixelFontVRAM, d0  
    move.l   #PixelFontSizeT, d1 
	jsr      LoadTiles             

	; load BG tiles
	lea      BG_tiles, a0       
    move.l   #BGVRAM, d0 
    move.l   #BGTileSizeT, d1 
	jsr      LoadTiles             
	
	; Load player frame
	lea      PLAYER_UP0, a0           
    move.l   #PlayerVRAM, d0     
    move.l   #PlayerFrameSizeT, d1 ; Move number of tiles (in one anim frame only) to d1
	jsr      LoadTiles  

	; Load Bombx sprites
	lea      BOMBX_IDLE, a0           
    move.l   #BombxIdleVRAM, d0     
    move.l   #BombxFrameSizeT, d1
	jsr      LoadTiles  
	
	lea      BOMBX_INACTIVE, a0           
    move.l   #BombxInactiveVRAM, d0      
    move.l   #BombxFrameSizeT, d1
	jsr      LoadTiles  
	
	lea      BOMBX_EXPLODE, a0        
    move.l   #BombxExplodeVRAM, d0      
    move.l   #(BombxFrameSizeT*2), d1 
	jsr      LoadTiles  
	
	lea 	 NUMBER_TILES,a0
	move.l 	 #NumberVRAM, d0
	move.l 	 #NumberTotalSizeT,d1
	jsr 	 LoadTiles  
	
	; Draw Texts
	lea       PressCString, a0         
	move.l    #PixelFontTileID, d0 
	move.w    #0x061A, d1          ; XY
	move.l    #0x3, d2             ; Palette 
	jsr       DrawTextPlaneA       
	
	lea       TimeLeftString, a0         
	move.l    #PixelFontTileID, d0 
	move.w    #0x0E01, d1          ; XY 
	move.l    #0x3, d2             ; Palette 
	jsr       DrawTextPlaneA       

	move.w gCurrentLevelID, d0
	cmp #0x0,d0
	bne @TutorialEnd
	
	lea 	TutorialString1, a0
	move.l    #PixelFontTileID, d0 
	move.w    #0x0614, d1          ; XY 
	move.l    #0x3, d2             ; Palette 
	jsr       DrawTextPlaneA      
	
	lea 	TutorialString2, a0
	move.l    #PixelFontTileID, d0 
	move.w    #0x0815, d1          ; XY 
	move.l    #0x3, d2             ; Palette 
	jsr       DrawTextPlaneA      
	
	@TutorialEnd:
	
	move.l  #SpriteDescs, a0		
	move.w  #0x31, d0			; # sprites
	jsr     LoadSpriteTables	
	
	move.w  #0x0,  d0	  ; Sprite ID
	move.w  gPlayerX, d1	  
	jsr     SetSpritePosX 
	move.w  gPlayerY, d1	  
	jsr     SetSpritePosY 
	
	jsr LoadLevel
	
	lea   GameScreenPalettes,a0
	move.l  #0x3,d0
	jsr FadeInPalettes
	
	@GameLoop:

	 jsr ReadPad1 

	btst   #pad_button_start, d0 
	bne    @NoAbort 
	btst   #pad_button_a, d0 
	bne    @NoAbort 
	btst   #pad_button_b, d0 
	bne    @NoAbort 
	btst   #pad_button_c, d0 
	bne    @NoAbort 
	move.l #TitleScreen, gScreenPointer
	jmp 	@End
	@NoAbort:
	 
	clr.l d3
	move.w gPlayerExplodingTicks,d3
	cmp #0x0,d3
	bne @InputOver
	
	 btst   #pad_button_c, d1 
	 bne    @NoC              
	 jsr ResetScreen
	 @NoC:
	 
	 btst   #pad_button_right, d0 
	 bne    @NoRight             
	 jsr MoveRight
	 @NoRight:
	 
	 move.w gGamePadState,d0
	 btst   #pad_button_left, d0  
	 bne    @NoLeft               
	 jsr MoveLeft
	 @NoLeft:
	 
     move.w gGamePadState,d0
	 btst   #pad_button_down, d0  
	 bne    @NoDown             
	 jsr MoveDown
	 @NoDown:
	 
	 move.w gGamePadState,d0
	 btst   #pad_button_up, d0  
	 bne    @NoUp             
	 jsr MoveUp
	 @NoUp:
	 @NoDirectionalInput:

	 jsr CheckMovement
	 @InputOver:
	 
	 jsr UpdateBombxExplosions
	 jsr UpdateTimerCounter
	 jsr UpdatePlayerExplosion
	 
	 jsr CheckLevelOver
	 cmp #0x1,d0
	 beq @End
	 
	jsr WaitForScreenStart  

	move.w #0x0,d0
	jsr SetHScroll
	
	jsr     WaitForScreenEnd 

	jmp     @GameLoop    
	
	@End:

	lea   GameScreenPalettes,a0
	move.l  #0x3,d0
	jsr FadeOutPalettes
	
	rts 
	
SpriteDescs:
PlayerDesc:
    dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x11              ; Index of next sprite (linked list)
    dc.b (%00100000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b PlayerTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
BombxDescs:
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x02              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x03              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x04              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x05              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x06              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x07              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x08              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x09              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0A              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0B              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0C              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0D              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0E              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x0F              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x10              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0101) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x00              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b BombxIdleTileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)

NumberSpriteDescs:

	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x12              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x13              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x14              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x15              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)

	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x16              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x17              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x18              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x19              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x1A              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x1B              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x1C              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x1D              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x1E              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x1F              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x20              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x21              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x22              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x23              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x24              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x25              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x26              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x27              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x28              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x29              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x2A              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x2B              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x2C              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x2D              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x2E              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x2F              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x30              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
	dc.w 0x0000            ; Y coord (+ 128)
    dc.b (%0000) ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x01              ; Index of next sprite (linked list)
    dc.b (%11000000)              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b NumberTileIDStart     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
GameStrings:
PressCString:
	dc.b "PRESS C TO RESET THE SCREEN! ", 0		
	
TimeLeftString:
	dc.b "TIME LEFT: ", 0		
	
	
TutorialString1:
	dc.b "FILL ALL THE HOLES ", 0
	
TutorialString2:
	dc.b "AND EXPLODE ALL THE BOMBXES! ", 0