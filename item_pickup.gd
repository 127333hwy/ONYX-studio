extends Node2D
class_name item_pickup

@export var item_scene : PackedScene

@onready var prompt = $Interaction

var player_in_range := false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		pick_up()

func _on_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = true
		if not body.holding_item: 
			prompt.visible = true

func _on_body_exited(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = false
		prompt.visible = false

func pick_up():
	var pickup_point = get_tree().get_first_node_in_group("pickup_point")
	if pickup_point == null:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player.holding_item:
		return
		
	var new_item = item_scene.instantiate()
	new_item.reparent(pickup_point)
	new_item.position = Vector2.ZERO

	player.holding_item = true
	player.held_item = new_item

	prompt.visible = false
