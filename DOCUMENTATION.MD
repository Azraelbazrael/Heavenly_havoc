# Structural Overview

<img src="Assets/screenshots/main_structure.png">

Godot 4.4 allows for Modular programming that this project takes advantage of. By seperating the program into seperate slices, code has been easier to read and understand. Heavenly Havoc relies on emiting and recieving signals across different scenes in order to form a more cohesive game. 
The bulk of these are defined in an auto-loade global script found in `global.gd`, which, indicated by its namesake provides global variables and signals which scripts can reference and pass along.

# Main Scene
This section discusses the sections of code found within the main scene. This includes the battling scene, the ending panel and the other scripts these scenes heavily reference.
## Battle Manager

Managing a battle in this case comes down to a few processes in this order:
- establishing signals to listen for
- initalizing the battle
- sorting battlers into turn orders
- updating turns
- attacking
- changing turns
- keeping track of whose dead

<br>
Once the scene is loaded, the script looks for nodes in a group to add to an array, then references and connects those node's signals to scripts mentioned later in the script. Once the ready function is complete, it passes the engine to read the initalize function.

```sh
func _ready() -> void:
	## initalized before initalize because these nodes are native to the scene, otherwise would give us errors
	player_battlers = get_tree().get_nodes_in_group("PlayerBattler")
	for p in player_battlers:
		p.turn_ended.connect(_next_turn)
		p.dead.connect(_on_player_dead)
		
	
	defend_button.pressed.connect(_defending_turn)

	Global.connect("choose_target", _show_target_buttons) ## prompts player to choose target
	Global.connect("spell_options", _select_spell) ## shows spell array from players
	Global.connect("init_battle", _initalize) ## creates new battle/enemies
	Global.connect("be_selected", attack_selected_enemy) ## when enemy is attacked
	
	
	
	ready_completed = true
	Global.emit_signal("init_battle")
	

```
Initalization covers instantiating enemies onto the scene. Enemies are not native to the battling scene, and therefore have to be looked for after ready is called. The textbox with flavor text with cleared and the canvas layer with UI assets are shown. From there, each character on the feild is put into an "all battlers" array, where the turn-speed stats connected to each node is sorted with ascending order.
```sh
func _initalize() -> void:
	## initalizes enemies to fight, resetting health and such. These guys are not native to the root scene
	textbox_text.clear()
	canvas_layer.show()
		
	for spawnpoint in get_tree().get_nodes_in_group("SpawnPoints"): ## With each marker marked as spawnpoints there will be (1) enemy
		if spawnpoint is Marker2D:
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemy.position = spawnpoint.position
		
		
	enemy_battlers = get_tree().get_nodes_in_group("EnemyBattler") ## again its important this is after the ready function so it registers it properly
	
	## Adds players and battlers to the array
	if Global.current_wave == 1: ## so players arent added twice/thrice between waves
		all_battlers.append_array(player_battlers)
		
		
	all_battlers.append_array(enemy_battlers)
	all_battlers.sort_custom(_sort_turn_order_ascending)
	

	for e in enemy_battlers:	
		e.dead.connect(_on_enemy_dead) ## when enemy dies
		e.deal_damage.connect(attack_random_player_battler) ## when an enemy is attacking 
		
		
	Global.current_turn = all_battlers[current_turn_index] ## sorts all battlers on the field via turn orders
	_update_turn()
```

## End Panel


# Stats, Actions and Resources
## Battlers
## Spells


