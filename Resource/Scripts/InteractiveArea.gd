class_name InteractiveObject extends Node2D

@export var IsSizeUp: bool = true
@export_range(0, 10) var PossibleIdxLimit : int # (int, 0, 10)

signal InteractionAreaEntered

func _ready():
	$InteractionArea.connect("area_entered", Callable(self, "OnAreaEntered"))

func OnAreaEntered(_OtherArea2D):
	emit_signal("InteractionAreaEntered")

