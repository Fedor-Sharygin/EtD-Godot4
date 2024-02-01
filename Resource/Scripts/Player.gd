extends CharacterBody2D


var InputTouchEvent = null
var TouchEventJump = false
var InputHoldEventHeld : bool = false
var InputHoldEventDragged : bool = false
var InputHoldEventPos : Vector2 = Vector2.ZERO

var Gravity = 2000
var Velocity = Vector2.ZERO
var GroundAcceleration = 2000
var MaxGroundSpeed = 1200
var JumpForce = 1100
var Weight = 1.0

var CurrentPossibleIndx
var MaxIdx
@export_group("Size Parameters")
@export var StartingIdx: int
@export var PossibleScale : Array[float] # (Array, float, 0.1, 5.0, 0.05)
@export var PossibleJumpForce : Array[float] # (Array, float)
@export var PossibleWeight : Array[float] # (Array, float, 0.1, 5.0, 0.05)
@export var PossibleGroundSpeed : Array[float] # (Array, float)

@export var SlimeTrailScene: PackedScene = preload("res://Scenes/SlimeTrail.tscn")
var SlimeTrailScaleMultiplier = 4

@onready var SlimeSprite = $Visuals/AnimatedSprite2D
@onready var SlimeParticlesLeftMaterial : ParticleProcessMaterial = ($Visuals/SlimeParticlesLeft.process_material as ParticleProcessMaterial)
@onready var SlimeParticlesRightMaterial : ParticleProcessMaterial = ($Visuals/SlimeParticlesRight.process_material as ParticleProcessMaterial)

func _ready():
	$InteractionArea.connect("area_entered", Callable(self, "OnInteractionAreaEntered").bind())
	$SlimeTrailTimer.connect("timeout", Callable(self, "OnSlimeTrailTimerEnd"))
	MaxIdx = PossibleScale.size() - 1
	SetSizeParamsIdx(StartingIdx)

func _physics_process(Delta):
	ProcessMovement(Delta)
	UpdateAnimations()


func TouchEventInMoveAreas(Position : Vector2, ScreenPercent : float = 0.12) -> int:
	var EventXPos = Position.x
	var ScreenWidth = get_viewport_rect().size.x
	var ReturnVal = -1 if EventXPos < ScreenPercent * ScreenWidth else 0
	if ReturnVal == 0:
		ReturnVal = 1 if EventXPos > (1 - ScreenPercent) * ScreenWidth else 0
	return  ReturnVal

func _unhandled_input(Event):
	if Event is InputEventScreenTouch:
		if Event.is_pressed():
			if TouchEventInMoveAreas(Event.position) == 0:
				InputTouchEvent = Event
				TouchEventJump = true
			else:
				InputHoldEventHeld = true
				InputHoldEventPos = Event.position
		elif !TouchEventJump:
			InputHoldEventHeld = false
		else:
			TouchEventJump = false

func GetMoveInput():
	var MoveVector = Vector2.ZERO
	
	#Regular PC/Controller Input
	MoveVector.x = Input.get_axis("MoveLeft", "MoveRight")
	if Input.is_action_just_pressed("Jump"):
		MoveVector.y = -1 if Input.get_action_raw_strength("Jump") else 0
	
	#Mobile Input
	if MoveVector.x == 0:
		#NEED TO TEST ON FIRE TABLET
		var Gyroscope = Input.get_gyroscope()
		MoveVector.x = sin(Gyroscope.x) #possibly Gyroscope.y or Gyroscope.z
		#if there is no Gyroscope
		#hold left right side of screen
		if MoveVector.x == 0 && InputHoldEventHeld:
			MoveVector.x = TouchEventInMoveAreas(InputHoldEventPos)
	if MoveVector.y == 0 && is_instance_valid(InputTouchEvent):
		MoveVector.y = -1
		InputTouchEvent = null
	
	return MoveVector



