
LevelMap:
	dc.l Level1
	dc.l Level24
	
	dc.l Level1
	dc.l Level40
	dc.l Level39
	dc.l Level38
	dc.l Level37
	dc.l Level36
	dc.l Level35
	dc.l Level34
	dc.l Level33
	dc.l Level32
	dc.l Level31	
	dc.l Level30
	dc.l Level29
	dc.l Level28
	dc.l Level27
	dc.l Level26
	dc.l Level25
	dc.l Level24
	dc.l Level23
	dc.l Level22
	dc.l Level21
	dc.l Level20
	dc.l Level19
	dc.l Level18
	dc.l Level17
	dc.l Level16
	dc.l Level15
	dc.l Level14
	dc.l Level13
	dc.l Level12
	dc.l Level11
	dc.l Level10
	dc.l Level9
	dc.l Level8
	dc.l Level7
	dc.l Level6
	dc.l Level5
	dc.l Level4
	dc.l Level3
	dc.l Level2
LevelMapEnd:
	
level_amount equ ((LevelMapEnd-LevelMap)/lsize)
final_level equ (level_amount-1)
 