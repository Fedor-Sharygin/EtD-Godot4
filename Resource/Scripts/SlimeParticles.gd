extends GPUParticles2D

@export var SlimeDirection : Vector2

func _ready():
	process_material.set("direction", SlimeDirection)
