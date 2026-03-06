extends Node

# Variables pour stocker l'état des gagnants
var player1_is_winner: bool = false
var player2_is_winner: bool = false

# Fonction pour définir le gagnant
func set_winner(player1: bool, player2: bool) -> void:
	player1_is_winner = player1
	player2_is_winner = player2

# Fonction pour vérifier si Player1 a gagné
func is_player1_winner() -> bool:
	return player1_is_winner

# Fonction pour vérifier si Player2 a gagné
func is_player2_winner() -> bool:
	return player2_is_winner
