extends Node2D

@export_range(1, 10) var Rows : int = 1 # (int, 1, 10)
@export_range(1, 10) var Columns : int = 1 # (int, 1, 10)
@export var StartPosition : Vector2 = Vector2.ZERO

var Cell = preload("res://Scenes/WorldViewArea.tscn")
var CellSize = Vector2(1100, 550)
var CellStep = Vector2(1420, 920)


func _ready():
	for i in range(Rows):
		for j in range(Columns):
			var NewArea = Cell.instantiate()
			NewArea.ViewAreaShapeSize = CellSize
			NewArea.global_position = StartPosition + CellStep * Vector2(j, -i)
			add_child(NewArea)

