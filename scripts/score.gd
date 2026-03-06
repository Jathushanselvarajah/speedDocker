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
		pass
	else:
		pass
