extends Area2D

@export var burger_scene : PackedScene
@export var ricebowl_scene : PackedScene

var ingredients : Array = []
var cooking : bool = false
var player_in_range : bool = false

@onready var cook_timer: Timer = $CookTimer


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		var player = get_tree().get_first_node_in_group("player")
		if player and player.holding_item:
			place_item(player)

func place_item(item_to_add):
	if cooking:
		return
	ingredients.append(item_to_add)
	item_to_add.reparent(self)
	item_to_add.position = Vector2.ZERO
	
	if ingredients.size() >= 2:
		start_cooking()
	print("Stove detected item")
	
func start_cooking():
	cooking = true
	print("Cooking started...")
	cook_timer.start(5.0)
	

func check_recipe():
	var names = []
	for item in ingredients:
		names.append(item.item_name)
	names.sort()
	var key = ",".join(names)
	
	var recipes = {
		"Meat,Rice": ricebowl_scene,
		"Lettuce,Meat": burger_scene
	}
	if recipes.has(key):
		make_dish(recipes[key])
	else:
		burn_all()

func make_dish(dish_scene):
	print("Created dish!")
	for item in ingredients:
		item.queue_free()
	ingredients.clear()
	
	var finished_dish = dish_scene.instantiate()
	add_child(finished_dish)
	finished_dish.position = Vector2.ZERO
	
	cooking = false

func burn_all():
	print("Ingredients burned!")
	for item in ingredients:
		if item.has_method("become_burned"):
			item.become_burned()
		else:
			item.modulate = Color(0.1, 0.1, 0.1)
	ingredients.clear()
	cooking = false
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		
