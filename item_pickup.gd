extends Node2D

@onready var prompt = $Interaction

@export var item_scene : PackedScene
@export var item_name : String = "Ingredient"

var player_in_range := false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	prompt.visible = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		var player = get_tree().get_first_node_in_group("player")
		if player and not player.holding_item:
			pick_up(player)

func _on_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = true
		if not body.holding_item: 
			prompt.visible = true

func _on_body_exited(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = false
		prompt.visible = false

func pick_up(player):
	var pickup_point = get_tree().get_first_node_in_group("pickup_point")
	if pickup_point == null:
		return
	var new_item = item_scene.instantiate()
	pickup_point.add_child(new_item)
	new_item.position = Vector2.ZERO

	player.holding_item = true
	player.held_item = new_item

	prompt.visible = false
