extends Area2D

# Variables de vitesse
var base_speed = 200.0
var speed_increase = 15.0
var pixels_per_km = 80.0

@onready var player1 = $"../Player1"
@onready var player2 = $"../Player2"
@onready var start_timer = $"Timer/StartTimer"
@onready var boom_sound: AudioStreamPlayer2D = $BoomSound
@onready var game_timer: Node2D = get_node("/root/Game/GameTimer")  # Accès direct au GameTimer


var move_wall = false

func _ready():
	# Connexion du signal race_ready
	game_timer.connect("race_ready", Callable(self, "_on_race_ready"))  # Connexion correcte du signal

	start_timer.wait_time = 10.0  # Assurez-vous que le timer est défini
	start_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	start_timer.start()


func _on_race_ready() -> void:
	print("La course peut commencer pour le mur !")
	# La course est prête, donc le joueur peut commencer
	set_process(true)  # Reprend le traitement du joueur (si nécessaire)


func _on_timer_timeout():
	GameState.start_moving_wall()  # Appeler la méthode de l'autoload

func _process(delta):
	if not game_timer.race_active:
		return  # Ne pas bouger le mur tant que la course n'a pas commencé
	if move_wall:
		position.x += base_speed * delta
		print("Mur en mouvement.")  # Pour vérifier que le mur se déplace

	var player1_distance = player1.position.x / pixels_per_km
	var player2_distance = player2.position.x / pixels_per_km
	var max_distance_km = max(player1_distance, player2_distance)

	base_speed = 200.0 + speed_increase * int(max_distance_km / 10)

func _on_body_entered(body):
	if body.name == "Player1" or body.name == "Player2":
		if body.has_node("AnimatedSprite2D"):
			boom_sound.play()  # Jouer le son de l'item
			body.get_node("AnimatedSprite2D").play("deadline")
		print(body.name, " a été touché par le mur de piques.")
