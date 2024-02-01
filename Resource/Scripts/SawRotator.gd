extends Sprite2D

@export var RotationSpeed: float = 120

var StainedSawSprite : Texture2D = preload("res://Assets/Saw/saw_stained.png")

func _ready():
	get_parent().connect("InteractionAreaEntered", Callable(self, "OnSawTouched"))

func _process(Delta):
	rotate(deg_to_rad(RotationSpeed * Delta))

func OnSawTouched():
	texture = StainedSawSprite

