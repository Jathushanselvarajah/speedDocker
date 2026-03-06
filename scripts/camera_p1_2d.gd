extends Camera2D

@onready var player1 = $"../Player1"  # Chemin vers Player1
@onready var label: Label = $Label  # Chemin vers le Label
@onready var explosion: AnimatedSprite2D = $Explosion  # Référence à l'explosion
@onready var spike_wall = $"../SpikeWall"  # Référence au mur de piques
var spike_wall_speed = 170.0  # Vitesse initiale du mur
var spike_speed_increment = 10.0  # Augmentation de la vitesse du mur tous les 10 km

# Accéder aux AnimatedSprite2D des joueurs
@onready var player1_sprite = player1.get_node("AnimatedSprite2D")  # Accède au nœud AnimatedSprite2D de Player1

var player1_start_position = Vector2()  # Stocker la position de départ de Player1
var player2_start_position = Vector2()  # Stocker la position de départ de Player2
var is_game_over = false  # Pour savoir si le jeu est terminé

# Facteur de conversion : combien de pixels correspondent à un kilomètre
var pixels_per_km = 130.0  # Par exemple, 100 pixels = 1 km (ajuster selon ton jeu)

var speed_increase = 50.0  # Même valeur que dans boost.gd
var ground_limit_y = 300.0  # Définir la limite de sol (ajuster selon ton jeu)
var camera_margin_x = 668.0

var player1_dead = false
var player2_dead = false


signal game_over(final_score)


func _ready() -> void:

	# Enregistrer les positions de départ des joueurs
	player1_start_position = player1.position
		
	# Connecter les barils présents dans la scène (ajuster selon votre organisation)
	for barrel in get_tree().get_nodes_in_group("Barrels"):
		barrel.connect("barrel_touched", Callable(self, "_on_barrel_touched"))

func _on_barrel_touched(player: Node) -> void:
	if player == player1:
		await_end_game("player1")  # Termine le jeu pour le joueur 1


func _process(delta: float) -> void:
	# Si le jeu est terminé, ne rien faire
	if is_game_over:
		return

	# --- Vérifier si un joueur sort de la caméra ---
	var camera_left_limit = position.x - ((get_viewport_rect().size.x / 2) - camera_margin_x)
	var camera_right_limit = position.x + (get_viewport_rect().size.x / 2)

	if player1.position.x < camera_left_limit or player1.position.x > camera_right_limit:
		player1.play_deadline_animation()  # Activer l'animation "deadline"
		await_end_game("player1")  # Appeler une méthode avec un délai
	
	# --- Vérifier si un joueur franchit la limite de sol ---
	if player1.position.y > ground_limit_y:
		player1.play_explosionsol_animation()  # Activer l'animation "deadline"
		await_end_game("player1")  # Appeler une méthode avec un délai

	
	# Vérifier si un joueur joue l'animation "dead"
	if player1_sprite.animation == "dead":  # Vérifier l'animation sur AnimatedSprite2D de Player1
		end_game("player1")  # Terminer le jeu pour Player1


	# --- Calculer la distance parcourue par chaque joueur ---
	var player1_distance = player1.position.x - player1_start_position.x

	# Le score est la distance maximale parcourue entre les deux joueurs
	var max_distance_pixels = max(player1_distance, 0) # Empêche les valeurs négatives


	# Convertir la distance en kilomètres
	var distance_km = max_distance_pixels / pixels_per_km

	# Calculer la vitesse du joueur en fonction de la distance
	update_player_speed(distance_km)

	# Convertir en entier pour supprimer les décimales
	var distance_km_int = int(distance_km)

	# --- Mettre à jour le Label avec le score basé sur la distance en kilomètres (sans décimales) ---
	if not is_game_over:  # Mettre à jour uniquement si le jeu est en cours
		label.text = "%d" % distance_km_int  # Afficher la distance en km sans décimales

	if GameState.move_wall:  # Vérifier si le mur doit bouger
		if distance_km_int > 0:  # Vérifier si le score est supérieur à 0
			spike_wall.position.x += spike_wall_speed * delta

	if spike_wall.get_overlapping_bodies().has(player1):
		player1.play_deadline_animation()  # Activer l'animation "deadline"
		await_end_game("player1")

	# --- Mise à jour de la vitesse du mur tous les 10 km ---
	if not is_game_over:
		var new_speed = 200.0 + spike_speed_increment * int(distance_km / 10)
		spike_wall_speed = max(spike_wall_speed, new_speed)
		
		# Appliquer la limite maximale de vitesse du mur
		new_speed = min(new_speed, 700.0)


