extends CharacterBody2D

@onready var StateTimer = $StateTimer
@onready var NavAgent = $NavigationAgent2D
@onready var Crumbcast = $Crumbseeker
@onready var Memory = $Memory
@export var HP = 3
@export var Speed = 50

@onready var Sprite = $ColorRect
@onready var AnimPlayer = $AnimationPlayer

#region detection stuff
var LastSeen: Vector2
var PlayerLastSeen = false
var LostSight = false
var Player: Node2D
#endregion

#region knockback and stun stuff
var Stunned = false
var StunTimer = 0
var KnockBackVelocity = Vector2.ZERO
#endregion
func _ready() -> void:
	AnimPlayer.play("RESET")
	NavAgent.target_desired_distance = 4
	Player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if !StateTimer.is_stopped():
		KnockBackVelocity = lerp(KnockBackVelocity, Vector2.ZERO, 0.1)
		velocity = KnockBackVelocity
		move_and_slide()
		return
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

func attacked(duration: float, strength: float, source_position: Vector2):
	var KnockBackDirection = source_position.direction_to(global_position)
	KnockBackVelocity = KnockBackDirection * strength
	StateTimer.start(duration)
	print("stunned")
	AnimPlayer.play("Hurt")

func meleeattack():
	velocity = Vector2.ZERO
	KnockBackVelocity = Vector2.ZERO
	StateTimer.start(0.5)
	AnimPlayer.play("Strike")

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

func _on_melee_range_detector_area_entered(area: Area2D) -> void:
	meleeattack()

func _on_memory_timeout() -> void:
	PlayerLastSeen = false
	LostSight = false

func _on_state_timer_timeout() -> void:
	KnockBackVelocity = Vector2.ZERO
