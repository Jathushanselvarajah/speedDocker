extends Control

var player_name: String
var score: int
@onready var http_request: HTTPRequest = HTTPRequest.new()
@onready var message_label: Label = $MessageLabel
@onready var message_label_2: Label = $MessageLabel2
@onready var message_label_3: Label = $MessageLabel3
@onready var background_music: = $BackgroundMusic
@onready var inactivity_timer: Timer = Timer.new()
@onready var winner_label_1: Label = $WinnerLabel1
@onready var winner_label_2: Label = $WinnerLabel2

var lettres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var index_lettres = [0, 0, 0]  # Indices pour les lettres de chaque `LetterLabel`
var current_letter_index: int = 0  # Lettre actuellement sélectionnée (0, 1 ou 2)

var winner: String = ""  # Cette variable va contenir "player1" ou "player2" en fonction du gagnant

# Ajouter une fonction qui définit qui a gagné en récupérant cette information depuis WinnerManager
func _ready() -> void:
	# Initialiser et démarrer le timer de 300 secondes
	inactivity_timer.wait_time = 300.0  # Temps d'inactivité en secondes
	inactivity_timer.one_shot = true  # Assure que le timer ne se répète pas
	inactivity_timer.connect("timeout", Callable(self, "_on_inactivity_timeout"))
	add_child(inactivity_timer)  # Ajoute le timer à la scène
	inactivity_timer.start()
	
	if background_music:
		background_music.play()  # Lancer la musique
	add_child(http_request)
	# Récupérer le score depuis ScoreManager lors du chargement de la scène
	score = ScoreManager.get_final_score()

	# Récupérer le gagnant (player1 ou player2)
	winner = "player1" if WinnerManager.is_player1_winner() else "player2"
	
	# Afficher un message avec le score et le pseudo (avant l'envoi)
	message_label.text = "your score is :"
	message_label_2.text = str(score)
	
	# Met à jour l'affichage du gagnant
	update_winner_display()
	
	update_letter_labels()

func update_winner_display() -> void:
	if winner == "player1":
		winner_label_1.text = "PLAYER 1,"
		winner_label_1.visible = true
		winner_label_2.visible = false
	elif winner == "player2":
		winner_label_2.text = "PLAYER 2,"
		winner_label_2.visible = true
		winner_label_1.visible = false


func _on_inactivity_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(delta: float) -> void:
	# Détecter les inputs pour naviguer ou modifier les lettres en fonction du joueur gagnant
	if winner == "player1":
		if Input.is_action_just_pressed("ui_start1"):
			_on_SubmitButton_pressed()
		elif Input.is_action_just_pressed("navigate_left1"):
			navigate_to_previous_letter()
		elif Input.is_action_just_pressed("navigate_right1"):
			navigate_to_next_letter()
		elif Input.is_action_just_pressed("increment_letter1"):
			increment_letter(current_letter_index)
		elif Input.is_action_just_pressed("decrement_letter1"):
			decrement_letter(current_letter_index)
		elif Input.is_action_just_pressed("stop"):  # Détecter l'action "stop"
			handle_stop_action()  # Appeler une méthode dédiée pour "stop"
	
	elif winner == "player2":
		if Input.is_action_just_pressed("ui_start2"):
			_on_SubmitButton_pressed()
		elif Input.is_action_just_pressed("navigate_left2"):
			navigate_to_previous_letter()
		elif Input.is_action_just_pressed("navigate_right2"):
			navigate_to_next_letter()
		elif Input.is_action_just_pressed("increment_letter2"):
			increment_letter(current_letter_index)
		elif Input.is_action_just_pressed("decrement_letter2"):
			decrement_letter(current_letter_index)
		elif Input.is_action_just_pressed("stop"):  # Détecter l'action "stop"
			handle_stop_action()  # Appeler une méthode dédiée pour "stop"


func handle_stop_action() -> void:
	# Arrêter la musique si elle est en cours de lecture
	if background_music and background_music.playing:
		background_music.stop()
	# Revenir au menu principal
	get_tree().quit()



func update_letter_labels():
	# Met à jour l'affichage des lettres et change leur couleur
	var letter_labels = [$Letter1/LetterLabel, $Letter2/LetterLabel, $Letter3/LetterLabel]
	
	for i in range(3):
		if letter_labels[i]:
			letter_labels[i].text = lettres[index_lettres[i]]
			# Mettre en jaune la lettre sélectionnée, en blanc les autres
			letter_labels[i].modulate = Color(1, 1, 0) if i == current_letter_index else Color(1, 1, 1)
		else:
			pass

func increment_letter(index_lettre):
	index_lettres[index_lettre] = (index_lettres[index_lettre] + 1) % lettres.length()
	update_letter_labels()

func decrement_letter(index_lettre):
	index_lettres[index_lettre] = (index_lettres[index_lettre] - 1 + lettres.length()) % lettres.length()
	update_letter_labels()

func navigate_to_next_letter():
	current_letter_index = (current_letter_index + 1) % 3  # Cycle entre 0, 1 et 2
	update_letter_labels()

func navigate_to_previous_letter():
	current_letter_index = (current_letter_index - 1 + 3) % 3
	update_letter_labels()

func get_pseudonym():
	return lettres[index_lettres[0]] + lettres[index_lettres[1]] + lettres[index_lettres[2]]

func _on_SubmitButton_pressed() -> void:
	player_name = get_pseudonym()  # Récupérer le pseudonyme à partir des lettres

	if player_name.length() == 3:
		send_score_to_api(player_name, score)
	else:
		pass

func send_score_to_api(name: String, score: int) -> void:
	var url = "api/?game=SpeedDocker"
	var data = {"name": name, "score": score}
	var json_data = JSON.stringify(data)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		pass

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var body_string = body.get_string_from_utf8()
	if response_code == 200:
		# Revenir à l'écran d'accueil
		get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")
	else:
		pass