# Mise à jour de la vitesse des joueurs en fonction de la distance, y compris si le joueur est boosté
func update_player_speed(distance_km: float) -> void:
	# Calcul de la vitesse standard en fonction de la distance
	var base_speed = 200.0 + 10.0 * int(distance_km / 10)

	# Appliquer la limite maximale de vitesse
	base_speed = min(base_speed, 800.0)
	
	
	# Si le joueur 1 est boosté, appliquer le boost + l'augmentation de distance
	if player1.has_meta("is_boosted") and player1.get_meta("is_boosted"):
		player1.SPEED = player1.get_meta("original_speed") + speed_increase + (25.0 * int(distance_km / 10))
	else:
		player1.SPEED = base_speed

var game_winner: String = ""  # Stocke le gagnant actuel
# Fonction appelée pour arrêter le jeu et afficher le score final

func await_end_game(player: String) -> void:
	is_game_over = true  # Empêche de rejouer l'animation ou de vérifier d'autres conditions
	await get_tree().create_timer(2.5).timeout  # Attendre 0.5 secondes (durée de l'animation "deadline")
	
	# Marquez le joueur comme mort
	if player == "player1":
		player1_dead = true
	elif player == "player2":
		player2_dead = true

	# Si les deux joueurs sont morts, vérifiez les scores avant d'afficher la scène appropriée
	if player1_dead and player2_dead:
		# Calculer la distance finale parcourue par chaque joueur
		var player1_distance = player1.position.x - player1_start_position.x
		var max_distance_pixels = max(player1_distance, 0)

		# Convertir la distance finale en kilomètres
		var final_distance_km = max_distance_pixels / pixels_per_km

		# Convertir en entier pour supprimer les décimales
		var final_distance_km_int = int(final_distance_km)

		if final_distance_km_int == 0:
			# Utilisation d'une fonction de changement de scène après un délai de sécurité
			await get_tree().create_timer(0.1).timeout  # Attendre 1 seconde pour réessayer après un délai
			call_deferred("_change_scene_to_highscore")  # Utiliser 'call_deferred' pour différer l'appel
			return  # Arrêter l'exécution de la fonction ici
		
		# Sinon, continuer avec la logique normale pour HighScoresScene
		call_deferred("_change_scene_to_highscore")  # Utiliser 'call_deferred' pour différer l'appel
	else:
		# Si un seul joueur est mort, gérer la fin de partie normalement
		call_deferred("_trigger_end_game", player)


# Fonction différée pour appeler `end_game` sans bloquer la logique
func _trigger_end_game(player: String) -> void:
	if get_tree() != null:
		end_game(player)
	else:
		pass


