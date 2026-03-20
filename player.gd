extends CharacterBody2D


@export var max_speed:= 600.0
@export var acceleration:=1500.0
@export var deceleration := 1200.0
@export var interact_range := 200.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var holding_item: bool = false
var held_item: Node2D = null

func _physics_process(delta: float) -> void:
	if holding_item and held_item == null:
		print("Held item lost. Resetting.")
		holding_item = false
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	if direction.y > 0:
		animated_sprite.flip_v = false
		animated_sprite.play("full_front_walk")
	elif direction.y < 0:
		animated_sprite.play("full_back_walk")
		
	if direction.y == 0:
		animated_sprite.play("full_idle")
			
	
	var has_input_direction := direction.length()>0.0	
	if has_input_direction:
		var desired_velocity:= direction * max_speed
		velocity= velocity.move_toward(desired_velocity,acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta)
	move_and_slide()
			
	if Input.is_action_just_pressed("interact"):
		if not holding_item:
			try_pickup()
	
	if Input.is_action_just_pressed("drop_item"):
		print("DROP PRESSED")
		print("Holding:", holding_item)

	if holding_item and Input.is_action_just_pressed("drop_item"):
		print("Calling try_place()")
		try_place()
				
func try_pickup():
	var nearby = get_tree().get_nodes_in_group("ingredient")
	
	for target in nearby:
		if global_position.distance_to(target.global_position) < interact_range:
			if target.has_method("spawn_item"):
				var new_rice = target.spawn_item()
				pick_up(new_rice)
			else:
				pick_up(target)
			return

func pick_up(target):
	if target == null: return
	
	held_item = target
	holding_item = true
	
	if target.get_parent() == null:
		get_tree().current_scene.add_child(target)
	target.reparent.call_deferred(self)
	target.position = Vector2(0, -40)
	target.z_index = 1
	
func try_place():
	print("TRY PLACE CALLED")

	if held_item == null:
		print("Held item is null")
		return

	var stove = get_tree().get_first_node_in_group("stove")
	print("Stove found:", stove)

	if stove:
		var dist = global_position.distance_to(stove.global_position)
		print("Distance to stove:", dist)

		if dist < interact_range:
			print("Close enough → putting in stove")
			put_in_stove(stove)
		else:
			print("Too far → dropping")
			drop_on_floor()
	else:
		print("No stove found → dropping")
		drop_on_floor()
		
func put_in_stove(stove_node):
	if held_item == null:
		return
	
	print("Putting item in stove")
	
	if stove_node.has_method("place_item"):
		stove_node.place_item(held_item)
	
	holding_item = false
	held_item = null

func drop_on_floor():
	if held_item == null:
		return
	
	if "held" in held_item:
		held_item.held = false
	if held_item.has_node("Area2D"):
		held_item.get_node("Area2D").monitoring = true
		
	var level = get_tree().current_scene
	held_item.reparent(level)
	held_item.global_position = global_position + Vector2(0, 80)

	holding_item = false
	held_item = null
	
	print("Dropped item")
		
