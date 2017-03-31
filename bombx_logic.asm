; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

GetBombxSpriteID
	; d0 - Bombx ID -> Sprite ID
	add.w #0x1,d0
	
	rts
	
	
GetBombxIDFromSpriteID:
	; d0 - Sprite ID -> Bombx ID
	sub.w #0x1,d0

	rts

GetNumberSpriteIDFromBombxID:
	; d0 - Bombx ID -> First Number Sprite ID

	mulu.w #0x2,d0 	; number offset
	add.w #0x1,d0 	; player sprite offset
	add.w #0x10,d0 	; bombx sprite offset
	
	rts
	
SetGenericBombxMapEntry:
	; d0 - ID to be written
	; d1 - x
	; d2 - y
	; a0 - map
	
	sub.w #0x80,d1
	sub.w #0x80,d2
	
	and.l #0xFFFF, d1
	and.l #0xFFFF, d2	
	divu.w #0x10,d1
	divu.w #0x10,d2
	and.l #0xFFFF, d1
	and.l #0xFFFF, d2
	
	clr.l d3
	move.w d2,d3
	mulu.w #(column_amount),d3
	add.w d1,d3
	mulu.w #(wsize),d3
	
	
	add.l d3,a0
	move.w d0, (a0)
	
	rts
	

GetGenericBombxMapEntry:
	; (return) d0 - ID
	; d1 - x
	; d2 - y
	; a0 - map
	
	sub.w #0x80,d1
	sub.w #0x80,d2
	
	and.l #0xFFFF, d1
	and.l #0xFFFF, d2
	divu.w #0x10,d1
	divu.w #0x10,d2
	and.l #0xFFFF, d1
	and.l #0xFFFF, d2
	
	clr.l d3
	move.w d2,d3
	mulu.w #(column_amount),d3
	add.w d1,d3
	mulu.w #(wsize),d3
	
	add.l d3,a0
	
	move.w (a0), d0
	
	rts

	
SetBombxMapEntry:
	; d0 - ID to be written
	; d1 - x
	; d2 - y
		
	move.l #gBombxMap, a0
	jsr SetGenericBombxMapEntry
	rts

GetBombxMapEntry:
	; (return )d0 - ID
	; d1 - x
	; d2 - y
	move.l #gBombxMap, a0
	jsr GetGenericBombxMapEntry
	rts
	
SetBombxFinishedMapEntry:
	; d0 - ID to be written
	; d1 - x
	; d2 - y
	
	move.l #gBombxFinishedMap, a0
	jsr SetGenericBombxMapEntry
	rts

SetBombxPositionInBombxMap:
	; d0 - Bombx ID (w)
	; d1 - x pos (w)
	; d2 - y pos (w)
	
	clr.l d3
	move.w d0, d3
	mulu.w #(wsize*2), d3
	add.l #gBombxPositions, d3

	move.l d3,a0
	move.w (a0),d4
	move.w d1,(a0)
	
	add.l #wsize,a0 
	move.w (a0),d5
	move.w d2,(a0)
	
	jsr SetBombxMapEntry
	
	move.w #-0x1, d0
	move.w d4,d1
	move.w d5,d2
	jsr SetBombxMapEntry
	
	rts
	
SetNumberPosition:
	; d0 - Bombx ID (w)
	; d1 - Bombx pos x
	; d2 - Bombx Pos y
	
	jsr GetNumberSpriteIDFromBombxID

	add.w #0x8,d2
	
	move.w d1, -(sp)
	move.w d2,d4
	
	jsr SetSpritePosX
	
	move.w d2,d1
	jsr SetSpritePosY

	add.w #0x1,d0
	

	move.w (sp)+,d1
	add.w #0x8,d1
	jsr SetSpritePosX
	
	move.w d4,d1
	jsr SetSpritePosY
	
	
	rts
	
SetBombxPosition:
	; d0 - Bombx ID (w)
	; d1 - x pos (w)
	; d2 - y pos (w)
	
	move.w d0,i0
	move.w d1,i1
	move.w d2,i2
	
	jsr setBombxPositionInBombxMap

	move.w i0,d0
	move.w i1,d1

	jsr GetBombxSpriteID
	jsr SetSpritePosX

	move.w d1,i1
	move.w i2,d1
	jsr SetSpritePosY

	jsr GetBombxIDFromSpriteID
	move.w i1,d1
	move.w i2,d2
	jsr SetNumberPosition

	
	
	rts
	
SetBombxSpritePosition:
	; d0 - Bombx ID (w)
	; d1 - x pos (w)
	; d2 - y pos (w)
	
	jsr GetBombxSpriteID
	jsr SetSpritePosX

	move.w d2,d1
	jsr SetSpritePosY

	rts
	

	
