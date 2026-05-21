extends Control

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var tip_label: Label = $VBoxContainer/TipLabel
@onready var title_label: Label = $VBoxContainer/TitleLabel

var path_to_load = "res://prototype.tscn"
var dot_count = 0
var timer = 0
var load_status = []

func _ready():
	ResourceLoader.load_threaded_request(path_to_load)

func _process(delta):
	# loading dots
	timer += delta
	if timer > 0.5:
		timer = 0
		dot_count = (dot_count + 1) % 4
		title_label.text = "Loading" + ".".repeat(dot_count)
	# loading progress
	var status = ResourceLoader.load_threaded_get_status(path_to_load, load_status)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if load_status.size() > 0:
			progress_bar.value = load_status[0] * 100

	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(path_to_load)
		get_tree().change_scene_to_packed(scene)
