extends Node2D

var ingredients : Array = []
var cooking : bool = false

@onready var cook_timer = $CookTimer

func place_item(item):
	if cooking:
		return
	ingredients.append(item)
	item.reparent(%PlacePoint)
	item.position = Vector2.ZERO
	if ingredients.size() >= 2:
		start_cooking()
		

	item.reparent($PlacePoint)
	item.position = Vector2.ZERO

func start_cooking():
	cooking = true
	cook_timer.start()
	
func _on_CookTimer_timeout():
	check_recipe()

func check_recipe():
	var names = []
	for item in ingredients:
		names.append(item.item_name)
	names.sort()
	var recipes = {
	["Meat","Rice"]: "RiceBowl",
	["Meat","Lettuce"]: "Burger"
		}
	if recipes.has(names):
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
		item.become_burned()
	ingredients.clear()
	cooking = false
	