SetBombxInactive:
	; d0 - Bombx ID (w)
	; d1 - x pos (w) 
	; d2 - y pos (w)
	
	jsr ToTilePositions

	move.w d0,-(sp)
	move.w #0x3,d0
	add.l #BGTileID,d0
	moveq #0x0,d3
	jsr SetTilePlaneB
	add.w #0x1,d1
	moveq #0x0,d3
	jsr SetTilePlaneB
	add.w #0x1,d2
	moveq #0x0,d3
	jsr SetTilePlaneB
	sub.w #0x1,d1
	moveq #0x0,d3
	jsr SetTilePlaneB
	
	move.w (sp)+,d0

	jsr GetBombxSpriteID
	
	move.w #BombxInactiveTileID,d1
	jsr SetSpriteTileID

	move.w #0x0,d1
	jsr SetSpritePosX
	
	move.w #0x0,d1
	jsr SetSpritePosY

	jsr GetBombxIDFromSpriteID
	
	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxState,a1
	add.l  d3,a1
	move.w #0x0,(a1)
	
	move.w #0x0,d1
	move.w #0x0,d2
	jsr SetNumberPosition
	
	clr.l d3
	move.w gActiveBombxAmount,d3
	sub.w #0x1,d3
	move.w d3,gActiveBombxAmount
	
	rts
	
GetNumber:
	; d0 - Bombx ID (w)
	; (return) d1 - Number value (w)
		
	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxNumber,a1
	add.l  d3,a1
	move.w (a1),d1
	
	rts
	
SetNumberTiles:
	; d0 - Bombx ID (w)
	; d1 - Number value (w)

	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxNumber,a1
	add.l  d3,a1
	move.w d1,(a1)
	
	jsr SeparateNumberIntoRegisters
	
	move.w d3,-(sp)
	
	jsr GetNumberSpriteIDFromBombxID
	move.w d2,d1
	add.w #NumberTileIDStart,d1
	jsr SetSpriteTileID
	
	move.w (sp)+,d3
	
	add.w #0x1,d0
	move.w d3,d1
	add.w #NumberTileIDStart,d1
	jsr SetSpriteTileID

	rts

SetBombxExploding:
	; d0 - Bombx ID

	clr.l d3
	move.w gCurrentLevelID,d3
	cmp #final_level,d3
	bne @KeepExploding
	
	jsr SetGameWon
	rts
	
	@KeepExploding:
	jsr GetBombxSpriteID
	move.w #BombxExplodeTileID, d1
	jsr SetSpriteTileID
	
	jsr GetBombxIDFromSpriteID
	move.w d0, -(sp)
	move.w #0x0,d1
	move.w #0x0,d2
	jsr SetNumberPosition
	move.w (sp)+,d0
	
	move.w d0, -(sp)
	jsr GetBombxPositions
	move.w #-0x1,d0
	jsr SetBombxMapEntry
	move.w (sp)+,d0

	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxState,a1
	add.l  d3,a1
	move.w #0x2,(a1)
	
	move.w #(bombx_explosion_ticks),d1
	jsr SetBombxAnimationTicks
	
	
	jsr GetBombxPositions
	move.w d1,-(sp)
	move.w d2,-(sp)
	add.w #0x10,d1
	jsr GetBombxMapEntry
	cmp #-0x1,d0
	beq @Next1
	jsr SetBombxExploding
	
	@Next1:
	move.w (sp)+,d2
	move.w (sp)+,d1
	move.w d1,-(sp)
	move.w d2,-(sp)
	add.w #0x10,d2
	clr.l d0
	jsr GetBombxMapEntry
	cmp #-0x1,d0
	beq @Next2
	jsr SetBombxExploding
	
	@Next2:
	move.w (sp)+,d2
	move.w (sp)+,d1
	move.w d1,-(sp)
	move.w d2,-(sp)
	sub.w #0x10,d2
	clr.l d0
	jsr GetBombxMapEntry
	cmp #-0x1,d0
	beq @Next3
	jsr SetBombxExploding
	
	@Next3:
	move.w (sp)+,d2
	move.w (sp)+,d1
	move.w d1,-(sp)
	move.w d2,-(sp)
	sub.w #0x10,d1
	clr.l d0
	jsr GetBombxMapEntry
	cmp #-0x1,d0
	beq @Next4
	jsr SetBombxExploding
	
	@Next4:
	move.w (sp)+,d2
	move.w (sp)+,d1

	move.w d0,-(sp)
	move.w d1,-(sp)
	move.w d2,-(sp)
	move.w d5,-(sp)
	move.w d6,-(sp)
	jsr CheckPlayerExploded
	move.w (sp)+,d6
	move.w (sp)+,d5
	move.w (sp)+,d2
	move.w (sp)+,d1
	move.w (sp)+,d0

	rts

ComparePositionsEqual:
	; d0 - (return) 1 iff equal, 0 else
	; d1 - x1 (w)
	; d2 - y1 (w)
	; d5 - x2 (w)
	; d6 - y2 (w)

	cmp d1,d5
	bne @Fail
	
	cmp d2,d6
	bne @Fail
	
	@Success:
	move.w #0x1,d0
	jmp @End
	
	@Fail:
	move.w #0x0,d0
	
	@End:
	rts

