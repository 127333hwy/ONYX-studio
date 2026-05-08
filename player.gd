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
		print("on_stove check: ", target.name, " | has on_stove: ", "on_stove" in target, " | value: ", target.get("on_stove"))
		if "on_stove" in target and target.on_stove:
			continue
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
	
	if "on_stove" in target:
		target.on_stove = false
	var closest_stove = _find_closest_in_group("stove")
	if closest_stove and closest_stove.has_method("on_dish_picked_up"):
		closest_stove.on_dish_picked_up()
	
func try_place():
	print("attempted to place")

	if held_item == null:
		print("Error: Held item is null")
		return

	var is_dish = held_item.is_in_group("dish")
	print("Is dish: ", is_dish, " | Item name: ", held_item.name)
	
	if is_dish:
		var closest_customer = _find_closest_in_group("customer")
		if closest_customer:
				print("SUCCESS: Delivering dish to customer ", closest_customer.name)
				deliver_to_customer(closest_customer)
				return
	var closest_trash = _find_closest_in_group("trash")
	if closest_trash:
		print("Trashing item: ", held_item.name)
		closest_trash.trash_item(held_item)
		held_item = null
		holding_item = false
		return
		
	var closest_stove = _find_closest_in_group("stove")
	if closest_stove:
		print("SUCCESS: Found stove ", closest_stove.name)
		put_in_stove(closest_stove)
	else:
		print("FAIL: Nothing in range to place item on.")
		
	
		
func put_in_stove(stove_node):
	if held_item == null:
		return
	
	if stove_node.has_method("place_item"):
		stove_node.place_item(held_item)
	
	holding_item = false
	held_item = null

	print("Player's item has been placed")

func _find_closest_in_group(group_name: String) -> Node2D:
	var nodes = get_tree().get_nodes_in_group(group_name)
	print("Searching group: ", group_name, " | Found: ", nodes.size())
	var closest = null
	var min_dist = interact_range
	for node in nodes:
		var dist = global_position.distance_to(node.global_position)
		print("  - ", node.name, " dist: ", dist, " | range: ", interact_range)
		if dist < min_dist:
			min_dist = dist
			closest = node
	return closest

func deliver_to_customer(customer_node: Node2D):
	if held_item == null:
		return
	var dish = held_item
	holding_item = false
	held_item = null
	dish.reparent(customer_node)
	dish.position = Vector2.ZERO
	dish.z_index = 0
	if dish.has_node("CollisionShape2D"):
		dish.get_node("CollisionShape2D").disabled = false
	if customer_node.has_method("receive_dish"):
		customer_node.receive_dish(dish)
	else:
		push_warning("Customer node has no receive_dish() method!")
