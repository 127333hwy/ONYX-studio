extends Area2D

@export var sushi_scene : PackedScene
@export var fried_rice_scene : PackedScene
@export var salad_scene : PackedScene
@export var onigiri_scene : PackedScene
@export var burnt_sushi_scene : PackedScene

var ingredients : Array = []
var cooking : bool = false
var player_in_range : bool = false

@onready var cook_timer: Timer = $CookTimer


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		var player = get_tree().get_first_node_in_group("player")
		if player and player.holding_item:
			place_item(player.held_item)

func place_item(item_to_add):
	if cooking:
		return
	ingredients.append(item_to_add)
	item_to_add.reparent(self)
	item_to_add.position = Vector2.ZERO
	item_to_add.visible = false
	
	print("Stove added: ", item_to_add.item_name)
		
	if ingredients.size() >= 2:
		check_recipe()

	
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
	
	print("STOVE DEBUG: Current Key is ['" + key + "']")
	
	var recipes = {
		"Meat,Rice": fried_rice_scene,
		"Rice,Meat": fried_rice_scene,
		"Rice,Fish": sushi_scene,
		"Fish,Rice": sushi_scene,
		"Lettuce,Meat": salad_scene,
		"Meat,Lettuce": salad_scene,
		"Rice,Lettuce": onigiri_scene,
		"Lettuce,Rice": onigiri_scene
	}
	if recipes.has(key):
		make_dish(recipes[key])
		print("fail: recipe found")
	else:
		print("failed")
		burn_all()

func make_dish(dish_scene):
	
	var finished_dish = dish_scene.instantiate()
	add_child(finished_dish)
	finished_dish.position = Vector2.ZERO
	
	finished_dish.add_to_group("ingredient")
	print("Created dish! Ready for pickup.")
	if !"item_name" in finished_dish:
		finished_dish.set("item_name", "RiceBowl")
	
func burn_all():
	print("Ingredients burned!")
	for item in ingredients:
			item.queue_free()
	ingredients.clear()
	
	var trash = burnt_sushi_scene.instantiate()
	add_child(trash)
	trash.position = Vector2.ZERO
	
	trash.add_to_group("ingredient")
	if "item_name" in trash:
		trash.item_name = "BurntFood"
	
	cooking = false
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		
