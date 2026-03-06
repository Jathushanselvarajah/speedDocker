extends Area2D

func _on_ordinateur_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):  # Vérifie que le corps est un joueur
		var parent = get_parent()  # Récupère le parent (Node2D)
		
		# Récupère Player1 et Player2 via leur nom
		var player1 = get_tree().root.get_node("Game/Player1")
		var player2 = get_tree().root.get_node("Game/Player2")
		
		# Si c'est le joueur 1 qui touche l'ordinateur
		if body.name == "Player1":
			player2.freeze(0.3)  # Applique l'effet sur le joueur 2 pendant 0,3 seconde
		# Si c'est le joueur 2 qui touche l'ordinateur
		elif body.name == "Player2":
			player1.freeze(0.3)  # Applique l'effet sur le joueur 1 pendant 0,3 seconde

		# Supprimer l'ordinateur de la scène après utilisation
		queue_free()

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_ordinateur_body_entered"))
