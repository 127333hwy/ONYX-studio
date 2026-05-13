extends CharacterBody2D


@export var speed:float = 120
@export var possible_orders: Array[String] = ["FriedRice","Salad","Sushi","Onigiri"]
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var order_images: Dictionary = {
	"FriedRice": preload("res://Fried_rice.tres"),
	"Onigiri": preload("res://Onigiri.tres"),
	"Sushi": preload("res://Sushi.tres"),
	"Salad": preload ("res://Salad.tres") }
	
var target_position: Vector2 = Vector2(-9999, 9999)
var exit_position: Vector2 = Vector2.ZERO

var order_name: String = ""
var arrived: bool = false
var leaving: bool = false
var at_table: bool = false

var my_table = null

@onready var bubble_bg: TextureRect = $Bubble/BubbleBG
@onready var food_icon: TextureRect = $"Bubble/BubbleBG/Food Icon"

func _ready() -> void:
	handle_arrival()
	show_bubble()
	
func set_target(pos:Vector2):
	target_position = pos
	arrived = false

func generate_order():
	order_name = possible_orders.pick_random()
	print(order_name)
	show_bubble()

func show_bubble():
	if order_images.has(order_name):
		food_icon.texture = order_images[order_name]
		bubble_bg.visible = true
	else:
		print("Error: No image found for ", order_name)
func leave_resturant():
	leaving = true
	arrived = false
	
	if my_table != null:
		my_table.occupied = false
		my_table.customer_ref = null
		
	animated_sprite_2d.play("leaving")
	set_target(exit_position)

func _physics_process(_delta: float) -> void:
	if arrived:
		return
	if target_position == Vector2.ZERO:
		return
	
	var direction = target_position - global_position
		
	if direction.length() > 1:
		velocity = direction.normalized() * speed
		move_and_slide()
	
		if animated_sprite_2d.animation!= "walking":
				animated_sprite_2d.play("walking")
	else: 
		handle_arrival()

func handle_arrival(): 
	arrived = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("idle")
	if leaving:
		queue_free()
	else:
		if my_table != null:
			my_table.customer_ref = self
		at_table = true
		generate_order()
		
		
func receive_dish(dish_node):
	print("dish_name: ", dish_node.get("item_name"), " | order_name: ", order_name)
	var dish_name = dish_node.name
	print("comparing: '", dish_name, "' == '", order_name, "'")
	if dish_name == order_name:
		animated_sprite_2d.play("happy")
		print("Correct dish!")
		$Bubble.visible = false
		dish_node.z_index = 1
		await get_tree().create_timer(4.0).timeout
		if dish_node != null:
			dish_node.queue_free()
		leave_resturant()
	else:
		print("Wrong dish!")
		dish_node.queue_free()
		
	print("dish_name: ", dish_node.get("item_name"), " | order_name: ", order_name)
