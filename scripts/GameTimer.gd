extends Node2D

signal race_ready  # Signal pour indiquer que la course peut commencer

@export var race_timer_duration: int = 3  # Durée du compte à rebours (en secondes)
@onready var countdown_label: Label = $CountdownLabel
@onready var countdown_sound: AudioStreamPlayer2D = $CountdownSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var race_active: bool = false  # Indique si la course est active

func start_timer():
	countdown_label.visible = true
	race_active = false  # La course n'est pas active avant que le timer ne se termine

	# Lancement du compte à rebours
	for i in range(race_timer_duration, 0, -1):
		countdown_label.text = str(i)
		countdown_label.modulate = Color(1, 1, 1)  # Couleur blanche par défaut
		animation_player.play("scale_bounce")  # Joue l'animation
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "GO!"
	countdown_label.modulate = Color(1, 1, 0)  # Jaune
	animation_player.play("scale_bounce")
	await get_tree().create_timer(1.0).timeout
	countdown_label.visible = false

	# La course peut maintenant commencer
	race_active = true  # La course est active après le compte à rebours
	emit_signal("race_ready")  # Émettre le signal indiquant que la course est prête
