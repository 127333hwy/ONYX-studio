extends Button

@onready var pause_menu: Control = $"../PauseMenu"


func _on_pressed():
	if pause_menu:
		pause_menu.is_paused = true