func end_game(winner: String) -> void:
	game_winner = winner
	# Si les deux joueurs ne sont pas morts simultanément, gérer normalement
	if not (player1_dead and player2_dead):
		# Détecter quel joueur a perdu
		var losing_player = player1 if winner == "player1" else player1

		
		is_game_over = true  # Marquer que le jeu est terminé

		# Calculer la distance finale parcourue par chaque joueur
		var player1_distance = player1.position.x - player1_start_position.x
		var max_distance_pixels = max(player1_distance, 0)

		# Convertir la distance finale en kilomètres
		var final_distance_km = max_distance_pixels / pixels_per_km

		# Convertir en entier pour supprimer les décimales
		var final_distance_km_int = int(final_distance_km)
		
		
		# Ajouter la gestion du score nul
		if final_distance_km_int == 0:
			change_scene_for_low_score(game_winner)
			return  # Arrêter l'exécution de la fonction ici
		
		# Stocker le score pour utilisation ultérieure
		current_new_score = final_distance_km_int



		# Envoie le score final à ScoreManager
		ScoreManager.set_final_score(final_distance_km_int)

		# Appeler directement check_new_highscore pour vérifier le record
		check_new_highscore(final_distance_km_int)

		emit_signal("game_over", final_distance_km_int)  # Émettre le signal avec le score final en km (entier)

var current_new_score: int  # Variable de classe pour stocker le score


func check_new_highscore(new_score: int) -> void:
	current_new_score = new_score
	var url = "info.json"
	var http_request = HTTPRequest.new()
	add_child(http_request)  # Ajouter le nœud HTTPRequest

	http_request.connect("request_completed", Callable(self, "_on_highscores_loaded"))
	var error = http_request.request(url)

	if error != OK:
		pass


# Fonction appelée lors du chargement des scores
func _on_highscores_loaded(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if response_code == 200:
		var body_string = body.get_string_from_utf8()
		var json = JSON.new()
		var parse_result = json.parse(body_string)

		if parse_result == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY and data.has("highscores"):
				var highscores = data["highscores"]
				
				# Vérifier si le score actuel est le plus élevé des 11 premiers
				var is_highest = true
				for i in range(min(11, highscores.size())):
					if current_new_score <= highscores[i]["score"]:
						is_highest = false
						break

				# Si le score est dans les 11 premiers, l'ajouter
				if is_highest:
					change_scene_for_records(game_winner)
				elif highscores.size() < 11:
					change_scene_for_highscore(game_winner)
				else:
					# Comparer le score actuel avec le plus faible des 11 meilleurs
					var lowest_score = highscores[0]["score"]
					for i in range(1, min(11, highscores.size())):
						if highscores[i]["score"] < lowest_score:
							lowest_score = highscores[i]["score"]

					if current_new_score > lowest_score:
						change_scene_for_highscore(game_winner)
					else:
						change_scene_for_low_score(game_winner)
			else:
				change_scene_for_low_score(game_winner)
		else:
			change_scene_for_low_score(game_winner)
	else:
		change_scene_for_low_score(game_winner)

# Fonction pour changer la scène en fonction du gagnant (pour les scores éligibles)
func change_scene_for_records(winner: String) -> void:
	# Mettre à jour le gagnant en utilisant WinnerManager
	if winner == "player1":
		WinnerManager.set_winner(true, false)  # Player2 gagne
		get_tree().change_scene_to_file("res://scenes/Player2Record_p1.tscn")
	elif winner == "player1":
		WinnerManager.set_winner(true, false)  # Player2 gagne
		get_tree().change_scene_to_file("res://scenes/Player2Record_p1.tscn")
	else:
		pass

# Fonction pour changer la scène en fonction du gagnant (pour les scores éligibles)
func change_scene_for_highscore(winner: String) -> void:
	# Mettre à jour le gagnant en utilisant WinnerManager
	if winner == "player1":
		WinnerManager.set_winner(true, false)  # Player2 gagne
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	elif winner == "player1":
		WinnerManager.set_winner(true, false)  # Player2 gagne
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	else:
		pass


# Fonction pour changer la scène si le score n'est pas éligible
func change_scene_for_low_score(winner: String) -> void:
	if winner == "player1":
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	elif winner == "player1":
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

	else:
		pass

# Fonction qui sera appelée pour changer la scène, différée
func _change_scene_to_highscore() -> void:
	if get_tree() != null:
		get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")
	else:
		pass



func _on_Explosion_animation_finished() -> void:
	explosion.hide()  # Cacher l'explosion une fois terminée
