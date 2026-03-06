extends Control

@onready var http_request: HTTPRequest = HTTPRequest.new()
@onready var best_score_label: RichTextLabel = $BestScoreLabel
@onready var top_scores_label: RichTextLabel = $TopScoresLabel
@onready var inactivity_timer: Timer = $InactivityTimer
@onready var font_for_scores = preload("res://assets/fonts/joystix monospace.otf")
@onready var font_for_names = preload("res://assets/fonts/PixelifySans-VariableFont_wght.ttf")
@onready var background_music: = $BackgroundMusic

func _process(delta: float) -> void:
	# Détecter les inputs
	if Input.is_action_just_pressed("ui_start"):
		_on_button_pressed()
	elif Input.is_action_just_pressed("stop"):
		_on_exit_pressed()

func _ready() -> void:
	if background_music:
		background_music.play()  # Lancer la musique
	add_child(http_request)
	fetch_scores_from_api()

	# Configure et démarre le timer d'inactivité
	if not inactivity_timer:
		inactivity_timer = Timer.new()
		inactivity_timer.wait_time = 5.0  # 5 secondes avant la redirection
		inactivity_timer.one_shot = true
		inactivity_timer.connect("timeout", Callable(self, "_on_inactivity_timeout"))
		add_child(inactivity_timer)
	inactivity_timer.start()

# Récupère les scores depuis l'API
func fetch_scores_from_api() -> void:
	var url = "api/?game=SpeedDocker"
	http_request.connect("request_completed", Callable(self, "_on_scores_request_completed"))
	var error = http_request.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		pass

# Gestion de la réponse HTTP
func _on_scores_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if response_code == 200:
		var body_string = body.get_string_from_utf8()

		# Parse le JSON de la réponse
		var json_instance = JSON.new()
		var parse_result = json_instance.parse(body_string)

		if parse_result == OK:
			var scores_data = json_instance.get_data()["highscores"]

			# Affiche les scores si récupérés correctement
			if scores_data.size() > 0:
				scores_data.sort_custom(sort_scores_descending)  # Tri décroissant
				var best_score = scores_data[0]  # Meilleur score
				var top_scores = scores_data.slice(1, 11)  # Top 10 scores

				# Met à jour les affichages
				update_best_score_display(best_score)
				update_top_scores_display(top_scores)
			else:
				best_score_label.text = "No high scores available."
				top_scores_label.text = ""
		else:
			best_score_label.text = "Erreur lors du parsing des scores."
			top_scores_label.text = ""
	else:
		best_score_label.text = "Erreur de récupération des scores."
		top_scores_label.text = ""

# Met à jour l'affichage du meilleur score
func update_best_score_display(best_score: Dictionary) -> void:
	best_score_label.bbcode_enabled = true
	best_score_label.bbcode_text = "[center][font=res://assets/fonts/PixelifySans-VariableFont_wght.ttf]" + best_score["name"] + "[/font]  " + "[font=res://assets/fonts/joystix monospace.otf]" + str(best_score["score"]) + "[/font][/center]"


# Met à jour l'affichage des scores 2 à 10
func update_top_scores_display(scores_data: Array) -> void:
	top_scores_label.bbcode_enabled = true
	var scores_text = "[center]"  # Ajouter la balise [center] au début
	for score_entry in scores_data:
		scores_text += "[font=res://assets/fonts/PixelifySans-VariableFont_wght.ttf]" + score_entry["name"] + "[/font]  "
		scores_text += "[font=res://assets/fonts/joystix monospace.otf]" + str(score_entry["score"]) + "[/font]\n"
	scores_text += "[/center]"  # Fermer la balise [center]
	top_scores_label.bbcode_text = scores_text

# Fonction de tri décroissant
func sort_scores_descending(a: Dictionary, b: Dictionary) -> bool:
	return a["score"] > b["score"]

# Redirection manuelle vers le menu principal
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_exit_pressed() -> void:
	get_tree().quit()

# Appelée lorsque le timer d'inactivité expire
func _on_inactivity_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Réinitialise le timer d'inactivité lorsqu'une entrée utilisateur est détectée
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		inactivity_timer.start()
