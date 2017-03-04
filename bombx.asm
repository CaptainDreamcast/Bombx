; Taken in part from https://bigevilcorporation.co.uk
; So buy Tanglewood, will ya

;=================================
;MAIN game source code
;sources:
;https://bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
;https://en.wikibooks.org/wiki/Genesis_Programming#ROM_header
;http://darkdust.net/writings/megadrive/initializing
;http://mrjester.hapisan.com/04_MC68/Index.html
;http://darkdust.net/writings/megadrive/firststeps
;=================================

	;==============================
	;INCLUDES
	;==============================
	
	include 'init.asm'
	
	; include loading
	include 'draw.asm'
	include 'input.asm'
	
__main:
	
	move.w #0x8F02, vdp_control     ; Set autoincrement to 2 bytes

	; ************************************
	; Move palettes to CRAM
	; ************************************
	move.l #vdp_write_palettes, vdp_control ; Set up VDP to write to CRAM address 0x0000

	lea Palettes, a0  ; Load address of Palettes into a0
	move.l #0x0F, d0  ; 64 bytes of data (2 palettes, 16 longwords, minus 1 for counter) in palettes

	@ColourLoop:
	move.l (a0)+, vdp_data ; Move data to VDP data port, and increment source address
	dbra d0, @ColourLoop

	; ************************************
	; Load sprite tiles
	; ************************************
    lea      Sprite1, a0         ; Move sprite address to a0
    move.l   #Sprite1VRAM, d0    ; Move VRAM dest address to d0
    move.l   #Sprite1SizeT, d1   ; Move number of tiles to d1
	jsr      LoadTiles           ; Jump to subroutine
	
	lea      Sprite2, a0         ; Move sprite address to a0
    move.l   #Sprite2VRAM, d0    ; Move VRAM dest address to d0
    move.l   #Sprite2SizeT, d1   ; Move number of tiles to d1
	jsr      LoadTiles           ; Jump to subroutine
	
	; ************************************
	; Load sprite descriptors
	; ************************************
	lea     SpriteDescs, a0		; Sprite table data
	move.w  #0x2, d0			; 2 sprites
	jsr     LoadSpriteTables

	; ************************************
	; Set sprite positions
	; ************************************
	move.w  #0x0,  d0	  ; Sprite ID
	move.w  #0xB0, d1	  ; X coord
	jsr     SetSpritePosX ; Set X pos
	move.w  #0xB0, d1	  ; Y coord
	jsr     SetSpritePosY ; Set Y pos

	move.w  #0x1,  d0	  ; Sprite ID
	move.w  #0xA0, d1	  ; X coord
	jsr     SetSpritePosX ; Set X pos
	move.w  #0x90, d1	  ; Y coord
	jsr     SetSpritePosY ; Set Y pos

	move.l #0x80, d4 ;x
	move.l #0x80, d5 ;y
	
Game:
	
	jsr ReadInput
	
	move.l #0x1, d6
	
	btst    #pad_button_right, d0 ; Check right button
	bne     @NoRight              ; Branch if button off
	add.w   d6, d4                ; Increment sprite X pos
	@NoRight:
	
	btst    #pad_button_left, d0 ; Check right button
	bne     @NoLeft              ; Branch if button off
	sub.w   d6, d4                ; Increment sprite X pos
	@NoLeft:
	
	jsr WaitForScreenStart
	
	move.w  #0x0,  d0	  ; Sprite ID
	move.w  d4, d1	      ; X coord
	jsr     SetSpritePosX ; Set X pos
	move.w  d5, d1	      ; Y coord
	jsr     SetSpritePosY ; Set Y pos
	
	jsr WaitForScreenEnd
	
	jmp Game
	
SpriteDescs:
    dc.w 0x0000        ; Y coord (+ 128)
    dc.b %00001111     ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x01          ; Index of next sprite (linked list)
    dc.b 0x00          ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b Sprite1TileID ; Index of first tile
    dc.w 0x0000        ; X coord (+ 128)
	
    dc.w 0x0000        ; Y coord (+ 128)
    dc.b %00001111     ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x00          ; Index of next sprite (linked list)
    dc.b 0x20          ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b Sprite2TileID ; Index of first tile
    dc.w 0x0000        ; X coord (+ 128)
	
; Include data
	include 'data.asm'


; End of ROM
__end: