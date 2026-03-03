extends Node2D

@export var inactivity_duration = 10.0  # Durée d'inactivité avant l'arrêt du jeu (en secondes)
@export var camera_smoothness = 0.8  # Vitesse de la transition de la caméra

var player_1_inactivity_timer = 0.0
var player_2_inactivity_timer = 0.0
var final_score = 0  # Variable pour stocker le score final
@onready var player_1: CharacterBody2D = $Player1
@onready var camera = $Camera2D
@onready var background_music: = $BackgroundMusic
@onready var game_timer: Node2D = $GameTimer  # Référence à la scène GameTimer
@onready var countdown_sound: Node2D = $GameTimer/CountdownSound #Référence du son du timer

var ground_limit_y = 400.0  # Définir la limite de sol (ajuster selon ton jeu)

var player_name = ""
var http_request: HTTPRequest = null

func _ready() -> void:
	game_timer.connect("race_ready", Callable(self, "_on_race_start"))
	game_timer.start_timer()  # Démarrer le timer
	print("Le script principal est prêt.")  # Ajoute ceci
	set_process(true)
	player_1_inactivity_timer = 0.0
	
		# Démarrer la musique de fond
	if background_music:
		background_music.play()  # Lancer la musique

	if countdown_sound:
		countdown_sound.play() #Lancer la musique
		
	# Initialiser l'HTTPRequest
	http_request = HTTPRequest.new()
	add_child(http_request)  # Ajoute le node à la scène

func _on_race_start():
	print("La course commence !")
	# Tout le traitement nécessaire pour démarrer la course
	# Cela pourrait inclure l'activation du mouvement des joueurs, des obstacles, etc.
	set_process(true)  # Reprendre le traitement des fonctionnalités (optionnel si déjà actif)

func _process(delta: float) -> void:
	if not game_timer.race_active:
		return  # Bloquer les fonctionnalités jusqu'à ce que la course commence
	# --- Gestion de l'inactivité des deux joueurs ---

	# Augmenter les timers d'inactivité des deux joueurs
	player_1_inactivity_timer += delta
	
	# Si les deux joueurs sont inactifs pendant la durée limite, arrêter le jeu
	if player_1_inactivity_timer >= inactivity_duration:
		print("Les deux joueurs sont inactifs, arrêt du jeu.")
		JavaScriptBridge.eval("window.location.href='http://localhost:3000'")

	# Obtenir les positions X des deux joueurs
	var player_1_x = player_1.position.x
	
	# Déterminer quel joueur est le plus à droite
	var target_position_x = player_1_x
	
	# Obtenir la position actuelle de la caméra
	var camera_position = camera.position
	
	# Déplacer la caméra progressivement vers le joueur le plus avancé
	camera_position.x = lerp(camera_position.x, target_position_x, camera_smoothness)
	
	# Mettre à jour la position de la caméra
	camera.position = camera_position
	
	# --- Vérification si les joueurs sortent de la caméra ---
	
	# Obtenir les dimensions visibles de la caméra
	var camera_left_limit = camera_position.x - (get_viewport_rect().size.x / 2)
	var camera_right_limit = camera_position.x + (get_viewport_rect().size.x / 2)

	# Vérifier si Player1 sort des limites de la caméra
	if player_1.position.x < camera_left_limit or player_1.position.x > camera_right_limit:
		print("Le joueur numéro 1 a perdu")


	# --- Vérification des joueurs franchissant la limite de sol ---
	if player_1.position.y > ground_limit_y:
		print("Le joueur numéro 1 est tombé dans le vide")



# Fonction pour traiter la fin de partie et envoyer le score au ScoreManager
func end_game(score: int) -> void:
	final_score = score
	ScoreManager.set_final_score(final_score)
	print("GOOD SCORE LOAD:", final_score)  # Vérifie que le score est envoyé au ScoreManager
	ScoreManager.check_new_highscore(final_score)
	
# Fonction appelée pour réinitialiser le timer d'inactivité du joueur 1
func reset_player_1_inactivity_timer() -> void:
	player_1_inactivity_timer = 0.0
