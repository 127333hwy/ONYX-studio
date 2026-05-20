extends Control

@onready var order_name: Label = $Paper/OrderName
@onready var order_image: TextureRect = $Paper/OrderImage
@onready var ingredient_list: HBoxContainer = $Paper/IngredientList
@onready var dimmer: ColorRect = $Paper/Dimmer

var is_zoomed = false
var original_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_zoomed = false
	top_level = false
	scale = Vector2(1, 1)
	z_index = 0
	rotation = 0
	dimmer.hide()
func setup_ticket(food_name, dish_image, ingredient_images):
	order_name.text = food_name
	order_image.texture = dish_image
	
	for child in ingredient_list.get_children():
		child.queue_free()
	
	for img in ingredient_images:
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(40, 40)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # or EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		ingredient_list.add_child(icon)
	


func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if not is_zoomed:
		original_pos = position
		
		
		top_level = true
		z_index = 100
		anchor_left = 0.5
		anchor_top = 0.5
		anchor_right = 0.5
		anchor_bottom = 0.5
		
		grow_horizontal = GrowDirection.GROW_DIRECTION_BOTH
		grow_vertical = GrowDirection.GROW_DIRECTION_BOTH
		position = Vector2.ZERO
		
		
		var zoom_amount = 4.0  
		scale = Vector2(zoom_amount, zoom_amount)
		dimmer.show()
		
		is_zoomed = true
	else:
		top_level = false
		scale = Vector2(1, 1)
		z_index = 0
		anchor_left = 0.0
		anchor_top = 0.0
		anchor_right = 0.0
		anchor_bottom = 0.0
		
		position = original_pos
		dimmer.hide()
		
		is_zoomed = false
