extends Node2D

@export var customer_scene : PackedScene


func _on_timer_timeout() -> void:
	print("Timer triggered")
	spawn_customer()
	
func spawn_customer():
	var target_table = get_nearest_empty_table()
	
	if target_table == null:
		print("Restaurant is full!")
		return
	
	var customer = customer_scene.instantiate()
	add_child(customer)
	
	customer.global_position = get_tree().root.find_child("SpawnPoint", true, false).global_position
	#customer.exit_position =get_tree().root.find_child("SpawnPoint", true, false).global_position
	
	customer.my_table = target_table
	target_table.occupied = true
	
	customer.set_target(target_table.global_position)	
func get_nearest_empty_table():
	var all_tables = get_tree().get_nodes_in_group("tables")
	
	for table in all_tables:
		if not table.occupied:
			return table
	return null
