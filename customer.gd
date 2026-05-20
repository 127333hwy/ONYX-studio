extends CharacterBody2D

@export var speed:float = 120
@export var patience_time: float = 20.0
@export var angry_energy_penalty: int = 1
@export var possible_orders: Array[String] = ["FriedRice","Salad","Sushi","Onigiri"]
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var order_images: Dictionary = {
	"FriedRice": preload("res://Fried_rice.tres"),
	"Onigiri": preload("res://Onigiri.tres"),
	"Sushi": preload("res://Sushi.tres"),
	"Salad": preload ("res://Salad.tres") }
	
var target_position: Vector2 = Vector2(-9999, 9999)
var exit_position: Vector2 = Vector2.ZERO
var order_generated:bool = false
var order_name: String = ""
var arrived: bool = false
var leaving: bool = false
var at_table: bool = false
var patience_left: float = 0.0
var patience_expired: bool = false
var served_successfully: bool = false

var my_table = null

@onready var bubble_bg: TextureRect = $Bubble/BubbleBG
@onready var food_icon: TextureRect = $"Bubble/BubbleBG/Food Icon"
@onready var customer_timer: Sprite2D = $CustomerTimer

func _ready() -> void:
	patience_left = patience_time
	update_customer_timer()
	$Bubble.visible = false
	
func set_target(pos:Vector2):
	target_position = pos
	arrived = false

func generate_order():
	if order_generated:
		return
		
	order_generated = true
	order_name = possible_orders.pick_random()
	patience_left = patience_time
	patience_expired = false
	served_successfully = false
	update_customer_timer()
	print(order_name)
	show_bubble()
	
	if order_images.has(order_name):
		var food_tex = order_images[order_name]
		GlobalSignals.customer_ordered.emit(order_name, food_tex, self)
		
func show_bubble():
	if order_images.has(order_name):
		$Bubble.visible = true
		food_icon.texture = order_images[order_name]
		bubble_bg.visible = true
	else:
		print("Error: No image found for ", order_name)
func leave_resturant():
	
	leaving = true
	arrived = false
	at_table = false
	order_generated = false
	update_customer_timer()
	
	if my_table != null:
		my_table.occupied = false
		my_table.customer_ref = null
	
	animated_sprite_2d.play("leaving")
	set_target(exit_position)

func _physics_process(delta: float) -> void:
	update_customer_patience(delta)

	if arrived:
		return
	if target_position == Vector2.ZERO:
		return
	
	var direction = target_position - global_position
		
	if direction.length() > 1:
		velocity = direction.normalized() * speed
		move_and_slide()
		if leaving:
			if animated_sprite_2d.animation!= "leaving":
				animated_sprite_2d.play("leaving")

		else: 
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

func update_customer_patience(delta: float) -> void:
	if not at_table or not order_generated or leaving or served_successfully or patience_expired:
		return

	patience_left = max(patience_left - delta, 0.0)
	update_customer_timer()

	if patience_left <= 0.0:
		patience_expired = true
		customer_got_angry_and_left()

func update_customer_timer() -> void:
	if customer_timer == null:
		return
	customer_timer.visible = at_table and order_generated and not leaving and not served_successfully
	if patience_time <= 0.0:
		customer_timer.frame = customer_timer.hframes * customer_timer.vframes - 1
		return
	var empty_amount = 1.0 - clamp(patience_left / patience_time, 0.0, 1.0)
	var last_frame = customer_timer.hframes * customer_timer.vframes - 1
	customer_timer.frame = clampi(roundi(empty_amount * last_frame), 0, last_frame)

func customer_got_angry_and_left() -> void:
	print("Customer got angry and left!")
	at_table = false
	animated_sprite_2d.play("angry")
	$Bubble.visible = false
	update_customer_timer()

	var energy = get_tree().get_first_node_in_group("energy")
	if energy:
		for _i in range(angry_energy_penalty):
			energy.remove_energy()

	GlobalSignals.customer_served.emit(order_name, self)
	await get_tree().create_timer(1.0).timeout
	leave_resturant()


func receive_dish(dish_node):
	if not at_table or patience_expired or leaving:
		print("Customer not seated yet!")
		return
	print("dish_name: ", dish_node.get("item_name"), " | order_name: ", order_name)
	var dish_name = dish_node.name
	var item_name = dish_node.get("item_name")
	if item_name != null:
		dish_name = item_name
	var energy = get_tree().get_first_node_in_group("energy")
	print("comparing: '", dish_name, "' == '", order_name, "'")
	if dish_name == order_name:
		served_successfully = true
		update_customer_timer()
		if energy:
			energy.add_energy()
		animated_sprite_2d.play("happy")
		print("Correct dish!")
		$Bubble.visible = false
		GlobalSignals.customer_served.emit(order_name, self)
		dish_node.z_index = 1
		await get_tree().create_timer(4.0).timeout
		if dish_node != null:
			dish_node.queue_free()
		leave_resturant()
		
	else:
		print("Wrong dish!")
		animated_sprite_2d.play("angry")
		if energy:
			energy.remove_energy()
		dish_node.queue_free()
		
	print("dish_name: ", dish_node.get("item_name"), " | order_name: ", order_name)
