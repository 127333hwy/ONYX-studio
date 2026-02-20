extends CharacterBody2D


@export var max_speed:= 600.0
@export var acceleration:=1500.0
@export var deceleration := 1200.0
@export var interact_range := 200.0

var holding_item: bool = false
var held_item: Node2D = null

func _physics_process(delta: float) -> void:
	if holding_item and held_item == null:
		print("Held item lost. Resetting.")
		holding_item = false
	var direction :=Input.get_vector("move_left","move_right","move_up","move_down")
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
	
	for item in nearby:
		if global_position.distance_to(item.global_position) < interact_range:
			pick_up(item)
			return

func pick_up(item):
	if item == null:
		return
	
	held_item = item
	holding_item = true
	
	item.reparent(self)
	item.position = Vector2(0, -40)

	print("Picked up:", item.name)

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
	
	var level = get_tree().current_scene
	held_item.reparent(level)
	held_item.global_position = global_position + Vector2(0, 80)
	
	holding_item = false
	held_item = null
	
	print("Dropped item")
		
