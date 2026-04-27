extends Control

@onready var dimmer: ColorRect = $Dimmer
@onready var order_name: Label = $Paper/OrderName
@onready var order_image: TextureRect = $Paper/OrderImage
@onready var ingredient_list: HBoxContainer = $Paper/IngredientList

var is_zoomed = false
var original_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_pos = self.position

func setup_ticket(food_name, dish_image, ingredient_images):
	order_name.text = food_name
	order_image.texture = dish_image
	
	for child in ingredient_list.get_children():
		child.queue_free()
	
	for img in ingredient_images:
		var icon = TextureRect.new()
		icon.texture = img
		icon.rect_min_size = Vector2(40, 40)
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ingredient_list.add_child(icon)
	


func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if not is_zoomed:
		original_pos = position
		
		var zoom_amount = 4.0  
		scale = Vector2(zoom_amount, zoom_amount)
		
		top_level = true
		z_index = 100
		
		var screen_size = get_viewport_rect().size
		global_position = (screen_size / 2) - (size * zoom_amount / 2)
		
		dimmer.show()
		is_zoomed = true
	else:
		top_level = false
		scale = Vector2(1, 1)
		position = original_pos
		z_index = 0
		dimmer.hide()
		is_zoomed = false
