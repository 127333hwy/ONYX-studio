extends Area2D

var ingredients : Array = []
var cooking : bool = false

@onready var cook_timer: Timer = $CookTimer

func place_item(item):
	if cooking:
		return
	ingredients.append(item.item_name)
	item.reparent(item.item_name)
	item.position = Vector2.ZERO
	if ingredients.size() >= 2:
		start_cooking()
	print("Stove received item")

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
		"Meat,Rice": "RiceBowl",
		"Lettuce,Meat": "Burger"
	}
	if recipes.has(key):
		make_dish(recipes[names])
	else:
		burn_all()

func make_dish(result_name):
	print("Created dish:", result_name)
	for item in ingredients:
		item.queue_free()
	ingredients.clear()
	cooking = false

func burn_all():
	print("Ingredients burned!")
	for item in ingredients:
		if item.has_method("become_burned"):
			item.become_burned()
		else:
			item.modulate = Color(0.1, 0.1, 0.1) #
	ingredients.clear()
	cooking = false
	


func _on_cook_timer_timeout() -> void:
	check_recipe()
