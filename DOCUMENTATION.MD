# Structural Overview

<img src="Assets/screenshots/main_structure.png">

Godot 4.4 allows for Modular programming that this project takes advantage of. By seperating the program into seperate slices, code has been easier to read and understand. Heavenly Havoc relies on emiting and recieving signals across different scenes in order to form a more cohesive game. 
The bulk of these are defined in an auto-loade global script found in `global.gd`, which, indicated by its namesake provides global variables and signals which scripts can reference and pass along.


# Global

```sh
extends Node
signal init_battle // initiates battles
signal spell_options //shows spells player has
signal be_selected(this_target: Node2D) // signals that the target has been chosen for attacks
signal choose_target // gives player option to choose targets
signal wave_complete // when a battle is completed
signal game_over // when all players died 
signal casted(SpellData) // holds the spell selected to be referenced later



var current_turn: Node2D
var chosen_enemy: Node2D
var casting_spell: bool = false
var has_no_spells: bool

var current_wave: int = 0
var total_enemy_exp: int = 0
```

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
<br>

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

# Sorts character speed
func _sort_turn_order_ascending(battler_1, battler_2) -> bool:
	if battler_1.stats_resource.turn_speed < battler_2.stats_resource.turn_speed:
		return true
	return false
```
The later functions all reference this one, so I'd like to elaborate on what it does really quickly. The `Battle_Scene` has a panel beneath the canvas layer, showcasing the small snippets of text throughout the battle. It opperates by referencing the RichTextLabel, clearing and appending the text over-top of it.
```sh
@onready var textbox: MarginContainer = $CanvasLayer/textbox
@onready var textbox_text: RichTextLabel = $CanvasLayer/textbox/text/RichTextLabel
```

```sh
func _show_flavor_text(message: String) -> void:
	textbox_text.clear()
	textbox_text.append_text(message)
	textbox_text.show()
```
<br>

Now that turns are sorted, the global variable `current_turn` is referenced and changed to whomever's turn-speed is the highest on the battle field. When `update_turn` is called, a condition is checked to see if the current_turn's stat resource is a player battler. When this condition is met, an asset on the screen changes it's text to display the player's stats, and shows new flavor text. If this condition is not met, the function does not do anything.
Once these conditions are read through, in either case, the function calls for the `current_turn`'s start_turn function, found in both player and enemy battlers. As seen earlier both in the initalizing and ready functions if a battler of either type emits a `turn_ended` signal, only then is a `next_turn` function called. Next_turn changes the Node2D variable to the next battler found in the array.
```sh
# calls the different turns
func _update_turn() -> void:
	Global.casting_spell = false
	#print(Global.current_turn.stats_resource.char_name)
	if Global.current_turn.stats_resource.type == BattlerStats.BattlerType.Player:
		player_status_text._show_hp_text(Global.current_turn.stats_resource.char_name, Global.current_turn.level, Global.current_turn.current_hp, Global.current_turn.stats_resource.max_hp, Global.current_turn.current_mp, Global.current_turn.stats_resource.max_mp)
		_show_flavor_text("What does %s do...?" %[Global.current_turn.stats_resource.char_name])
		turn_action_buttons.show()
		_no_longer_defending()
	else:
		pass
		
	Global.current_turn.start_turn()
		
func _next_turn() -> void:
	Global.current_turn.stop_turn()
	if _check_battle_end() == false:
		current_turn_index = (current_turn_index + 1) % all_battlers.size()
		Global.current_turn = all_battlers[current_turn_index]
		
		_update_turn()
	else:
		pass
```
<br>

The following section of functions is only considered when the player side deals damage. What these do is look for certain functions found in the enemy_battler scripts, hiding or showing a select button when prompted.

```sh
func _hide_target_buttons() -> void:
	for e in enemy_battlers:
		e.hide_select_button()

func _show_target_buttons() -> void:
	turn_action_buttons.hide()
	spell_options.hide()
	for e in enemy_battlers:
		e.show_select_button()

func attack_selected_enemy(selected_enemy: Node2D) -> void:
	_hide_target_buttons()
	spell_options.hide()
	if Global.casting_spell == true:
		Global.current_turn.start_blasting(selected_enemy)
		selected_enemy.dmg_label._update_text(Global.current_turn.sp_damage)
		_show_flavor_text("%s dealt %s damage!" %[Global.current_turn.stats_resource.char_name, Global.current_turn.sp_damage])
	else:
		Global.current_turn.start_attacking(selected_enemy)
		selected_enemy.dmg_label._update_text(Global.current_turn._get_attack_damage())
		_show_flavor_text("%s dealt %s damage!" %[Global.current_turn.stats_resource.char_name, Global.current_turn._get_attack_damage()])


func _select_spell():
	Global.casting_spell = true
	textbox_text.hide()
	spell_options.show()
	if Global.has_no_spells == true:
		_no_spells()
		
func _no_spells():
	Global.has_no_spells = true
	spell_options.hide()
	textbox_text.show()
	_show_flavor_text("%s has NO SPELLS." %[Global.current_turn.stats_resource.char_name])
```

```sh
func _defending_turn():
	_defending(Global.current_turn)

func _defending(current_player: Node2D) -> void:
	current_player.stats_resource.defending = true
	_show_flavor_text("%s defends themselves!" %[current_player.stats_resource.char_name])
	_next_turn()
	
func _no_longer_defending():
	Global.current_turn.stats_resource.defending = false
	
	
```

<br>

```sh
func attack_random_player_battler(damage: int) -> void:
	var rand = randi_range(0, player_battlers.size() - 1)
	
	player_battlers[rand].play_hit_anim()
	await get_tree().create_timer(0.6).timeout
	player_battlers[rand].take_damage(damage)
	player_battlers[rand].dmg_label._update_text(damage)
	await get_tree().create_timer(0.1).timeout
	_next_turn()

```

<br>
```sh
#On death!!
func _on_enemy_dead(dead_enemy: Node2D) -> void:
	Global.total_enemy_exp += dead_enemy.stats_resource.experience
	enemy_battlers.erase(dead_enemy)
	all_battlers.erase(dead_enemy)
	remove_child(dead_enemy)
	_show_flavor_text("KNOCK OUT!!")
	
func _on_player_dead(dead_battler: Node2D) -> void:
	player_battlers.erase(dead_battler)
	all_battlers.erase(dead_battler)
	_show_flavor_text("KNOCK OUT!!")
	
func _check_battle_end() -> bool:
	if enemy_battlers.is_empty():
		canvas_layer.hide()
		Global.emit_signal("wave_complete")
		
		return true

	if player_battlers.is_empty():
		canvas_layer.hide()
		Global.emit_signal("game_over")
		
		return true	
	return false
```

## End Panel


# Stats, Actions and Resources
## Battlers
## Spells


