extends Node

var final_score: int = 0

# Fonction pour définir le score final
func set_final_score(score: int) -> void:
	final_score = score
	print("Score final mis à jour dans ScoreManager : ", final_score)

# Fonction pour récupérer le score final
func get_final_score() -> int:
	return final_score
