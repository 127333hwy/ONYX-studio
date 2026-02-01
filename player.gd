extends CharacterBody2D


@export var max_speed:= 600.0
@export var acceleration:=2000.0
@export var deceleration := 1080.0

func _physics_process(delta: float) -> void:
	var direction :=Input.get_vector("move_left","move_right","move_up","move_down")
	var has_input_direction := direction.length()>0.0	
	if has_input_direction:
		var desired_velocity:= direction * max_speed
		velocity= velocity.move_toward(desired_velocity,acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta)
	move_and_slide()

var holding_item := false
