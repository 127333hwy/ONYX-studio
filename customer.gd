extends CharacterBody2D

@export var speed:float = 120
@export var possible_orders: Array[String] = ["Beef","Burger","Ramen"]

var target_position: Vector2 = Vector2(-9999, 9999)
var exit_position: Vector2= Vector2.ZERO

var order_name: String =""
var arrived: bool = false
var leaving :bool = false

var my_table = null

@onready var bubble_label: Label = $Bubble/BubbleLabel
@onready var bubble_bg: ColorRect = $Bubble/BubbleBG

func _ready() -> void:
	hide_bubble()
	
	
func set_target(pos:Vector2):
	target_position = pos
	arrived = false

func generate_order():
	order_name = possible_orders.pick_random()
	bubble_label.text = order_name
	show_bubble()

func show_bubble():
	bubble_bg.visible = true
	bubble_label.visible = true
	print("bubble")

func hide_bubble():
	bubble_bg.visible = false
	bubble_label.visible = false
	print("nobubble")
	
func leave_resturant():
	leaving = true
	arrived = false
	hide_bubble()
	
	if my_table != null:
		my_table.occupied = false
		my_table.customer_ref = null
		
	set_target(exit_position)

func _physics_process(delta: float) -> void:
	if arrived:
		return
	if target_position == Vector2.ZERO:
		return
	
	var direction = target_position - global_position
	
	if direction.length() < 10.0:
		handle_arrival()
		return
	velocity = direction.normalized() * speed
	move_and_slide()

func handle_arrival():
	arrived = true
	velocity = Vector2.ZERO
	if leaving:
		queue_free()
	else:
		if my_table != null:
			my_table.customer_ref = self
		generate_order()
