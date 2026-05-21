extends Area2D

@export var sushi_scene : PackedScene
@export var fried_rice_scene : PackedScene
@export var salad_scene : PackedScene
@export var onigiri_scene : PackedScene
@export var burnt_fried_rice_scene: PackedScene
@export var burnt_sushi_scene: PackedScene
@export var burnt_salad_scene: PackedScene
@export var burnt_onigiri_scene: PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var burn_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D2
@onready var burn_timer: Timer = $BurnTimer
@onready var cook_timer: Timer = $CookTimer
@onready var cooking_sound: AudioStreamPlayer2D = $CookingSound

var dish_picked_up: bool = false
var ingredients : Array = []
var cooking : bool = false
var player_in_range : bool = false
var current_dish_scene = null



func _ready():
	animated_sprite.play("idle")
	burn_animated_sprite.visible = false
	
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		var player = get_tree().get_first_node_in_group("player")
		
		if not player: return
		
		if not player.holding_item:
			var finished_dish = null
			for child in get_children():
				if child.is_in_group("dish"):
					finished_dish = child
					break
				
			if finished_dish != null:
				pick_up_dish(player, finished_dish)
		elif player.holding_item and !cooking:
				if !player.held_item.is_in_group("dish"):
					if ingredients.size() < 2:
						place_item(player.held_item)

func pick_up_dish(player, dish):
	var pickup_point = player.get_node("PickupPoint")
	if pickup_point:
		burn_timer.stop()
		burn_animated_sprite.stop()
		burn_animated_sprite.visible = false
		dish_picked_up = true
		dish.reparent(player)
		dish.position = pickup_point.position
		
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
	print("Cooking started")
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

func start_cooking_timer(dish_scene):
	cooking = true
	current_dish_scene = dish_scene
	animated_sprite.play("cooking")
	var start_second: float = 1.0
	cooking_sound.play(start_second)
	for item in ingredients:
		if is_instance_valid(item):
			item.queue_free()
	ingredients.clear()
	cook_timer.start(2.5)
	await cook_timer.timeout
	cooking = false
	cooking_sound.stop()
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
	dish_picked_up = false
	burn_animated_sprite.visible = true
	burn_animated_sprite.play("burn_timer_animation")
	burn_timer.start(5.5)

func _on_burn_timer_timeout():
	if dish_picked_up:
		burn_animated_sprite.visible = false
		return
	print("timer done")
	if dish_picked_up:
		burn_animated_sprite.visible = false
		return
	
	for child in get_children():
		if child.is_in_group("dish"):
			child.queue_free()
			break
	await get_tree().process_frame
	print("calling burn_all_finished")
	burn_all_finished()

func burn_all_finished():
	var energy = get_tree().get_first_node_in_group("energy")
	if energy:
		energy.remove_energy()
	for child in get_children():
		if child.is_in_group("dish"):
			return
	var burnt_scene = null
	if current_dish_scene == fried_rice_scene:
		burnt_scene = burnt_fried_rice_scene
	elif current_dish_scene == sushi_scene:
		burnt_scene = burnt_sushi_scene
	elif current_dish_scene == salad_scene:
		burnt_scene = burnt_salad_scene
	elif current_dish_scene == onigiri_scene:
		burnt_scene = burnt_onigiri_scene
	
	if burnt_scene == null:
		return
	
	var burnt = burnt_scene.instantiate()
	add_child(burnt)
	burnt.position = Vector2.ZERO
	burnt.add_to_group("dish")
	burnt.on_stove = true
	if "item_name" in burnt:
		burnt.item_name = "BurntFood"
	print("Dish has burned")
	
func on_dish_picked_up():
	burn_timer.stop()
	burn_animated_sprite.stop()
	burn_animated_sprite.visible = false
	dish_picked_up = true
	for child in get_children():
		if child.is_in_group("dish") and "on_stove" in child:
			child.on_stove = false
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
