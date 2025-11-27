extends Area2D

@onready var AnimPlayer = $AnimationPlayer
var active

func _physics_process(delta: float) -> void:
	if active == true:
		if !AnimPlayer.is_playing():
			queue_free()
	else:
		return

func normal_crumb():
	AnimPlayer.play("NormalCrumb")
	active = true

func sneak_crumb():
	AnimPlayer.play("QuietCrumb")
	active = true
