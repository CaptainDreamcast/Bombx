; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

LoadHoleAmount:
	; a0 - LevelMapAddress

	move.l a0,a3

	clr.l d3 ; counter

	move.w #row_amount,d6
	jmp @RowLoopEnd
	
	@RowLoop:
	@ColumnLoop:
	
	move.w (a3)+,d4
	add.l #wsize,a3
	
	cmp #0x0,d4
	bne @Skip
	
	add.w #0x1,d3
	
	@Skip:
	
	@ColumnLoopEnd:
	dbra d5,@ColumnLoop
	add.l #((0x40-column_amount*2)*wsize),a3 ; skip buffer area
	add.l #(0x40*wsize),a3 ; skip row
	
	@RowLoopEnd:
	move.w #column_amount,d5
	dbra d6,@ColumnLoopEnd
	
	move.w d3,gHolesLeft
	
	rts

CheckLevelOver:
	; (return) d0 - 1 iff level over, else 0 

	clr.l d0
	
	clr.l d3
	move.w gScreenStatus,d3
	
	cmp #0x1,d3
	bne @Over
	
	clr.l d3
	move.w gHolesLeft,d3
	cmp #0x0,d3
	bne @Continue
	
	move.w gActiveBombxAmount,d3
	cmp #0x0,d3
	bne @Continue
	
	move.w gPlayerExplodingTicks,d3
	cmp #0x0,d3
	bne @Continue
	
	jsr SetLevelWon
	
	@Continue:
	move.w #0x0,d0
	jmp @End
	
	@Over:
	move.w #0x1,d0
	
	@End:
	rts

DrawTimerValues:
	; d1 - pos XY (w) #0xXXYY
	; d3 - value (w) < 10
	; d4 - value (w) < 10
	; d5 - value (w) < 10
	
	move.l #gTimerBuffer,a3
	add.w #'0',d3
	add.w #'0',d4
	add.w #'0',d5
	move.b d3,(a3)+
	move.b d4,(a3)+
	move.b d5,(a3)+
	move.b #0x0,(a3)+
	move.l #gTimerBuffer,a3
	
	lea       gTimerBuffer, a0         
	move.l    #PixelFontTileID, d0 
	move.l    #0x3, d2             ; Palette 
	jsr       DrawTextPlaneA       
	
	rts

	
IncreaseTimerCounter:
	; d1 - value (w)
	move.w gTimer,d2
	add.w d2,d1

	jsr SetTimerCounter
	
	rts
	
SetTimerCounter:
	; d1 - value (w)
	move.w d1,gTimer
	
	cmp #999,d1
	ble @ClipOver
	move.w #999,d1
	@ClipOver:
	
	jsr SeparateNumberIntoRegisters
	clr.l d4
	clr.l d5
	move.w d3,d5
	move.w d2,d4
	move.w d1,d3

	move.w    #0x1801, d1          ; XY 
	jsr DrawTimerValues
	
	rts


DecreaseTimerCounter:
	move.w gTimer,d1
	cmp #0x0,d1
	bne @NoGameOver

	jsr SetLevelLost
	
	jmp @End
	@NoGameOver:

	sub.w #0x1,d1
	jsr SetTimerCounter
	
	@End:
	rts
	
UpdateTimerCounter:
	move.w gTimerTicks,d3
	add.w #0x1,d3
	cmp.w #60,d3
	bne @End

	jsr DecreaseTimerCounter
	move.w #0x0,d3
	
	@End:
	move.w d3,gTimerTicks
	rts
	
	
GameTileToRealPosition:
	; d1 - x (16er tile -> real pos) (w)
	; d2 - y (16er tile -> real pos) (w)
	
	mulu.w #0x10,d1
	mulu.w #0x10,d2
	add.w #0x80,d1
	add.w #0x80,d2
	
	rts
	
