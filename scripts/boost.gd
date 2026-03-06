extends Area2D

@export var speed_increase: float = 50.0  # Augmentation de la vitesse
@export var boost_duration: float = 1.0  # Durée du boost en secondes

var boost_time_left: float = 0.0  # Temps restant pour le boost
var boosted_player: Node = null  # Le joueur qui a pris le boost

signal boost_taken(player)

@onready var boost_timer: Timer = null  # Déclaration du timer

func _ready() -> void:
	add_to_group("Boosts")
	# Initialisation du timer une seule fois si ce n'est pas déjà fait
	if boost_timer == null:
		boost_timer = Timer.new()
		add_child(boost_timer)
	
	# Configurer le timer pour qu'il ne répète pas
	boost_timer.one_shot = true
	boost_timer.wait_time = boost_duration
	
	# Connecter l'événement de fin du timer (si pas déjà connecté)
	if not boost_timer.is_connected("timeout", Callable(self, "_on_boost_timeout")):
		boost_timer.connect("timeout", Callable(self, "_on_boost_timeout"))
	
	# Connecter l'événement de collision avec un joueur si nécessaire
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))


# Fonction appelée lorsqu'un joueur entre en collision avec le Boost
func _on_body_entered(body: Node) -> void:
	# Vérifier si le corps entrant est dans le groupe "Players" pour n'appliquer le boost qu'aux joueurs
	if body.is_in_group("Players"):

		# Si le joueur n'a pas déjà un boost actif, lui appliquer le boost
		if boosted_player == null:
			apply_boost(body)
		
		# Masquer le boost pour qu'il ne soit plus visible ou utilisable
		hide()
		set_collision_layer(0)  # Désactiver les collisions pour éviter de le reprendre
		set_collision_mask(0)

# Fonction pour appliquer le boost de vitesse au joueur
func apply_boost(player: Node) -> void:
	# Sauvegarder le joueur qui a pris le boost
	boosted_player = player

	# Marquer le joueur comme étant boosté
	boosted_player.set_meta("is_boosted", true)
	
	# Sauvegarder la vitesse initiale si elle n'est pas déjà enregistrée
	if not boosted_player.has_meta("original_speed"):
		boosted_player.set_meta("original_speed", boosted_player.SPEED)

	# Appliquer l'augmentation de vitesse
	boosted_player.SPEED += speed_increase
	boost_time_left = boost_duration  # Définit la durée du boost
	

	# Envoyer un signal indiquant qu'un joueur a pris un boost
	emit_signal("boost_taken", boosted_player)

	# Démarrer le timer pour la durée du boost
	boost_timer.start()

signal boost_ended(player)

# Fonction appelée lorsque le timer expire
func _on_boost_timeout() -> void:
	# Afficher un message pour vérifier si cette fonction est appelée
	
	# Vérifie si un joueur a un boost actif
	if boosted_player != null:
		emit_signal("boost_ended", boosted_player)
		# Retirer l'augmentation de vitesse à la fin du boost
		if boosted_player.has_meta("original_speed"):
			var original_speed = boosted_player.get_meta("original_speed")
			boosted_player.SPEED = original_speed
			boosted_player.remove_meta("original_speed")

		# Retirer le statut de boosté
		boosted_player.set_meta("is_boosted", false)
		boosted_player = null
	#SUPPRESION QUAND LE BOOST EST TERMINER A 100%
	queue_free()
