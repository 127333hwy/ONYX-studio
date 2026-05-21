extends CanvasLayer

@onready var energy_bar: AnimatedSprite2D = $Control/EnergyBar

var total_frames: int = 27
		
func add_energy():
	energy_bar.frame = min(energy_bar.frame + 1, total_frames - 1)
	if energy_bar.frame >= total_frames - 1:
		on_bar_full()
	
func remove_energy():
	energy_bar.frame = max(energy_bar.frame - 1, 0)
	
func on_bar_full():
	print("Bar is full!")
	get_tree().change_scene_to_file("res://ending.tscn")
