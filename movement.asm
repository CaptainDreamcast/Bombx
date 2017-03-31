; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

SetCurrentAnimation:
	; no params
	
	move.l gPlayerFrameAddress, a0

	clr.l d1
	move.w gPlayerFrame,d1
	mulu.w #PlayerFrameSizeB,d1
	add.l d1,a0
	
	move.l   #PlayerVRAM, d0      
    move.l   #PlayerFrameSizeT, d1 ; Move number of tiles (in one anim frame only) to d1
	jsr      LoadTiles   

	rts

 
IncreasePlayerFrame:
	move.w gPlayerFrame,d1
	move.w gPlayerFrameAmount,d2
	
	add.w #0x1,d1

	cmp.w d1,d2
	bne @End

	move.w #0x0,d1

	@End:
	move.w d1,gPlayerFrame
	
	jsr SetCurrentAnimation
	
	rts

	
CheckInBoxMap:
	; d0 - (return) target box id (-1 if none) (w)
	; d1 - target pos x (-0x80) (w)
	; d2 - target pos y (-0x80) (w)
	; a1 - map (l)
	
	and.l #0xFFFF, d1
	and.l #0xFFFF, d2
	divu.w #0x10,d1
	divu.w #0x10,d2
	and.l #0xFFFF, d1
	and.l #0xFFFF, d2
	
	mulu.w #(column_amount),d2
	
	moveq #0x0,d3
	move.w d1,d3
	add.w d2,d3
	mulu.w #0x2,d3
	
	
	add.l d3,a1
	moveq #0x0,d0
	move.w (a1),d0

	rts
	
	
	
CheckIfBoxThere:
	; d0 - (return) target box id (-1 if none) (w)
	; d1 - target pos x (-0x80) (w)
	; d2 - target pos y (-0x80) (w)
	
	move.l #gBombxMap, a1
	jsr CheckInBoxMap
	rts
		
CheckIfFinishedBoxThere:
	; d0 - (return) target box id (-1 if none) (w)
	; d1 - target pos x (-0x80) (w)
	; d2 - target pos y (-0x80) (w)
	; 
	move.l #gBombxFinishedMap, a1
	jsr CheckInBoxMap	
	rts
	
GetTileIDOffset;
	; a1 - (return) tile map offset to topleft corner
	; d1 - target x 
	; d2 - target y

	sub.w #0x80,d1
	sub.w #0x80,d2
	and.l #0xFFFF,d1
	and.l #0xFFFF,d2
	
	clr.l d3
	move.w #0x4,d3
	divu.w d3,d1  ; get word position from x coordinate
	
	mulu.w #0x10,d2 ; get row offset from Y-coordinate  (y-pos/8)*0x80
	
	move.l gLevelMapAddress,a1
	move.w d1,d3
	add.l d3,a1 
	move.w d2,d3
	add.l d3,a1

	rts
	
BoxCanMoveThere:
	; d0 - (return) 1 iff can move there, else 0
	; d1 - targetX (w)
	; d2 - targetY (w)
 
	move.w d1,d5
	move.w d2,d6
 
	sub.w #0x80,d5
	sub.w #0x80,d6
	and.l #0xFFFF,d6
	and.l #0xFFFF,d6
	
	jsr GetTileIDOffset
	
	clr.l d3
	move.w (a1), d3
	
	cmp #0x0000,d3
	beq @Success
	
	cmp #0x0003,d3
	bne @Fail

	add.l #0x2,a1
	clr.l d3
	move.w (a1), d3
	cmp #0x0003,d3
	bne @Fail
	
	sub.l #0x2,a1
	add.l #0x80,a1
	clr.l d3
	move.w (a1), d3
	cmp #0x0003,d3
	bne @Fail
	
	add.l #0x2,a1
	clr.l d3
	move.w (a1), d3
	cmp #0x0003,d3
	bne @Fail
	
	move.w d5,d1
	move.w d6,d2
	
	jsr CheckIfBoxThere
	move.w d0,d3
	
	cmp #-0x1,d3
	bne @Fail
	
	@Success:
	move.w #0x1,d0
	jmp @End

	@Fail:
	move.w #0x0,d0
	
	@End:
	rts
	