func ProcessMovement(Delta):
	var MoveVector = GetMoveInput()
	if MoveVector.x > 0:
		$Visuals/SlimeParticlesLeft.emitting = true
		$Visuals/SlimeParticlesRight.emitting = false
	if MoveVector.x < 0:
		$Visuals/SlimeParticlesRight.emitting = true
		$Visuals/SlimeParticlesLeft.emitting = false
	if MoveVector.x == 0 || !is_on_floor():
		$Visuals/SlimeParticlesLeft.emitting = false
		$Visuals/SlimeParticlesRight.emitting = false
	
	#Ground movement
	velocity.x += MoveVector.x * GroundAcceleration * Delta
	if MoveVector.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2.0, -30 * Delta))
	velocity.x = clamp(velocity.x, -MaxGroundSpeed, MaxGroundSpeed)
	
	#Jumping
	if MoveVector.y != 0 && (is_on_floor() || !$CoyoteTimer.is_stopped()):
		velocity.y = MoveVector.y * JumpForce
		$CoyoteTimer.stop()
		$AnimationPlayer.play("Jump")
	velocity.y += Gravity * Delta
	
	var WasOnFloor = is_on_floor()
	#set_velocity(Velocity)
	#set_up_direction(Vector2.UP)
	move_and_slide()
	#Velocity = velocity
	if WasOnFloor && !is_on_floor():
		$CoyoteTimer.start()
		$SlimeTrailTimer.stop()
	if !WasOnFloor && is_on_floor():
		$AnimationPlayer.play("Land")
		$SlimeTrailTimer.start()
		SpawnSlimeTrail(1.6)

var LastFrame : bool = false
func UpdateAnimations():
	if LastFrame && SlimeSprite.frame == 0:
		LastFrame = false
		SlimeSprite.play("Airborn" if SlimeSprite.animation == "Jump" else "Move")
	
	#depending on "Jump", "Land" animations length change 3/2 to appropriate values
	if SlimeSprite.animation == "Jump" && SlimeSprite.frame == 3:
		LastFrame = true
	if SlimeSprite.animation == "Land" && SlimeSprite.frame == 2:
		LastFrame = true


func SetSizeParamsIdx(NewIdx : int):
	if CurrentPossibleIndx == NewIdx:
		return
	
	CurrentPossibleIndx = NewIdx
	CurrentPossibleIndx = min(CurrentPossibleIndx, MaxIdx)
	CurrentPossibleIndx = max(CurrentPossibleIndx, 0)
	
	scale = Vector2.ONE * PossibleScale[CurrentPossibleIndx]
	#SlimeParticlesLeftMaterial.scale = scale.x * pow(2, .5 * (StartingIdx - CurrentPossibleIndx))
	#SlimeParticlesRightMaterial.scale = scale.x * pow(2, .5 * (StartingIdx - CurrentPossibleIndx))
	$WorldViewArea/CollisionShape2D.scale = Vector2.ONE / PossibleScale[CurrentPossibleIndx]
	JumpForce = PossibleJumpForce[CurrentPossibleIndx]
	Weight = PossibleWeight[CurrentPossibleIndx]
	MaxGroundSpeed = PossibleGroundSpeed[CurrentPossibleIndx]

func OnInteractionAreaEntered(OtherArea2D) -> void:
	var OtherObject : InteractiveObject = OtherArea2D.get_parent() as InteractiveObject
	if CurrentPossibleIndx == OtherObject.PossibleIdxLimit:
		return
	
	if OtherObject.IsSizeUp:
		SetSizeParamsIdx(CurrentPossibleIndx + 1)
	else:
		SetSizeParamsIdx(CurrentPossibleIndx - 1)


func SpawnSlimeTrail(Scale : float = 1):
	Scale *= SlimeTrailScaleMultiplier
	var SlimeTrailInstance = SlimeTrailScene.instantiate()
	SlimeTrailInstance.global_position = global_position
	SlimeTrailInstance.scale = Scale * scale
	get_parent().add_child(SlimeTrailInstance)

func OnSlimeTrailTimerEnd():
	SpawnSlimeTrail()

