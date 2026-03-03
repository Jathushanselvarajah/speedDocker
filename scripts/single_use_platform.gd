extends StaticBody2D

var time = 2

func _ready():
	set_process(false)


func _process(_delta):
	time += 1
	$Sprite2D.position += Vector2(0, sin(time) * 2)


func _on_area_2d_body_entered(body):
	# Vérifiez si le corps appartient au groupe "Players"
	if body.is_in_group("Players"):
		print("Body entered: ", body.name)  # Pour voir quel corps entre
		set_process(true)
		$Timer.start(1)  # Démarre le timer après que le joueur entre dans la zone


func _on_timer_timeout():
	if is_processing():
		set_process(false)
		$GPUParticles2D.emitting = true  # Activer l'effet de particules
		$Area2D.queue_free()            # Libérer la zone
		$CollisionShape2D.queue_free()  # Libérer la forme de collision
		$Sprite2D.queue_free()          # Libérer le sprite
		$Timer.start(1.2)               # Redémarrer le timer
	else:
		queue_free()  # Supprime complètement le nœud
