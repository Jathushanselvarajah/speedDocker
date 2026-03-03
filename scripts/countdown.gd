extends Node2D

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	# Lancer la vidéo
	video_player.play()
	# Connecter le signal de fin de lecture pour changer de scène
	video_player.connect("finished", Callable(self, "_on_video_stream_player_finished"))

func _on_video_stream_player_finished() -> void:
	# Charger la scène du jeu à la fin de la vidéo
	get_tree().change_scene_to_file("res://scenes/game.tscn")
