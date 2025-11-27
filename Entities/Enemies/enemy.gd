extends CharacterBody2D

@onready var NavAgent = $NavigationAgent2D
@onready var Crumbcast = $Crumbseeker
@onready var Memory = $Memory
@export var HP = 3
@export var Speed = 100
var LastSeen: Vector2
var PlayerLastSeen = false
var LostSight = false
var Player: Node2D

func _ready() -> void:
	NavAgent.target_desired_distance = 4
	Player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	seek_out_target()


func seek_out_target():
	if PlayerLastSeen == true:
		NavAgent.target_position = LastSeen
	elif LostSight == true:
		LastSeen = Player.global_position
		NavAgent.target_position = LastSeen
		
	
	if NavAgent.is_navigation_finished():
		if PlayerLastSeen == true:
			LostSight = true
			print("player lost, switching...")
			PlayerLastSeen = false
			if Memory.is_stopped():
				Memory.start()
		return
		
	#if PlayerLastSeen == true or LostSight == true:
	var CurrentPosition: Vector2 = global_position
	var NextPathPosition = NavAgent.get_next_path_position()
	var Direction = CurrentPosition.direction_to(NextPathPosition)
	
	velocity = Direction * Speed
	
	move_and_slide()

func attacked():
	if !HP <= 1:
		HP -= 1
	else:
		queue_free()


func _on_the_crumb_snifferr_area_entered(area: Area2D) -> void:
	var TargetPosition = area.global_position
	var LocalTarget = Crumbcast.to_local(TargetPosition)
	Crumbcast.target_position = LocalTarget
	Crumbcast.force_raycast_update()
	
	if Crumbcast.is_colliding():
		var target = Crumbcast.get_collider()
		if target.is_in_group("Player"):
			LastSeen = area.global_position
			PlayerLastSeen = true
			print("player found!")


func _on_memory_timeout() -> void:
	print("memory ran out, stalking stopped")
	PlayerLastSeen = false
	LostSight = false
