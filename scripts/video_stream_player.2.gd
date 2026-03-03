extends VideoStreamPlayer

@onready var background_music: = $BackgroundMusic

func _ready() -> void:
	if background_music:
		background_music.play()  # Lancer la musique
	# Démarrer automatiquement la vidéo
	play()

	# Connecter le signal "finished" à la fonction pour gérer la fin de la vidéo
	connect("finished", Callable(self, "_on_video_finished"))  # Correction ici


func _on_video_finished() -> void:
	# Passer à la scène suivante après la fin de la vidéo
	get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")


func _on_finished() -> void:
	pass # Replace with function body.
