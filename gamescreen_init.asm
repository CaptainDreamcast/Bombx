; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

ClearGeneralMap:
	; a0 - map
	
	moveq #0x0, d0
	move.w #(row_amount*column_amount),d0
	moveq #0x0,d1
	move.w #-0x1,d1
	jsr ClearW
	rts
	
ClearBombxMap:
	move.l #gBombxMap,a0
	jsr ClearGeneralMap
	
	rts
	
ClearBombxFinishedMap:
	move.l #gBombxFinishedMap,a0
	jsr ClearGeneralMap
	
	rts
	
ClearBombxArrays:
	move.l #gBombxPositions,a0
	moveq #0x0, d0
	move.w #(box_amount*2),d0
	moveq #0x0,d1
	move.w #0x0,d1
	jsr ClearW
	
	move.l #gBombxState,a0
	moveq #0x0, d0
	move.w #(box_amount),d0
	moveq #0x0,d1
	jsr ClearW
	
	move.l #gBombxNumber,a0
	moveq #0x0, d0
	move.w #(box_amount),d0
	moveq #0x0,d1
	jsr ClearW
	
	move.l #gBombxAnimationTicks,a0
	moveq #0x0, d0
	move.w #(box_amount),d0
	moveq #0x0,d1
	jsr ClearW
	
	rts

GameScreenInit:

	move.w #0x1, gScreenStatus

	move.w  #0x90, gPlayerX
	move.w  #0x90, gPlayerY
	move.b  #(%00100000), gPlayerSpriteSettings
	move.b  #PlayerTileID, gPlayerSpriteTileID
	move.w #0x0, gPlayerMovingTicks
	move.w #0x0, gPlayerDX
	move.w #0x0, gPlayerDY
	move.w #0x0, gPlayerExplodingTicks
	
	move.l #PLAYER_UP0, gPlayerFrameAddress
	move.w #0x1, gPlayerFrameAmount
	move.w #0x0, gPlayerFrame

	jsr ClearBombxMap
	jsr ClearBombxFinishedMap
	jsr ClearBombxArrays
	move.w #-0x1,gMovingBombxID
	
	rts