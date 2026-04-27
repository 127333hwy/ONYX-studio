extends Node2D

@export var ticket_scene: PackedScene
var menu
func create_order():
	var new_order = ticket_scene.instantiate()
	$TicketBoard/TicketList.add_child(new_order)
	
