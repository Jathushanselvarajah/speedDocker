extends Control

var player_name: String
var score: int
@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	add_child(http_request)
	# Récupère le score depuis ScoreManager au chargement de la scène
	score = ScoreManager.get_final_score()
	print("Score récupéré depuis ScoreManager : ", score)


func _on_button_pressed() -> void:
	player_name = $LineEdit.text.strip_edges()
	if player_name.length() == 3:
		send_score_to_api(player_name, score)
	else:
		print("Le pseudo doit être de trois lettres.")

func send_score_to_api(name: String, score: int) -> void:
	var url = "http://localhost:3000/api/?game=SpeedDocker"
	var data = {"name": name, "score": score}
	var json_data = JSON.stringify(data)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("Erreur lors de l'envoi de la requête : ", error)

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var body_string = body.get_string_from_utf8()
	if response_code == 200:
		print("Score envoyé avec succès.")
	else:
		print("Erreur lors de l'envoi du score : ", response_code)
		print("Corps de la réponse : ", body_string)
