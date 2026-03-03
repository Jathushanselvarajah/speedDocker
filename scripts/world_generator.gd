extends Node2D

@export var sections_pool: Array[PackedScene]  # Liste des scènes de sections normales
@export var num_sections: int = 100  # Nombre total de sections à générer
@export var section_width: float = 100 * 16  # Largeur totale d'une section (24 blocs de 16.5 pixels)
@export var special_scenes: Array[PackedScene]  # Liste des scènes spéciales
@export var special_probability: float = 0.4  # Probabilité d'apparition d'une section spéciale

signal section_added  # Signal pour indiquer qu'une nouvelle section est ajoutée

var current_x_position: float = 0  # Position X où la prochaine section sera placée
var normal_section_count: int = 0  # Compteur de sections normales depuis la dernière section spéciale

func _ready() -> void:
	# Connecter tous les joueurs au signal "section_added"
	for player in get_tree().get_nodes_in_group("Players"):
		connect("section_added", Callable(player, "connect_boosts"))
	generate_world()

func generate_world() -> void:
	randomize()  # Assure-toi que la génération soit aléatoire à chaque partie

	for i in range(num_sections):
		# Décide si une section spéciale ou normale doit être ajoutée
		var add_special = false
		if normal_section_count >= 2 and randi() % 100 < int(special_probability * 100):
			add_special = true

		if add_special:
			add_special_section()
			normal_section_count = 0  # Réinitialiser le compteur après une section spéciale
			print("Ajout d'une section spéciale")  # Afficher un message de débogage pour la section spéciale
		else:
			add_normal_section()
			normal_section_count += 1  # Incrémenter le compteur pour chaque section normale
			print("Ajout d'une section normale")  # Afficher un message de débogage pour la section normale

		# Met à jour current_x_position pour placer la prochaine section à la fin de celle-ci
		current_x_position += section_width

		# Émettre un signal pour indiquer qu'une nouvelle section a été ajoutée
		emit_signal("section_added")

func add_special_section() -> void:
	if special_scenes.size() > 0:
		var special_instance = special_scenes[randi() % special_scenes.size()].instantiate()
		add_child(special_instance)
		special_instance.position.x = current_x_position

func add_normal_section() -> void:
	if sections_pool.size() > 0:
		var normal_instance = sections_pool[randi() % sections_pool.size()].instantiate()
		add_child(normal_instance)
		normal_instance.position.x = current_x_position

		# Connecter dynamiquement les objets dans cette section
		connect_barrels_in_section(normal_instance)

# Nouvelle fonction pour connecter les barils générés dynamiquement
func connect_barrels_in_section(section: Node2D) -> void:
	# Récupérer tous les barils dans la section ajoutée
	for barrel in section.get_tree().get_nodes_in_group("Barrels"):
		# Connecter le signal "barrel_touched" à tous les joueurs
		for player in get_tree().get_nodes_in_group("Players"):
			if not barrel.is_connected("barrel_touched", Callable(player, "_on_barrel_touched")):
				barrel.connect("barrel_touched", Callable(player, "_on_barrel_touched"))
				
func connect_objects_in_section(section: Node2D) -> void:
	# Récupérer tous les boosts dans la section ajoutée
	for boost in section.get_tree().get_nodes_in_group("Boosts"):
		# Connecter le signal "boost_taken" et "boost_ended" à tous les joueurs
		for player in get_tree().get_nodes_in_group("Players"):
			if not boost.is_connected("boost_taken", Callable(player, "_on_boost_taken")):
				boost.connect("boost_taken", Callable(player, "_on_boost_taken"))
			if not boost.is_connected("boost_ended", Callable(player, "_on_boost_ended")):
				boost.connect("boost_ended", Callable(player, "_on_boost_ended"))

	# Récupérer tous les ordinateurs dans la section ajoutée
	for computer in section.get_tree().get_nodes_in_group("Computers"):
		# Connecter le signal "computer_touched" si nécessaire
		for player in get_tree().get_nodes_in_group("Players"):
			if not computer.is_connected("computer_touched", Callable(player, "_on_computer_touched")):
				computer.connect("computer_touched", Callable(player, "_on_computer_touched"))
