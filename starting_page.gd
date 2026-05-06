extends CanvasLayer

@onready var main_menu: Control = $MainMenu
@onready var controls_menu: Panel = $ControlsMenu

func _ready() -> void:
	main_menu.show()
	controls_menu.hide()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://prototype.tscn")
	

func _on_tutorial_button_pressed() -> void:
	main_menu.hide()
	controls_menu.show()
	
func _on_back_button_pressed() -> void:
	controls_menu.hide()
	main_menu.show()
