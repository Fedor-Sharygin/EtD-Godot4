class_name WorldViewArea extends Node2D

signal WorldAreaEntered

@export var ViewAreaShapeSize: Vector2

@onready var ViewArea = $Area2D
@onready var RectShape = $Area2D/CollisionShape2D

func _ready():
	var AreaRectShape = RectangleShape2D.new()
	AreaRectShape.size = ViewAreaShapeSize
	RectShape.shape = AreaRectShape
	ViewArea.connect("area_entered", Callable(self, "OnAreaEntered").bind(), CONNECT_DEFERRED)

	var GameCameras = get_tree().get_nodes_in_group("GameCamera")
	if !GameCameras.is_empty():
		connect("WorldAreaEntered", Callable(GameCameras[0], "OnWorldAreaEntered").bind(), CONNECT_DEFERRED)

func OnAreaEntered(_OtherArea2D):
	emit_signal("WorldAreaEntered", self)

