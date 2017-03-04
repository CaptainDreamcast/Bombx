; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

DrawTextPlaneA:
; a0 (l) - String address
; d0 (w) - First tile ID of font
; d1 (bb)- XY coord (in tiles)
; d2 (b) - Palette

	clr.l    d3                     ; Clear d3 ready to work with
	move.b   d1, d3                 ; Move Y coord (lower byte of d1) to d3
	mulu.w   #0x0040, d3            ; Multiply Y by line width (H40 mode - 64 lines horizontally) to get Y offset
	ror.l    #0x8, d1               ; Shift X coord from upper to lower byte of d1
	add.b    d1, d3                 ; Add X coord to offset
	mulu.w   #0x2, d3               ; Convert to words
	swap     d3                     ; Shift address offset to upper word
	add.l    #vdp_write_plane_a, d3 ; Add PlaneA write cmd + address
	move.l   d3, vdp_control        ; Send to VDP control port
	
	clr.l    d3                     ; Clear d3 ready to work with again
	move.b   d2, d3                 ; Move palette ID (lower byte of d2) to d3
	rol.l    #0x8, d3               ; Shift palette ID to bits 14 and 15 of d3
	rol.l    #0x5, d3               ; Can only rol bits up to 8 places in one instruction
	
	lea      ASCIIMap, a1           ; Load address of ASCII map into a1
 
	@CharCopy:
	move.b   (a0)+, d2              ; Move ASCII byte to lower byte of d2
	cmp.b    #0x0, d2               ; Test if byte is zero (string terminator)
	beq.b    @End                   ; If byte was zero, branch to end
	 
	sub.b    #ASCIIStart, d2        ; Subtract first ASCII code to get table entry index
	move.b   (a1,d2.w), d3          ; Move tile ID from table (index in lower word of d2) to lower byte of d3
	add.w    d0, d3                 ; Offset tile ID by first tile ID in font
	move.w   d3, vdp_data           ; Move palette and pattern IDs to VDP data port
	jmp      @CharCopy              ; Next character
	 
	@End:
	rts

LoadTiles:
	; a0 - Font address (l)
	; d0 - VRAM address (w)
	; d1 - Num chars (b)
	
	swap	d0						; VRAM addr in upper word
	add.l	#vdp_write_tiles, d0	; VRAM write cmd + VRAM destination address
	move.l	d0, vdp_control			; Send address to VDP cmd port
	
	subq.b	#0x1, d1				; Num chars - 1
	@CharCopy:
	move.w	#0x07, d2				; 8 longwords in tile
	@LongCopy:
	move.l	(a0)+, vdp_data			; Copy one line of tile to VDP data port
	dbra	d2, @LongCopy
	dbra	d1, @CharCopy
	
	rts
	
LoadSpriteTables:
	; a0 - Sprite data address
	; d0 - Number of sprites
	move.l	#vdp_write_sprite_table, vdp_control
	
	subq.b	#0x1, d0				; 2 sprites attributes
	@AttrCopy:
	move.l	(a0)+, vdp_data
	move.l	(a0)+, vdp_data
	dbra	d0, @AttrCopy
	
	rts

SetSpritePosX:
	; Set sprite X position
	; d0 (b) - Sprite ID
	; d1 (w) - X coord
	clr.l	d3						; Clear d3
	move.b	d0, d3					; Move sprite ID to d3
	
	mulu.w	#0x8, d3				; Sprite array offset
	add.b	#0x6, d3				; X coord offset
	swap	d3						; Move to upper word
	add.l	#vdp_write_sprite_table, d3	; Add to sprite attr table (at 0xD400)
	
	move.l	d3, vdp_control			; Set dest address
	move.w	d1, vdp_data			; Move X pos to data port
	
	rts
		
SetSpritePosY:
	; Set sprite Y position
	; d0 (b) - Sprite ID
	; d1 (w) - Y coord
	clr.l	d3						; Clear d3
	move.b	d0, d3					; Move sprite ID to d3
	
	mulu.w	#0x8, d3				; Sprite array offset
	swap	d3						; Move to upper word
	add.l	#vdp_write_sprite_table, d3	; Add to sprite attr table (at 0xD400)
	
	move.l	d3, vdp_control			; Set dest address
	move.w	d1, vdp_data			; Move X pos to data port
	
	rts
	

WaitForScreenStart:
	move.w  vdp_control, d0	; Move VDP status word to d0
	andi.w  #0x0008, d0     ; AND with bit 4 (vblank), result in status register
	bne     WaitForScreenStart ; Branch if not equal (to zero)
	rts

WaitForScreenEnd:
	move.w  vdp_control, d0	; Move VDP status word to d0
	andi.w  #0x0008, d0     ; AND with bit 4 (vblank), result in status register
	beq     WaitForScreenEnd   ; Branch if equal (to zero)
	rts

WaitFrames:
	; d0 - Number of frames to wait

	move.l  vblank_counter, d1 ; Get start vblank count

	@Wait:
	move.l  vblank_counter, d2 ; Get end vblank count
	subx.l  d1, d2             ; Calc delta, result in d2
	cmp.l   d0, d2             ; Compare with num frames
	bge     @End               ; Branch to end if greater or equal to num frames
	jmp     @Wait              ; Try again
	
	@End:
	rts