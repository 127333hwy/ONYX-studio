extends StaticBody2D

class_name Table

var occupied:bool = false
var customer_ref = null
var player_in_range: bool = false
@export var chair:Node2D;
@onready var serve_point = $ServePoint 

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("drop_item"):
		if occupied and customer_ref != null:
			check_and_serve()

func check_and_serve():
	var player = get_tree().get_first_node_in_group("player")
	if player.holding_item and player.held_item:
		var dish = player.held_item
		
		if customer_ref == null:
			return
		
		if dish.item_name == customer_ref.order_name:
			serve_to_table(player, dish)
		else:
			print("Match failed!")
			
func serve_to_table(player, dish):
	dish.reparent(self)
	var tween = create_tween()
	tween.tween_property(dish, "position", serve_point.position, 0.3).set_trans(Tween.TRANS_SINE)
	player.holding_item = false
	player.held_item = null
	customer_ref.receive_dish(dish)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
