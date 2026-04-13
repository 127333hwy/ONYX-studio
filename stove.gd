extends Area2D

@export var sushi_scene : PackedScene
@export var fried_rice_scene : PackedScene
@export var salad_scene : PackedScene
@export var onigiri_scene : PackedScene
@export var burnt_sushi_scene : PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var ingredients : Array = []
var cooking : bool = false
var player_in_range : bool = false

@onready var cook_timer: Timer = $CookTimer

func _ready():
	animated_sprite.play("idle")
	
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		var player = get_tree().get_first_node_in_group("player")
		if not player: return
		
		var stove_has_dish = false
		for child in get_children():
			if child.is_in_group("dish"):
				stove_has_dish = true
				break
		var player_holding_finished_dish = false
		if player.holding_item and player.held_item and player.held_item.is_in_group("dish"):
			player_holding_finished_dish = true
			
		if stove_has_dish or player_holding_finished_dish:
			return
			
		if player and player.holding_item and !cooking:
			if ingredients.size() < 2:
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
	cook_timer.start(3.0)
	
	

func check_recipe():
	var names = []
	for item in ingredients:
		if "item_name" in item:
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
		start_cooking_timer(recipes[key])
		print("fail: recipe found")
	else:
		print("failed")
		burn_all()

func start_cooking_timer(dish_scene):
	cooking = true
	animated_sprite.play("cooking")
	for item in ingredients:
		item.queue_free()
	ingredients.clear()
	
	cook_timer.start(5.0)
	await cook_timer.timeout
	
	cooking = false
	animated_sprite.play("idle")
	spawn_finished_dish(dish_scene)
	
func spawn_finished_dish(dish_scene):
	if dish_scene == null: 
		return
	var finished_dish = dish_scene.instantiate()
	add_child(finished_dish)
	finished_dish.position = Vector2.ZERO
	
	finished_dish.visible = true
	finished_dish.z_index = 5
	finished_dish.add_to_group("dish")

	print("Created dish! Ready for pickup.")
	
	if !"item_name" in finished_dish:
		finished_dish.set("item_name", "FinishedDish")
	
func burn_all():
	print("Ingredients burned!")
	for item in ingredients:
			item.queue_free()
	ingredients.clear()
	
	var trash = burnt_sushi_scene.instantiate()
	add_child(trash)
	trash.position = Vector2.ZERO
	
	trash.add_to_group("dish")
	if "item_name" in trash:
		trash.item_name = "BurntFood"
	
	cooking = false
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		
