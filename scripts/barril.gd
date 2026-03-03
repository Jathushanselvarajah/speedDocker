extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D  # Référence au sprite animé
signal barrel_touched(player)  # Signal envoyé lorsqu'un joueur touche le baril

var is_activated: bool = false  # Indique si le baril a déjà été activé

# Fonction appelée lorsque le joueur entre en collision avec le baril
func _on_body_entered(body: Node2D) -> void:
	if is_activated:  # Vérifie si le baril a déjà été activé
		return  # Sort de la fonction pour éviter les doublons

	if body.is_in_group("Players"):  # Vérifie si l'objet est un joueur
		is_activated = true  # Marque le baril comme activé
		animated_sprite_2d.play("destruction")  # Joue l'animation de destruction
		emit_signal("barrel_touched", body)  # Envoie le signal avec le joueur comme paramètre
		await animated_sprite_2d.animation_finished
		queue_free()  # Supprime le baril
