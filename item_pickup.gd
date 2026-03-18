extends Node2D
class_name item_pickup

@export var item_scene : PackedScene

@onready var prompt = %Interaction

var player_in_range := false
var player_ref : CharacterBody2D = null

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	prompt.visible = false
	
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if player_ref and not player_ref.holding_item:
			pick_up()

func _on_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		if not body.holding_item: 
			prompt.visible = true

func _on_body_exited(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		prompt.visible = false

func pick_up():
	var pickup_point = get_tree().get_first_node_in_group("pickup_point")
	if pickup_point == null:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player_ref.holding_item:
		return
		
	var new_item = item_scene.instantiate()
	pickup_point.add_child(new_item)
	
	new_item.position = Vector2.ZERO

	player_ref.holding_item = true
	player_ref.held_item = new_item
	

	prompt.visible = false
