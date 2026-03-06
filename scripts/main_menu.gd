extends Control

@onready var background_music: = $BackgroundMusic
@onready var inactivity_timer: Timer = Timer.new()

func _ready() -> void:
	# Initialiser et démarrer le timer de 300 secondes
	inactivity_timer.wait_time = 15.0  # Temps d'inactivité en secondes
	inactivity_timer.one_shot = true  # Assure que le timer ne se répète pas
	inactivity_timer.connect("timeout", Callable(self, "_on_inactivity_timeout"))
	add_child(inactivity_timer)  # Ajoute le timer à la scène
	inactivity_timer.start()

	if background_music:
		background_music.play()  # Lancer la musique
	pass

func _process(delta: float) -> void:
	# Détecter les inputs
	if Input.is_action_just_pressed("ui_start"):
		_on_start_pressed()
	elif Input.is_action_just_pressed("stop"):
		_on_exit_pressed()
	elif Input.is_action_just_pressed("highscore"):
		_on_highscores_pressed()
		

func _on_inactivity_timeout() -> void:
	JavaScriptBridge.eval("location.reload()")


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gamemode.tscn")

func _on_exit_pressed() -> void:
	JavaScriptBridge.eval("location.reload()")

func _on_highscores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")
