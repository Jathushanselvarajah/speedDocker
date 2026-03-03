extends Control

@onready var background_music: = $BackgroundMusic
@onready var inactivity_timer: Timer = Timer.new()

func _ready() -> void:
	# Initialiser et démarrer le timer de 300 secondes
	inactivity_timer.wait_time = 10.0  # Temps d'inactivité en secondes
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
		_on_button_pressed()
	elif Input.is_action_just_pressed("highscore"):
		_on_button_2_pressed()
	elif Input.is_action_just_pressed("stop"):  # Détecter l'action "stop"
		handle_stop_action()  # Appeler la méthode dédiée

func _on_inactivity_timeout() -> void:
	print("Temps écoulé, retour au menu principal.")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_p1.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func handle_stop_action() -> void:
	print("Action 'stop' détectée !")
	# Arrêter la musique si elle est en cours de lecture
	if background_music and background_music.playing:
		background_music.stop()
	# Revenir au menu principal
	JavaScriptBridge.eval("window.location.href='http://localhost:3000';")
