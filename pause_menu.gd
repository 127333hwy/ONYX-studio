extends Control

var is_paused: bool = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused

func _ready():
	is_paused = false
	hide()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_button_pressed() -> void:
	is_paused = false


func _on_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://prototype.tscn")

func _on_button_3_pressed() -> void:
	is_paused = false
