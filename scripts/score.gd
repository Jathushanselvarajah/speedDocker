extends Control

var player_name: String
var score: int
@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	add_child(http_request)
	# Récupère le score depuis ScoreManager au chargement de la scène
	score = ScoreManager.get_final_score()


func _on_button_pressed() -> void:
	player_name = $LineEdit.text.strip_edges()
	if player_name.length() == 3:
		send_score_to_api(player_name, score)
	else:
		pass

func send_score_to_api(name: String, score: int) -> void:
	var url = SupabaseConfig.get_highscores_url()
	var data = {"name": name, "score": score}
	var json_data = JSON.stringify(data)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	var headers = SupabaseConfig.get_headers()
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		# En cas d'erreur, aller quand même vers les highscores
		get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Supabase retourne 201 pour un INSERT réussi
	if response_code == 201 or response_code == 200:
		get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/HighScoresScene.tscn")
