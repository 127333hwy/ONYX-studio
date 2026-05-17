extends Area2D

@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		audio_player.play()
