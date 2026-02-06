extends Area2D
@export_file("*.tscn") var backyard_scene: String

func _on_body_entered(body) -> void:
	print("Entered:",body.name)
	if body is CharacterBody2D:
		get_tree().change_scene_to_file("res://backyard.tscn")
