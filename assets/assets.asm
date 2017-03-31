
; LogoScreen 
	
PixelFontVRAM:  equ 0x0000
LogoScreenVRAM:  equ PixelFontVRAM+PixelFontSizeB

LogoScreenTileID equ (LogoScreenVRAM/32)
LogoScreenTileSizeB equ (logoscreen_tiles_end-logoscreen_tiles)
LogoScreenTileSizeT equ (LogoScreenTileSizeB/32)

LogoScreenMapSizeB equ (logoscreen_map_end-logoscreen_map)
LogoScreenMapSizeW equ (LogoScreenMapSizeB/2)

; TitleScreen

PixelFontVRAM:  equ 0x0000
FlameVRAM:   equ PixelFontVRAM+PixelFontSizeB
TitleScreenVRAM: equ FlameVRAM+FlameFrameSizeB  


FlameTileID equ (FlameVRAM/32)
FlameFrameSizeB equ (flame_tiles_frame_end-flame_tiles)
FlameFrameSizeT equ (FlameFrameSizeB/32)

FlameTotalSizeB equ (flame_tiles_total_end-flame_tiles)
FlameTotalSizeT equ (FlameTotalSizeB/32)

TitleScreenTileID equ (TitleScreenVRAM/32)
TitleScreenTileSizeB equ (titlescreen_tiles_end-titlescreen_tiles)
TitleScreenTileSizeT equ (TitleScreenTileSizeB/32)

TitleScreenMapSizeB equ (titlescreen_map_end-titlescreen_map)
TitleScreenMapSizeW equ (TitleScreenMapSizeB/2)


; GameOverScreen

PixelFontVRAM:  equ 0x0000
GameOverScreenVRAM:  equ PixelFontVRAM+PixelFontSizeB

GameOverScreenTileID equ (GameOverScreenVRAM/32)
GameOverScreenTileSizeB equ (gameoverscreen_tiles_end-gameoverscreen_tiles)
GameOverScreenTileSizeT equ (GameOverScreenTileSizeB/32)

GameOverScreenMapSizeB equ (gameoverscreen_map_end-gameoverscreen_map)
GameOverScreenMapSizeW equ (GameOverScreenMapSizeB/2)

; CongratsScreen

PixelFontVRAM:  equ 0x0000
CongratsScreenVRAM:  equ PixelFontVRAM+PixelFontSizeB

CongratsScreenTileID equ (CongratsScreenVRAM/32)
CongratsScreenTileSizeB equ (congratsscreen_tiles_end-congratsscreen_tiles)
CongratsScreenTileSizeT equ (CongratsScreenTileSizeB/32)

CongratsScreenMapSizeB equ (congratsscreen_map_end-congratsscreen_map)
CongratsScreenMapSizeW equ (CongratsScreenMapSizeB/2)


; GameScreen

PixelFontVRAM:  equ 0x0000
BGVRAM:  equ PixelFontVRAM+PixelFontSizeB
PlayerVRAM: equ BGVRAM+BGTileSizeB
BombxIdleVRAM: equ PlayerVRAM+PlayerFrameSizeB
BombxInactiveVRAM: equ BombxIdleVRAM+BombxFrameSizeB
NumberVRAM: equ BombxInactiveVRAM+BombxFrameSizeB ; 10 frames
BombxExplodeVRAM: equ NumberVRAM+(NumberFrameSizeB*10) ; 2 frames


BGTileID equ (BGVRAM/32)
BGTileSizeB equ (BG_tiles_end-BG_tiles)
BGTileSizeT equ (BGTileSizeB/32)

BGMapSizeB equ (level1_fieldA_end-level1_fieldA)
BGMapSizeW equ (BGMapSizeB/2)

PlayerTileID equ (PlayerVRAM/32)
PlayerFrameSizeB equ PLAYER_UP0_end-PLAYER_UP0
PlayerFrameSizeT equ (PlayerFrameSizeB/32)

BombxIdleTileID equ (BombxIdleVRAM/32)
BombxInactiveTileID equ (BombxInactiveVRAM/32)
BombxExplodeTileID equ (BombxExplodeVRAM/32)

BombxFrameSizeB equ PlayerFrameSizeB
BombxFrameSizeT equ (BombxFrameSizeB/32)

NumberTileIDStart equ (NumberVRAM/32)
NumberFrameSizeB equ (NUMBER_1_END-NUMBER_TILES)
NumberFrameSizeT equ (NumberFrameSizeB/32)
NumberTotalSizeT equ (NumberFrameSizeT*10)




    include 'assets\fonts\pixelfont.asm'
	include 'assets\sprites\logoscreen.asm'
	include 'assets\sprites\BG.asm'
	include 'assets\sprites\congratsscreen.asm'	
	include 'assets\sprites\gameoverscreen.asm'
	include 'assets\sprites\titlescreen.asm'
	
	include 'assets\sprites\level1.asm'
	include 'assets\sprites\level3.asm'
	include 'assets\sprites\level4.asm'
	include 'assets\sprites\level5.asm'
	include 'assets\sprites\level6.asm'
	include 'assets\sprites\level7.asm'
	include 'assets\sprites\level8.asm'
	include 'assets\sprites\level9.asm'	
	include 'assets\sprites\level10.asm'
	include 'assets\sprites\level11.asm'
	include 'assets\sprites\level12.asm'
	include 'assets\sprites\level13.asm'	
	include 'assets\sprites\level14.asm'
	include 'assets\sprites\level15.asm'
	include 'assets\sprites\level16.asm'
	include 'assets\sprites\level17.asm'	
	include 'assets\sprites\level18.asm'
	include 'assets\sprites\level19.asm'
	include 'assets\sprites\level20.asm'
	include 'assets\sprites\level21.asm'	
	include 'assets\sprites\level22.asm'	
	include 'assets\sprites\level23.asm'
	include 'assets\sprites\level24.asm'
	include 'assets\sprites\level25.asm'	
	include 'assets\sprites\level26.asm'
	include 'assets\sprites\level27.asm'
	include 'assets\sprites\level28.asm'
	include 'assets\sprites\level29.asm'
	include 'assets\sprites\level30.asm'	
	include 'assets\sprites\level31.asm'
	include 'assets\sprites\level32.asm'	
	include 'assets\sprites\level33.asm'	
	include 'assets\sprites\level34.asm'	
	include 'assets\sprites\level35.asm'	
	include 'assets\sprites\level36.asm'	
	include 'assets\sprites\level37.asm'
	include 'assets\sprites\level38.asm'
	include 'assets\sprites\level39.asm'
	include 'assets\sprites\level40.asm'
	
	include 'assets\sprites\PLAYER_UP0.asm'
	include 'assets\sprites\PLAYER_EXPLODE_UP.asm'
	include 'assets\sprites\PLAYER_LEFT0.asm'
	include 'assets\sprites\PLAYER_EXPLODE_LEFT.asm'
	include 'assets\sprites\BOMBX.asm'
	include 'assets\sprites\NUMBERS.asm'
	include 'assets\sprites\FLAME.asm'
		
	

    include 'assets\palettes\logoscreen.asm'
	include 'assets\palettes\gamescreen.asm'
	include 'assets\palettes\titlescreen.asm'
	include 'assets\palettes\gameoverscreen.asm'
	include 'assets\palettes\congratsscreen.asm'