extends Node2D

@onready var prompt = $Interaction

var player_in_range := false
var held := false


func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	prompt.visible = false

func _process(_delta):
	if player_in_range and not held and Input.is_action_just_pressed("interact"):
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
	held = true
	reparent(pickup_point)
	position = Vector2.ZERO
	$Area2D.monitoring = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player.holding_item:
		return
	player.holding_item = true
	prompt.visible = false
