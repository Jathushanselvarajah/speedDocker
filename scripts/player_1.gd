extends CharacterBody2D

var SPEED = 300.0  # Augmente la vitesse ici
const JUMP_VELOCITY = -330.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_node = get_parent()  # On récupère le nœud parent "game"
@onready var smoke_ground: AnimatedSprite2D = $SmokeEffect/SmokeGround  # Référence au SmokeGround
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var item_sound: AudioStreamPlayer2D = $ItemSound
@onready var freeze_sound: AudioStreamPlayer2D = $FreezeSound
@onready var boom_sound: AudioStreamPlayer2D = $BoomSound

@onready var game_timer: Node2D = get_node("/root/Game/GameTimer")  # Accès direct au GameTimer



var is_frozen = false  # Nouvelle variable pour vérifier si le joueur est "bloqué"
var was_on_floor = false  # Suivi de l'état précédent du joueur (au sol ou en l'air)



func _on_boost_taken(player: Node) -> void:
	# Vérifier si le joueur boosté est ce joueur
	if player == self:
		$SmokeEffect/SmokeSprite.play("run_boost")
		item_sound.play()  # Jouer le son de l'item

func _on_boost_ended(player: Node) -> void:
	if player == self:
		$SmokeEffect/SmokeSprite.stop()
		$SmokeEffect/SmokeSprite.frame = 0  # Réinitialiser l'animation

# Fonction pour déclencher l'animation SmokeGround
func _smoke_ground_effect() -> void:
	smoke_ground.play("smokeground")

# Connexion des boosts
func connect_boosts() -> void:
	# Déconnecter les anciens boosts en toute sécurité
	for boost in get_tree().get_nodes_in_group("Boosts"):
		if boost.is_connected("boost_taken", Callable(self, "_on_boost_taken")):
			boost.disconnect("boost_taken", Callable(self, "_on_boost_taken"))
		if boost.is_connected("boost_ended", Callable(self, "_on_boost_ended")):
			boost.disconnect("boost_ended", Callable(self, "_on_boost_ended"))
	
	# Connecter les nouveaux boosts
	for boost in get_tree().get_nodes_in_group("Boosts"):
		boost.connect("boost_taken", Callable(self, "_on_boost_taken"))
		boost.connect("boost_ended", Callable(self, "_on_boost_ended"))


func connect_barrels() -> void:
	# Connecter les barils au signal "barrel_touched"
	for barrel in get_tree().get_nodes_in_group("Barrels"):
		if not barrel.is_connected("barrel_touched", Callable(self, "_on_barrel_touched")):
			barrel.connect("barrel_touched", Callable(self, "_on_barrel_touched"))

func _on_barrel_touched(player: Node) -> void:
	if player == self:
		# Joueur touché par un baril : activer l'animation "dead" et le bloquer
		boom_sound.play() 
		is_frozen = true  # Bloque les mouvements
		animated_sprite_2d.animation = "dead"  # Joue l'animation de mort

func _ready() -> void:
	add_to_group("Players")
	connect_boosts()  # Connecte les boosts existants
	connect_barrels()  # Connecte les barils existants


	# Connexion du signal race_ready
	game_timer.connect("race_ready", Callable(self, "_on_race_ready"))  # Connexion correcte du signal

func _on_race_ready() -> void:
	# La course est prête, donc le joueur peut commencer
	set_process(true)  # Reprend le traitement du joueur (si nécessaire)


func freeze(duration: float) -> void:
	is_frozen = true
	animated_sprite_2d.animation = "freeze"
	freeze_sound.play()  # Jouer le son freeze
	await get_tree().create_timer(duration).timeout  # Remplace yield par await
	is_frozen = false

func _physics_process(delta: float) -> void:
	if not game_timer.race_active or is_frozen:
		return 

	# Ajout de la gravité.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		# Si la vitesse verticale est positive, on joue l'animation de chute ("fall")
		if velocity.y > 0:
			animated_sprite_2d.animation = "fall"
		else:
			animated_sprite_2d.animation = "jump"
	else:
		# Animations sol (course ou idle)
		if abs(velocity.x) > 1:
			animated_sprite_2d.animation = "run"
		else:
			animated_sprite_2d.animation = "default"
	
	# Détecter si le joueur vient d'atterrir (passage de "en l'air" à "au sol")
	if not was_on_floor and is_on_floor():
		_smoke_ground_effect()  # Jouer la fumée uniquement quand on atterrit

	# Mettre à jour l'état précédent (au sol ou en l'air)
	was_on_floor = is_on_floor()

		# Gestion du saut.
	if Input.is_action_just_pressed("player1_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()  # Jouer le son de saut
		game_node.reset_player_1_inactivity_timer()  # Réinitialiser le timer du joueur 1

	# Obtenir la direction d'entrée et gérer le mouvement/décélération.
	var direction := Input.get_axis("player1_left", "player1_right")
	if Input.is_action_just_pressed("stop"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction != 0:  # Si le joueur 1 se déplace, réinitialiser aussi le timer
		game_node.reset_player_1_inactivity_timer()
	# Changement de direction
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	move_and_slide()

	# Retourner le sprite selon la direction
	animated_sprite_2d.flip_h = velocity.x < 0
	

func play_deadline_animation() -> void:
	boom_sound.play()  # Jouer le son de l'item
	# Activer l'animation "deadline" et bloquer les mouvements
	is_frozen = true
	animated_sprite_2d.animation = "deadline"

func play_explosionsol_animation() -> void:
	boom_sound.play()  # Jouer le son de l'item
	# Activer l'animation "deadline" et bloquer les mouvements
	is_frozen = true
	animated_sprite_2d.animation = "explosionsol"