CanMoveThere:
	; d0 - (return) 1 iff can move there, else 0
	; d1 - targetX (w)
	; d2 - targetY (w)
 
	move.w d1,d5
	move.w d2,d6
	sub.w #0x80,d5
	sub.w #0x80,d6
	and.l #0xFFFF,d5
	and.l #0xFFFF,d6
	
	jsr GetTileIDOffset
	
	clr.l d3
	move.w (a1), d3
	
	cmp #0x0000,d3
	bne @NoHoleTile
	
	move.w d5,d1
	move.w d6,d2
	move.w d3, -(sp)
	jsr CheckIfFinishedBoxThere
	move.w (sp)+,d3
	
	cmp #-0x1,d0
	bne @BoxCheck
	
	
	@NoHoleTile:
	
	cmp #0x0003,d3
	bne @Fail

	add.l #0x2,a1
	clr.l d3
	move.w (a1), d3
	cmp #0x0003,d3
	bne @Fail
	
	sub.l #0x2,a1
	add.l #0x80,a1
	clr.l d3
	move.w (a1), d3
	cmp #0x0003,d3
	bne @Fail
	
	add.l #0x2,a1
	clr.l d3
	move.w (a1), d3
	cmp #0x0003,d3
	bne @Fail

	@BoxCheck:
	move.w d5,d1
	move.w d6,d2
	
	jsr CheckIfBoxThere
	move.w d0,d3
	
	cmp #-0x1,d3
	beq @NoBox

	move.w d3, -(sp)
	
	move.w d3, d0
	move.w i1, d1
	move.w i2, d2	
	mulu.w #0x10,d1
	mulu.w #0x10,d2
	add.w #0x80,d1
	add.w #0x80,d2
	add.w d5,d1
	add.w d6,d2	
	jsr BoxCanMoveThere
	move.w (sp)+, d3
	
	cmp #0x0,d0
	beq @Fail
	
	move.w d3,gMovingBombxID
	move.w #-0x1, d0
	move.w d5,d1
	move.w d6,d2
	add.w #0x80,d1
	add.w #0x80,d2
	move.l a0, -(sp)
	jsr SetBombxMapEntry
	move.l (sp)+, a0
	
	@NoBox:
	
	@Success:
	move.w #0x1,d0
	jmp @End

	@Fail:
	move.w #0x0,d0
	
	@End:
	rts
 
 UpdatePlayerPosition:
	
	move.w  #0x0,  d0	  ; Sprite ID
	move.w  gPlayerX, d1	 
	jsr     SetSpritePosX 
	
	move.w  #0x0,  d0	  ; Sprite ID
	move.w  gPlayerY, d1	 
	jsr     SetSpritePosY 
 
	rts
 
 MoveGeneral:
	; d1 - DX
	; d2 - DY
	; d3 - MirrorX
	; d4 - MirrorY
	; a0 - Sprite address (LEFT/UP)

	move.w gPlayerMovingTicks, d0
	cmp #0x0, d0
	bne @End
	
	move.w d1,i1
	move.w d2,i2
	
	move.w d3,i3
	move.w d4,i4
	
	clr.l d0
	move.w i1,d0
	mulu.w #0x10,d0
	add.w gPlayerX,d0
	move.w d0,d1
	
	clr.l d0
	move.w i2,d0
	mulu.w #0x10,d0
	add.w gPlayerY,d0
	move.w d0,d2
	
	jsr CanMoveThere
	
	cmp #0x0,d0
	beq @End	
	
	move.w #0x10, gPlayerMovingTicks
	
	move.w i1,gPlayerDX
	move.w i2,gPlayerDY
	
	move.w #0x0,gPlayerFrame
	move.w #0x2,gPlayerFrameAmount
	move.l a0, gPlayerFrameAddress
	jsr SetCurrentAnimation
    
	
	move.w #0x0, d0
	move.w i3, d1
	move.l #gPlayerSpriteSettings, a0
	jsr SetSpriteMirrorX
	
	move.w #0x0, d0
	move.w i4, d1
	move.l #gPlayerSpriteSettings, a0
	jsr SetSpriteMirrorY
	
	@End:
	rts
 
 
 MoveRight:
	move.w  #0x1, d1
	move.w  #0x0, d2
	move.w  #0x1, d3
	move.w  #0x0, d4
	lea      PLAYER_LEFT0, a0           
	jsr MoveGeneral
	
	rts
	
	
 MoveLeft:
	
	move.w  #-0x1, d1
	move.w  #0x0, d2
	move.w  #0x0, d3
	move.w  #0x0, d4
	lea      PLAYER_LEFT0, a0           
	jsr MoveGeneral
	
	rts
	
