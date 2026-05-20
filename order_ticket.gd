extends Control

@onready var order_name: Label = $Paper/OrderName
@onready var order_image: TextureRect = $Paper/OrderImage
@onready var ingredient_list: HBoxContainer = $Paper/IngredientList
@onready var dimmer: ColorRect = $Paper/Dimmer

const PIXEL_FONT = preload("res://Jersey10-Regular.ttf")

var is_zoomed = false
var zoom_layer: CanvasLayer = null
var current_food_name = ""
var current_dish_image: Texture2D = null
var current_ingredient_images: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_zoomed = false
	top_level = false
	scale = Vector2(1, 1)
	z_index = 0
	rotation = 0
	pivot_offset = Vector2.ZERO
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	order_name.add_theme_font_override("font", PIXEL_FONT)
	order_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	dimmer.hide()


func _exit_tree() -> void:
	_close_zoom()


func setup_ticket(food_name, dish_image, ingredient_images):
	current_food_name = food_name
	current_dish_image = dish_image
	current_ingredient_images = ingredient_images
	order_name.text = _format_food_name(food_name)
	order_image.texture = dish_image

	_fill_ingredient_list(ingredient_list, ingredient_images, 7, 10)


func _fill_ingredient_list(list: HBoxContainer, ingredient_images: Array, icon_size: int, slot_size: int) -> void:
	for child in list.get_children():
		child.queue_free()

	for img in ingredient_images:
		var slot = CenterContainer.new()
		slot.custom_minimum_size = Vector2(slot_size, slot_size)
		list.add_child(slot)

		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # or EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _crop_ingredient_texture(img)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slot.add_child(icon)


func _crop_ingredient_texture(texture: Texture2D) -> Texture2D:
	var crop_regions = {
		"res://assets/ingredients/Rice.png": Rect2(67, 35, 26, 26),
		"res://assets/ingredients/Fish.png": Rect2(4, 39, 24, 16),
		"res://assets/ingredients/Lettuce.png": Rect2(65, 0, 30, 29),
		"res://assets/ingredients/Meat.png": Rect2(40, 37, 18, 15)
	}

	if not crop_regions.has(texture.resource_path):
		return texture

	var cropped = AtlasTexture.new()
	cropped.atlas = texture
	cropped.region = crop_regions[texture.resource_path]
	return cropped


func _format_food_name(food_name: String) -> String:
	match food_name:
		"FriedRice":
			return "FRIED RICE"
		_:
			return food_name.to_upper()


func _on_button_pressed() -> void:
	if is_instance_valid(zoom_layer):
		_close_zoom()
	else:
		_open_zoom()


func _open_zoom() -> void:
	is_zoomed = true
	zoom_layer = CanvasLayer.new()
	zoom_layer.layer = 100
	get_tree().root.add_child(zoom_layer)

	var viewport_size = get_viewport_rect().size
	var zoom_amount = min(viewport_size.x / size.x, viewport_size.y / size.y) * 0.82
	var card = Control.new()
	card.size = size * zoom_amount
	card.position = viewport_size * 0.5 - (card.size * 0.5)
	zoom_layer.add_child(card)

	var paper_copy = $Paper.duplicate()
	paper_copy.set_anchors_preset(Control.PRESET_FULL_RECT)
	paper_copy.offset_left = 0.0
	paper_copy.offset_top = 0.0
	paper_copy.offset_right = 0.0
	paper_copy.offset_bottom = 0.0
	card.add_child(paper_copy)

	var zoom_name: Label = paper_copy.get_node("OrderName")
	zoom_name.text = _format_food_name(current_food_name)
	zoom_name.add_theme_font_override("font", PIXEL_FONT)
	zoom_name.add_theme_font_size_override("font_size", int(4 * zoom_amount))
	zoom_name.add_theme_constant_override("outline_size", int(1 * zoom_amount))

	var zoom_image: TextureRect = paper_copy.get_node("OrderImage")
	zoom_image.texture = current_dish_image
	zoom_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var zoom_ingredients: HBoxContainer = paper_copy.get_node("IngredientList")
	zoom_ingredients.hide()

	var box_positions = [
		Rect2(card.size.x * 0.275, card.size.y * 0.585, card.size.x * 0.20, card.size.y * 0.12),
		Rect2(card.size.x * 0.50, card.size.y * 0.585, card.size.x * 0.20, card.size.y * 0.12)
	]
	var icon_size = int(card.size.y * 0.085)
	for i in range(min(current_ingredient_images.size(), box_positions.size())):
		var slot = CenterContainer.new()
		slot.position = box_positions[i].position
		slot.size = box_positions[i].size
		slot.clip_contents = true
		card.add_child(slot)

		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.size = Vector2(icon_size, icon_size)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _crop_ingredient_texture(current_ingredient_images[i])
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slot.add_child(icon)

	var close_button = Button.new()
	close_button.flat = true
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	close_button.pressed.connect(_close_zoom)
	zoom_layer.add_child(close_button)


func _close_zoom() -> void:
	if is_instance_valid(zoom_layer):
		zoom_layer.queue_free()
	zoom_layer = null
	is_zoomed = false
