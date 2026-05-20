extends Control

@onready var ticket_list: HBoxContainer = $TicketList

@export var order_ticket_scene: PackedScene = preload("res://order_ticket.tscn")

@export var recipe_ingredients: Dictionary = {
	"FriedRice": [preload("res://assets/ingredients/Rice.png"), preload("res://assets/ingredients/Meat.png")],
	"Sushi": [preload("res://assets/ingredients/Rice.png"), preload("res://assets/ingredients/Fish.png")],
	"Salad": [preload("res://assets/ingredients/Lettuce.png"), preload("res://assets/ingredients/Meat.png")],
	"Onigiri": [preload("res://assets/ingredients/Rice.png"), preload("res://assets/ingredients/Lettuce.png")]
}

var active_order_tickets: Dictionary = {}

func _ready() -> void:
	GlobalSignals.customer_ordered.connect(_on_customer_ordered)
	GlobalSignals.customer_served.connect(_on_customer_served)
	
func _on_customer_ordered(food_name: String, food_texture: Texture2D, customer_node: CharacterBody2D) -> void:
	var ticket = order_ticket_scene.instantiate()

	ticket_list.add_child(ticket)
	active_order_tickets[customer_node.get_instance_id()] = ticket

	var ingredients = recipe_ingredients.get(food_name, [])

	ticket.setup_ticket(food_name, food_texture, ingredients)


func _on_customer_served(_food_name: String, customer_node: CharacterBody2D) -> void:
	var customer_id = customer_node.get_instance_id()
	if not active_order_tickets.has(customer_id):
		return

	var ticket = active_order_tickets[customer_id]
	active_order_tickets.erase(customer_id)

	if is_instance_valid(ticket):
		ticket.queue_free()
