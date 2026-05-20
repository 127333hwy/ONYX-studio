extends Node

@warning_ignore("unused_signal")
signal customer_ordered(food_name: String, food_texture: Texture2D, customer_node: CharacterBody2D)
@warning_ignore("unused_signal")
signal customer_served(food_name: String, customer_node: CharacterBody2D)
