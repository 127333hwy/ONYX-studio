extends CharacterBody2D


@export var max_speed:= 600.0
@export var acceleration:=1500.0
@export var deceleration := 1200.0

func _physics_process(delta: float) -> void:
	var direction :=Input.get_vector("move_left","move_right","move_up","move_down")
	var has_input_direction := direction.length()>0.0	
	if has_input_direction:
		var desired_velocity:= direction * max_speed
		velocity= velocity.move_toward(desired_velocity,acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta)
	move_and_slide()
	
	if holding_item:
		var stove = get_tree().get_first_node_in_group("stove")
		if stove:
			stove.place_item(held_item)
			holding_item = false
			
	if holding_item and Input.is_action_just_pressed("drop_item"):
		drop_held_item()
		
func drop_held_item():

var holding_item := false
var held_item = null

	
