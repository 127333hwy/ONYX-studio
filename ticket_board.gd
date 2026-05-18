extends Sprite2D

@onready var ticket_list: HBoxContainer = $TicketList

@export var order_ticket_scene: PackedScene = preload("res://order_ticket.tscn")

@export var recipe_ingredients: Dictionary = {
	"FriedRice": [preload("res://Onigiri.tres")], 
	"Sushi": [preload("res://Sushi.tres")],
	"Salad": [preload("res://Salad.tres")],
	"Onigiri": [preload("res://Onigiri.tres")]
}

func _ready() -> void:
	GlobalSignals.customer_ordered.connect(_on_customer_ordered)
	
func _on_customer_ordered(food_name: String, food_texture: Texture2D, _customer_node: CharacterBody2D) -> void:
	var new_ticket = order_ticket_scene.instantiate()
	
	ticket_list.add_child(new_ticket)
	
	var ingredients = recipe_ingredients.get(food_name, [])
	
	new_ticket.setup_ticket(food_name, food_texture, ingredients)
