extends Camera2D

var CurrentPosition = Vector2.ZERO

#func _ready():
	#var WorldAreas = get_tree().get_nodes_in_group("WorldArea")
	#for WorldArea in WorldAreas:
	#	WorldArea.connect("WorldAreaEntered", self, "OnWorldAreaEntered", [], CONNECT_DEFERRED)

func _process(Delta):
	if global_position != CurrentPosition:
		global_position = lerp(CurrentPosition, global_position, pow(2, -4 * Delta))

func OnWorldAreaEntered(WorldViewAreaHit : WorldViewArea):
	if is_instance_valid(WorldViewAreaHit):
		CurrentPosition = WorldViewAreaHit.global_position
