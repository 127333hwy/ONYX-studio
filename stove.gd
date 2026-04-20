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
		
		if Input.is_action_just_pressed("pickup"):
			var finished_dish = null
			for child in get_children():
				if child.is_in_group("dish"):
					finished_dish = child
					break
				
			if finished_dish != null and not player.holding_item:
				pick_up_dish(player, finished_dish)
		elif Input.is_action_just_pressed("drop_item"):
			if player.held_item and player.holding_item and !cooking:
				if !player.held_item.is_in_group("dish"):
					if ingredients.size() < 2:
						place_item(player.held_item)

func pick_up_dish(player, dish):
	var pickup_point = player.get_node("PickupPoint")
	if pickup_point:
		dish.reparent(pickup_point)
		dish.position = Vector2.ZERO
		
		player.holding_item = true
		player.held_item = dish
		
func place_item(item_to_add):
	if cooking:
		return
	ingredients.append(item_to_add)
	item_to_add.reparent(self)
	item_to_add.position = Vector2.ZERO
	item_to_add.visible = true
	item_to_add.z_index = 1
	
	print("Stove added: ", item_to_add.item_name)
		
	if ingredients.size() >= 2:
		check_recipe()

	
func start_cooking():
	cooking = true
	print("Cooking started...")
	cook_timer.start(2.5)

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
		item.visible = false
		item.queue_free()
	ingredients.clear()
	
	cook_timer.start(2.5)
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
	finished_dish.add_to_group("dish")
	
	if dish_scene == fried_rice_scene:
		finished_dish.item_name = "FriedRice"
	elif dish_scene == sushi_scene:
		finished_dish.item_name = "Sushi"
	elif dish_scene == salad_scene:
		finished_dish.item_name = "Salad"
	elif dish_scene == onigiri_scene:
		finished_dish.item_name = "Onigiri"
		
	print("Created dish! Ready for pickup.")

	
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
		