LoadLevel:

	clr.l d3

	lea LevelMap,a1
	move.w gCurrentLevelID,d3
	mulu.w #lsize,d3
	add.l d3, a1
	
	move.l (a1),a0
	
	move.l (a0)+, a1
	move.l a0, a2
	move.l a1, a0 ; get level map to a0 and store data address in a2

	move.l a0,gLevelMapAddress

	jsr LoadHoleAmount
	
	move.w   #BGMapSizeW, d0     
	move.l   #0x00, d1               ; Y offset in d1
	move.w   #BGTileID, d2  
	move.l   #0x0, d3                ; Palette ID in d3
	jsr      LoadMapPlaneB          

	move.l a2,a0
	
	clr.l d1
	move.w (a0)+,d1
	
	move.w gIsReloadingLevel,d3
	cmp.w #0x1,d3
	bne @TimerIncrease
	move.w #0x0,d1
	@TimerIncrease:
	move.w #0x0,gIsReloadingLevel
	
	move.l a0, -(sp)
	jsr IncreaseTimerCounter
	move.l (sp)+,a0
	
	move.w (a0)+, d1
	move.w (a0)+, d2
	jsr GameTileToRealPosition
	move.w d1,gPlayerX
	move.w d2,gPlayerY
	jsr UpdatePlayerPosition
	
	move.w (a0)+, d6
	move.w d6, gBombxAmount
	move.w d6, gActiveBombxAmount

	clr.l d6
	@LoadBombxLoop:
	
	move.w d6,d0
	move.w (a0)+, d1
	move.w (a0)+, d2
	jsr GameTileToRealPosition
	
	move.l a0,a3
	
	jsr SetBombxPosition

	move.l a3,a0

	move.w d6,d0
	move.w (a0)+,d1
	jsr SetNumberTiles
	
	move.w d6,d0
	jsr SetBombxActive
	
	add.w #0x1,d6
	move.w gBombxAmount,d5
	cmp.w d5,d6
	bne @LoadBombxLoop
		
	rts

ToTilePositions:
	;d1 - x (total pos -> t) (w)
	;d2 - y (total pos -> t) (w)
	
	sub.w #0x80,d1
	sub.w #0x80,d2
	
	and.l #0xFFFF,d1
	and.l #0xFFFF,d2

	divu.w #0x8,d1
	divu.w #0x8,d2
	
	and.l #0xFFFF,d1
	and.l #0xFFFF,d2
	
	rts

ToGameTilePositions:
	;d1 - x (total pos -> t) (w)
	;d2 - y (total pos -> t) (w)
	
	sub.w #0x80,d1
	sub.w #0x80,d2
	
	and.l #0xFFFF,d1
	and.l #0xFFFF,d2

	divu.w #0x10,d1
	divu.w #0x10,d2
	
	and.l #0xFFFF,d1
	and.l #0xFFFF,d2
	
	rts

SetLevelWon:
	clr.l d3

	move.w gCurrentLevelID,d3
	add.w #0x1,d3
	move.w d3,gCurrentLevelID
	
	move.w #0x0, gScreenStatus
	
	move.l #GameScreenFunction,gScreenPointer
	
	rts

SetGameWon:
	move.w #0x0, gScreenStatus	
	move.l #CongratsScreen,gScreenPointer
	
	rts
	
SetLevelLost:

	clr.l d3
	move.w gCurrentLevelID,d3
	cmp #0x0,d3
	beq @NoReduce
	sub.w #0x1,d3
	@NoReduce:
	move.w d3,gCurrentLevelID
	
	move.w #0x0, gTimer
	move.w #0x0, gScreenStatus	
	
	rts

ResetScreen:
	move.w #0x1,gIsReloadingLevel
	move.w #0x0, gScreenStatus
	rts
	
DecreaseHolesLeft:
	clr.l d3
	move.w gHolesLeft,d3
	sub.w #0x1,d3
	move.w d3,gHolesLeft
	
	cmp #0x0,d3
	bne @End
	
	move.w gActiveBombxAmount,d3
	cmp #0x0,d3
	bne @End
	
	jsr SetLevelWon

	@End:
	rts