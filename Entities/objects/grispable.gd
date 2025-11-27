extends RigidBody2D

var Crumb = preload("res://Entities/Player/detection_drip.tscn")

@onready var Crumbtimber = $Crumbtimer

var IsWeapon = false
var SpeedTreshold = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if IsWeapon:
		if linear_velocity.length() < SpeedTreshold:
			IsWeapon = false
	var count = get_contact_count()
	if count > 0 and Crumbtimber.is_stopped() and linear_velocity.length() > SpeedTreshold:
		crumbs()

func crumbs():
	var DroppedCrumb = Crumb.instantiate()
	owner.add_child(DroppedCrumb)
	DroppedCrumb.global_transform = $".".global_transform
	DroppedCrumb.normal_crumb()
	Crumbtimber.start()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var Target = area.get_parent()
	if IsWeapon and Target.is_in_group("Enemy"):
		Target.attacked()
