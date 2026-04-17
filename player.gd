extends CharacterBody2D


@export var max_speed:= 600.0
@export var acceleration:=1500.0
@export var deceleration := 1200.0
@export var interact_range := 150.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var holding_item: bool = false
var held_item: Node2D = null
@onready var pickup_point = $PickupPoint

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
	print("trying to pickup")
	var nearby = get_tree().get_nodes_in_group("ingredient") + get_tree().get_nodes_in_group("dish")
	
	var closest_target = null
	var shortest_distance = interact_range
	
	for target in nearby:
		var dist = global_position.distance_to(target.global_position)
		print("Target: ", target.name, " | Dist: ", dist, " | Range: ", interact_range)
		
		if dist < shortest_distance:
			shortest_distance = dist
			closest_target = target
			print("SUCCESS: Picking up ", target.name)
			
	if closest_target:
		print("SUCCESS: Picking up the closest item: ", closest_target.name)
		if closest_target.has_method("spawn_item"):
			pick_up(closest_target.spawn_item())
		else:
			pick_up(closest_target)
	else:
		print("nothing nearby")
	
func pick_up(target):
	if target == null: return
	
	held_item = target
	holding_item = true
	
	target.reparent(self)
	
	target.position = pickup_point.position
	
	target.visible = true
	target.z_index = 30
	print("item visible at", target.global_position)
	
	if target.has_node("CollisionShape2D"):
		target.get_node("CollisionShape2D").disabled = true
	
func try_place():
	print("attempted to place")

	if held_item == null:
		print("Error: Held item is null")
		return

	var all_stoves = get_tree().get_nodes_in_group("stove")
	
	print("Stoves detected: ", all_stoves.size())
	
	var closest_stove = null
	var min_dist = interact_range
	
	for stove in all_stoves:
		var dist = global_position.distance_to(stove.global_position)
		
		print("Checking ", stove.name, " | Dist: ", dist, " | Max Range: ", interact_range)
		if dist < min_dist:
			min_dist = dist
			closest_stove = stove

	if closest_stove:
			print("SUCCESS: Found stove ", closest_stove.name)
			put_in_stove(closest_stove)
	else:
			print("FAIL: No stove found within range.")
		
func put_in_stove(stove_node):
	if held_item == null:
		return
	
	if stove_node.has_method("place_item"):
		stove_node.place_item(held_item)
	
	holding_item = false
	held_item = null

	print("Player's item has been placed")
	

	
