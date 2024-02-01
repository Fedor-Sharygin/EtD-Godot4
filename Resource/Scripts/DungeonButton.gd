extends StaticBody2D

var SlimedPercent : float = 0.0

func _ready():
	ChangeSlimedView(0)

func ChangeSlimedView(SlimedIncrement : float):
	SlimedPercent = clamp(SlimedPercent + SlimedIncrement, 0, 1)
	$SlimedSprite.modulate.a = SlimedPercent * 255
	$SlimedTimer.start()
