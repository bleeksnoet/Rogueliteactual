extends CharacterBody2D

var Crumb = preload("res://Entities/Player/detection_drip.tscn")

@onready var TrinketCompass = $"Trinket compass"
@onready var TrinketCompassSprite = $"Trinket compass/CompassSprite"
@onready var Crumbtimer = $Crumbtimer
@onready var CrumbMarker = $CrumbMarker

@export var NormalSpeed = 150 #pixels per second
@export var SneakSpeed = 75
var Speed = 150 #p/s

var Clicked = false
var GrispedObject = null

func _ready() -> void:
	TrinketCompassSprite.set_modulate(Color(255,255,255,0))
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	player_movement()
	grabbing_system()
	compass_system()
	
	if Input.is_action_just_pressed("Grab"):
		if !Clicked and GrispedObject != null:
			Clicked = true
			GrispedObject.freeze = true
		elif Clicked and GrispedObject != null:
			GrispedObject.freeze = false
			Clicked = false
	
	if Input.is_action_just_pressed("Chuck") and Clicked == true:
		if GrispedObject != null:
			GrispedObject.freeze = false
			Clicked = false
		
			var force = 400
			var direction = (get_global_mouse_position() - GrispedObject.global_position).normalized()
			GrispedObject.apply_impulse(direction * force)
			GrispedObject.IsWeapon = true
		return
	
	move_and_slide()

func player_movement():
	var Direction = Input.get_vector("West","East","North","South")
	velocity = Direction * Speed
	
	if velocity.length() > 0 and Crumbtimer.is_stopped():
		crumb_system()

	
	$"Arm control".look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("sneak"):
		Speed = SneakSpeed
		TrinketCompassSprite.set_modulate(Color(1.0, 1.0, 1.0, 0.294))
	if Input.is_action_just_released("sneak"):
		Speed = NormalSpeed
		TrinketCompassSprite.set_modulate(Color(1,1,1,0))

func grabbing_system():
	if Clicked == true and GrispedObject != null:
		GrispedObject.global_position = $"Arm control/Marker2D".global_position

func compass_system():
	var TrinketInRoom = get_tree().get_nodes_in_group("Trinket")
	if TrinketInRoom.is_empty():
		return
	var Target = TrinketInRoom[0]
	TrinketCompass.look_at(Target.global_position)

func crumb_system():
	var CrumbsDropped = Crumb.instantiate()
	owner.add_child(CrumbsDropped)
	CrumbsDropped.global_transform = CrumbMarker.global_transform
	
	if Input.is_action_pressed("sneak"):
		CrumbsDropped.sneak_crumb()
	else:
		CrumbsDropped.normal_crumb()
	Crumbtimer.start()

func _on_handbox_area_entered(area: Area2D) -> void:
	GrispedObject = area.get_parent()

@warning_ignore("unused_parameter")
func _on_handbox_area_exited(area: Area2D) -> void:
	if GrispedObject != null and Clicked == false:
		GrispedObject = null