MoveDown:
	move.w  #0x0, d1
	move.w  #0x1, d2
	move.w  #0x0, d3
	move.w  #0x1, d4
	lea      PLAYER_UP0, a0          
	jsr MoveGeneral

	rts
	
	
MoveUp:
	move.w  #0x0, d1
	move.w  #-0x1, d2
	move.w  #0x0, d3
	move.w  #0x0, d4
	lea      PLAYER_UP0, a0          
	jsr MoveGeneral
	
	rts
	
	
CheckMovement:	
	move.w gPlayerMovingTicks, d1
	cmp #0x0, d1
	beq @End
	
	sub.w #0x1,d1
	move.w d1,gPlayerMovingTicks
	
	clr.l d3
	move.w #0x7,d3
	and.w d1,d3

	cmp.w #0x4,d3  ; ((x & (%00000111)) == 4)
	bne @FrameIncreaseEnd
	jsr IncreasePlayerFrame
	
	@FrameIncreaseEnd:
	
	move.w gPlayerDX,d0
	add.w d0,gPlayerX
	move.w gPlayerDY,d0
	add.w d0,gPlayerY
	jsr UpdatePlayerPosition
	
	move.w gMovingBombxID,d3
	cmp #-0x1,d3
	beq @End
	
	moveq #0x0,d0
	move.w d3,d0

	move.l #gBombxPositions,a0
	move.w d0,d3
	mulu.w #(wsize*2),d3
	add.l d3,a0
	moveq #0x0,d1
	moveq #0x0,d2
	move.w (a0)+,d1
	move.w (a0)+,d2
	add.w gPlayerDX,d1
	add.w gPlayerDY,d2
	jsr SetBombxPosition
	
	move.w gPlayerMovingTicks, d3
	cmp #0x0,d3
	bne @End

	move.l #gBombxPositions,a0
	move.w gMovingBombxID,d0
	move.w d0,d3
	mulu.w #(wsize*2),d3
	add.l d3,a0
	moveq #0x0,d1
	moveq #0x0,d2
	move.w (a0)+,d1
	move.w (a0)+,d2
	move.w d1,-(sp)
	move.w d2,-(sp)
	jsr SetBombxMapEntry
	move.w (sp)+,d2
	move.w (sp)+,d1
	
	move.w d1,-(sp)
	move.w d2,-(sp)
	jsr GetTileIDOffset
	move.w (sp)+,d2
	move.w (sp)+,d1
	
	moveq #0x0,d3
	move.w (a1),d3
	cmp #0x0,d3
	bne @BombxFinishedEnd
	
	move.w d1,-(sp)
	move.w d2,-(sp)
	sub.w #0x80,d1
	sub.w #0x80,d2
	jsr CheckIfFinishedBoxThere
	move.w (sp)+,d2
	move.w (sp)+,d1
	cmp #-0x1,d0
	bne @BombxFinishedEnd
	
	move.w d1,-(sp)
	move.w d2,-(sp)
	move.w #-0x1,d0
	jsr SetBombxMapEntry
	move.w (sp)+,d2
	move.w (sp)+,d1
	
	move.w d1,-(sp)
	move.w d2,-(sp)
	move.w gMovingBombxID,d0
	jsr SetBombxFinishedMapEntry
	move.w (sp)+,d2
	move.w (sp)+,d1
	
	move.w gMovingBombxID,d0
	jsr SetBombxInactive

	jsr DecreaseHolesLeft
	
	@BombxFinishedEnd:

	jsr UpdateBombxCountdowns
	move.w #-0x1,gMovingBombxID
	
	
	@End:
	rts
	
	
UpdatePlayerExplosion:
	clr.l d3
	move.w gPlayerExplodingTicks,d3
	cmp #0x0,d3
	beq @End

	sub.w #0x1,d3
	move.w d3,gPlayerExplodingTicks
	cmp #0x0,d3
	bne @End
	
	jsr ResetScreen
		
	@End:
	rts