SetPlayerExplode:

	move.w #0x2,gPlayerFrame
	jsr SetCurrentAnimation
	
	move.w #60,gPlayerExplodingTicks
	
	rts
	
CheckPlayerExploded:
	; d1 - Exploding bombx x (w)
	; d2 - Exploding bombx y (w)

	jsr ToGameTilePositions
	
	clr.l d5
	clr.l d6

	move.w d1,d5
	move.w d2,d6

	move.w gPlayerX,d1
	move.w gPlayerY,d2
	
	jsr ToGameTilePositions
	
	add.w #0x1,d5
	jsr ComparePositionsEqual
	cmp #0x1,d0
	beq @PlayerExplodes

	sub.w #0x2,d5
	jsr ComparePositionsEqual
	cmp #0x1,d0
	beq @PlayerExplodes
	
	add.w #0x1,d5
	add.w #0x1,d6
	jsr ComparePositionsEqual
	cmp #0x1,d0
	beq @PlayerExplodes

	sub.w #0x2,d6
	jsr ComparePositionsEqual
	cmp #0x1,d0
	beq @PlayerExplodes
	
	jmp @End
	@PlayerExplodes:
	jsr SetPlayerExplode

	@End:
	rts

	
GetBombxAnimationTicks:
	; d0 - Bombx ID
	; (return) d1 - Animation ticks

	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxAnimationTicks,a1
	add.l  d3,a1
	move.w (a1),d1
	
	rts
	
	
SetBombxAnimationTicks:
	; d0 - Bombx ID
	; d1 - Animation Ticks

	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxAnimationTicks,a1
	add.l  d3,a1
	move.w d1, (a1)
	
	rts
	
DecreaseBombxAnimationTicksAndReturnTicks:
	; d0 - Bombx ID
	; d1 - (return) Animation ticks
	jsr GetBombxAnimationTicks
	sub.w #0x1,d1
	jsr SetBombxAnimationTicks
	
	rts
	
DecreaseSingleCountdown:
	; d0 - Bombx ID
	
	move.w d0, -(sp)
	jsr GetNumber
	move.w (sp)+, d0
	cmp #0x0,d1
	beq @End
	
	move.w d0, -(sp)
	sub.w #0x1,d1
	move.w d1,-(sp)
	jsr SetNumberTiles
	move.w (sp)+,d1
	move.w (sp)+,d0
	cmp #0x0,d1
	beq @BombxExplodes
	
	jmp @End
	
	@BombxExplodes:

	jsr SetBombxExploding
	
	@End:
	rts
	
SetBombxActive:
	; d0 - Bombx ID (w)
	
	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxState,a1
	add.l  d3,a1
	move.w #0x1,(a1)
	
	rts

GetBombxPositions:
	; d0 - Bombx ID (w)
	; (return) d1 - x pos
	; (return) d2 - y pos
	
	moveq #0x0,d3
	move.w d0,d3
	mulu.w #(wsize*2),d3
	
	move.l #gBombxPositions,a1
	add.l  d3,a1
	move.w (a1)+,d1
	move.w (a1)+,d2
	
	rts
	
	
GetBombxState:
	; d0 - Bombx ID (w)
	; (return) d1 - state ; 0 dead; 1 idle; 2 exploding

	moveq #0x0,d3
	move.w d0,d3
	mulu.w #wsize,d3
	
	move.l #gBombxState,a1
	add.l  d3,a1
	move.w (a1),d1
	
	rts
	
	
UpdateBombxCountdowns:
	moveq #0x0,d6
	@Loop:
		
	move.w d6,d0
	jsr GetBombxState
	cmp #0x0,d1
	beq @Skip
	
	move.w d6,d0
	jsr DecreaseSingleCountdown
	
	@Skip:
	
	add.w #0x1,d6
	move.w gBombxAmount,d3
	cmp d3,d6
	bne @Loop
	
	
	rts

UpdateSingleBombxExplosion:
	; d0 - bombx id (w)

	jsr DecreaseBombxAnimationTicksAndReturnTicks
	
	cmp #(bombx_explosion_ticks/2),d1
	beq @Frame2
	
	cmp #0x0,d1
	beq @Kill
	
	jmp @End

	@Frame2:
	
	jsr GetBombxSpriteID
	move.w #BombxExplodeTileID, d1
	add.w #(BombxFrameSizeT), d1
	jsr SetSpriteTileID
		
	jmp @End

	@Kill:
	jsr GetBombxPositions
	jsr SetBombxInactive

	@End:
	rts

	
UpdateBombxExplosions:
	
	moveq #0x0,d6
	@Loop:
		
	move.w d6,d0
	jsr GetBombxState
	cmp #0x2,d1
	bne @Skip
	
	move.w d6,d0
	jsr UpdateSingleBombxExplosion
	
	@Skip:

	add.w #0x1,d6
	move.w gBombxAmount,d3
	cmp d3,d6
	bne @Loop
	
	@End:
	rts
