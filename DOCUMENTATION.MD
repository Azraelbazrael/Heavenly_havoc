# Structural Overview

<img src="Assets/screenshots/main_structure.png">

Godot 4.4 allows for Modular programming that this project takes advantage of. By seperating the program into seperate slices, code has been easier to read and understand. Heavenly Havoc relies on emiting and recieving signals across different scenes in order to form a more cohesive game. 
The bulk of these are defined in an auto-loade global script found in `global.gd`, which, indicated by its namesake provides global variables and signals which scripts can reference and pass along.


# Global

```sh
extends Node
signal init_battle ## initiates battles
signal spell_options ##shows spells player has
signal be_selected(this_target: Node2D) ## signals that the target has been chosen for attacks
signal choose_target ## gives player option to choose targets
signal wave_complete ## when a battle is completed
signal game_over ## when all players died 
signal casted(SpellData) ## holds the spell selected to be referenced later


var current_turn: Node2D
var chosen_enemy: Node2D
var casting_spell: bool = false
var has_no_spells: bool

var current_wave: int = 0
var total_enemy_exp: int = 0
```

# Main Scene
This section discusses the sections of code found within the main scene found in `gameroot.tscn`. This includes the battling scene, the ending panel and the other scripts these scenes heavily reference. 
The sole root node of the scene contains a simple script:
<br>
All this does, apart from instantiating the two important scenes is to "reset" the battle waves, and erase the battle scene in order for the player to start over. 
```sh
extends Node2D

const battle_scene = preload("res://Scenes/BattleScene/Battle_Scene.tscn")
const battle_over_screen = preload("res://Scenes/BattleScene/wave_over_screen.tscn")

@onready var canvas = $CanvasLayer
var battle
var battle_over

func _ready():
	_start_battle()
	Global.connect("game_over", _restart)
	
func _start_battle():
	battle = battle_scene.instantiate()
	battle_over = battle_over_screen.instantiate()
	
	add_child(battle)
	add_child(battle_over)
	
	
func _restart():
	battle.queue_free()
	Global.current_wave = 0

```

<br>

## Battle Manager

Managing a battle in this case comes down to a few processes in this order:
- establishing signals to listen for
- initalizing the battle
- sorting battlers into turn orders
- updating turns
- attacking
- changing turns
- keeping track of whose dead

<img src="Assets/screenshots/battle_scene_screenshot.png">

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

```
These functions occur when the player selects the spell button. Right inside the textbox is a hidden grid container of buttons, containing the spell slots of the current battler, where the process for changing and adding spells occurs.
```sh
func _select_spell():
	Global.casting_spell = true
	textbox_text.hide()
	spell_options.show()
	if Global.has_no_spells == true:
		_no_spells()
		
func _no_spells():
	Global.casting_spell = false
	spell_options.hide()
	textbox_text.show()
	_show_flavor_text("%s has NO SPELLS." %[Global.current_turn.stats_resource.char_name])
```
```sh
extends GridContainer
class_name Spell_Options

@onready var spell_buttons = get_children()
#
var char_stats: BattlerStats
var move_slots



func _ready() -> void:
	Global.connect("spell_options", _get_char_stats)
	
func _get_char_stats():
	char_stats = Global.current_turn.stats_resource 
	move_slots = char_stats.spell_slots.attack_slots
	
	
	_get_moves()
	



	
func _get_moves() -> void:
	
	if move_slots.size() == 0:
		Global.has_no_spells = true
	else:
		Global.has_no_spells = false
		spell_buttons.resize(move_slots.size())
		for sb in range(spell_buttons.size()):
			
			spell_buttons[sb].spell = (move_slots[sb])
			spell_buttons[sb].text = (move_slots[sb].spell_name)
```
Each button within the container has the following script attached. This tracks the SpellData contained in each node, if at all. When pressed, it emits the "choose target" signal, for showing the target buttons.
```sh
extends Button
class_name Spell_button

@export var spell: SpellData

func _ready() -> void:
	pass
	
func _cast_spell():
	if spell:
		Global.casted.emit(spell)
		spell.cast(Global.current_turn)
		Global.emit_signal("choose_target")
	


func _on_pressed() -> void:	
	_cast_spell()
			
```
<br>
<br>

This function is what happens what the player chooses to defend this round. It switches on a bool and updates the flavor text before calling the next turn.

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
<br>
This sole function is used during enemy turns. Enemy AI is very simple and barebones during this stage of production. What this does is look for a random player battler stored in the array and cause damage to that specific Node, before updating to the next turn in the queue.

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

When a battler on either side dies, one of these top two functions are called. They serve nearly identical functions, when a signal from either player or enemy battlers is emitted, the function is called, passing the node that emitted the signal into the brackets. 
The array erases the shared value from the enemy/player and all battler arrays respectively, before removing the child from the scene entirely.
EXP is passed when an enemy dies, but does not when a player does. 
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
```
The `check_battle_end` function is called during every turn. What this does is check if either the enemy or player battler arrays are empty, if so, emit a global signal. These signals will be important to the end_panel and serves as different ending flags.
```sh
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

<br>

The battling scene also contains a script for changing the UI found in the corner. This is for player convenience. Once each battle is initialized, `Global.current_wave` counts up by one. 
<br>

```sh
extends Label
class_name Wave_text

func _ready() -> void:
	Global.connect("init_battle", update_text)

func update_text():
	Global.current_wave += 1
	text = "wave %s" % [Global.current_wave]

```


## End Panel
The end panel is what appears when the all battlers of the player or enemy side are no longer present. This check occurs within the `battler_manager`.
The root node of this scene is hidden by default and layered over top of the battling scene. 
<br>

The following lines of code just establishes a few things. Firstly is the top of the winning text, the exp display, the button and lastly stores a packedscene for labels used for the exp text.
<br>
<img src="Assets/screenshots/battle_end_screenshot.png">


```sh
extends Panel


var flavor_text: RichTextLabel
var _button: Button
var exp_label = preload("res://Scenes/BattleScene/exp_text.tscn")


@onready var win_lose_text = $"Win_lose text"
@onready var exp_text_handler = $exp_text
@onready var cont_button = $continue_button

func _ready() -> void:
	Global.connect("wave_complete", on_win)
	Global.connect("game_over", on_lose)
	cont_button.pressed.connect(cont_pressed)
```
When either signal is emitted, the RichLabelText at the top is cleared, making way for whichever new string matches the condition. `Change_win_text` holds the string to be displayed across, appending the new message onto the node.
```sh
##changing text	
func change_win_text(message: String):
	win_lose_text.clear()
	win_lose_text.append_text(message)
	
	
func change_button_text(message:String):
	_button = cont_button
	_button.text = (message)
	
func on_win():
	self.show()
	change_win_text("[center]BATTLE COMPLETE[/center]")
	change_button_text("CONTINUE?")
	update_exp()
	
func on_lose():
	self.show()
	#win_lose_text = flavor_text
	change_win_text("[center]BATTLE LOST[/center]")
	change_button_text("RETRY")

```
<br>

`update_exp` starts by first storing how many player battlers are left on the field, this is stored in an array. Once that's taken care of, the function checks the childcount of a grid container in the scene, when a game is first loaded there is none but that changes with the next loop. The for loop found here counts each battler and instantiates the packed scene from earlier, this makes sure the settings between the formatting is all the same and resizes and scales based off of how many battlers are present on the field. 
```sh
func update_exp():
	var pb = get_tree().get_nodes_in_group("PlayerBattler")
	


	if exp_text_handler.get_child_count() != 0:
		for etc in exp_text_handler.get_children():
			exp_text_handler.remove_child(etc)
			etc.queue_free()
	
	for i in pb.size():
		var exp_text = exp_label.instantiate()
		pb[i].gain_exp(Global.total_enemy_exp)
		exp_text_handler.add_child(exp_text)
		exp_text.text = ("%s lv. %s, current exp: %s, exp req: %s" %[pb[i].stats_resource.char_name, pb[i].level, pb[i].current_exp, pb[i].exp_required])
	return
	
```
`cont_pressed` is what occurs when the continue button is pressed. The whole scene's visibility is toggled off and emits the `Global.init_battle` signal, continuing the loop of creating a battle and finishing one.
```sh
##showing visibility
func cont_pressed():
	self.hide()
	Global.emit_signal("init_battle")

```

# Stats, Resources and Battlers

## Battler Stats Resource
```sh
class_name BattlerStats
extends Resource


enum BattlerType{
	Enemy, Player
}

@export_category("Battler Info")
@export var type: BattlerType
@export var char_name: String
@export var max_hp : int

@export var turn_speed : int 

@export_category("Battler Stats")
@export var attack : int
@export var defense : int
@export var magic: int
@export var unity: int
@export var intelligence: int
@export var style: int

@export_category("Player Stats")
@export var max_mp: int
@export var defending: bool
@export var base_lvl: int
@export var experience: int
#
@export var spell_slots: Movepool

func cast():
	pass
```

## Battler Scripts
"Battlers" in this case is defined by any character on the battle field, player or not.
Each Battler is sorted into different global node groups: 
- "PlayerBattler"
- "EnemyBattler"

<br>
These battlers share a lot in common functionality-wise, thus they'll be covered in one section. Each battler has a single script reused for each of their type, each has an exported BattlerStats resource to be interchanged with each other, a progress bar, a focus cursor and an animation player. I'll go more in depth on what they have in common before diverging into how they differ.
<br>

Taken from `enemy_battler.gd`
<br>
Once ready is called, the stats_resource's max_hp is assigned to the scripts `current_hp`, to be referenced later. Along with that, the turn is paused. The select cursor is no longer present, and the animation is set to the default. The progress bar is a visual representation of the HP, assigning the current_hp as the current value, and the max_hp as it's maximum value.

```sh
func _ready():
	select_target_button.hide()
	stop_turn()
	current_hp = stats_resource.max_hp
	_update_progress_bar()

	
func _update_progress_bar() -> void:
	progress_bar.max_value = stats_resource.max_hp
	progress_bar.value = current_hp
	
func stop_turn() -> void:
	unfocus()
	animation_player.play("RESET")

func start_turn() -> void:
	focus()	
	await get_tree().create_timer(0.3).timeout
	play_attack_anim()
	await get_tree().create_timer(0.6).timeout
	deal_damage.emit(_get_attack_damage())
	
func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()

```
Basic attacks work as follows. The damage label attached to the scene is shown and hidden, the amount the battler takes is passed on as an interger when the function is called. From there, the amount taken from damage is lessened by the stats_resource's `defense` stat. When a battler's current_hp stat is 0, it'll emit a `dead` local signal, which is listened for in the `Battle_Manager`.

```sh
func play_attack_anim():
	animation_player.play("Attack")
	
func play_hit_anim():
	animation_player.play("Hurt")

func _get_attack_damage() -> int:
	return round(stats_resource.attack * 1.5)
	

func take_damage(amount: int)-> void:
	dmg_label.show()
	await get_tree().create_timer(0.6).timeout	
	dmg_label.hide()
	
	current_hp -= (amount - stats_resource.defense)
	
	print(current_hp)
	if current_hp <=0:
		current_hp = 0
		dead.emit(self)
	_update_progress_bar()

```
The main difference between Enemy and Player Battlers is three key things:
- defending
- magic
- experience

<br>
All the above listed, the enemy lacks. Magic in this project relies on a stamina system. Along with HP the Player Battlers need to manage their mana in order to effectively clear a level. The `Global.casted` signal is emitted when any of the spell buttons with `SpellData` attached is pressed.
```sh
func _ready():
	
	Global.casted.connect(_cast_spell)
	stop_turn()
	current_hp = stats_resource.max_hp
	current_mp = stats_resource.max_mp
	
	_update_progress_bar()

func _update_progress_bar() -> void:
	hp_bar.max_value = stats_resource.max_hp
	hp_bar.value = current_hp
	mana_bar.max_value = stats_resource.max_mp
	mana_bar.value = current_mp
```
<br>

Casting a spell works very similarly to attacks, except the Spelldata for a magical attack is passed across scripts instead of referencing the stats_resource directly.
What the `Global.casted(SpellData)` does is store data that's attached to the node and emits that object for `Player_Battler`'s `_cast_spell` to reference and use. The callable used here pulls a random interger from two different numbers and has that be an attack roll, as opposed to having a set amount of damage for a basic attack.
```sh
func start_blasting(enemy_target: Node2D) -> void:
	
	await get_tree().create_timer(0.3).timeout
	play_attack_anim()
	await get_tree().create_timer(0.6).timeout
	enemy_target.play_hit_anim()
	await get_tree().create_timer(0.6).timeout
	enemy_target.take_damage(sp_damage)
	await get_tree().create_timer(0.6).timeout
	turn_ended.emit()
	
func _cast_spell(spell: SpellData) -> int:
	sp_damage =	spell.spell_behaviour.get_spell_perform()
	return sp_damage
```
<br>

Found in `spell_buttons.gd`
```sh
extends Button
class_name Spell_button

@export var spell: SpellData

func _ready() -> void:
	pass
	
func _cast_spell():
	if spell:
		Global.casted.emit(spell)
		spell.cast(Global.current_turn)
		Global.emit_signal("choose_target")
	
```

<br>

```sh
func get_level_exp(levl: int):
	return round(pow(levl, 1.8) + levl *4)
	

func gain_exp(amount: int):
	current_exp += amount
	while current_exp >= exp_required:
		stats_resource.experience -= exp_required
		level_up()

func level_up():
	level += 1
	exp_required = get_level_exp(level + 1)
	# figure out how to scale enemies to your level somehow

#func level_up_moves(lvl: int, spellname):
	#pass
```
## Spells

The component of each spell can be broken down in two pieces:
- SpellData
- SpellBehaviour

<br>
`SpellData` carries the behaviour and spell name, basically. It's a container for something more complicated for ease of access.
```sh
extends Resource
class_name SpellData


enum Targets{Self, Party, 
Enemy, All_Enemies}

@export var targets: int = Targets.Enemy
@export var spell_name: String
@export var spell_behaviour: SpellBehaviour

func cast(caster: Node2D):
	spell_behaviour.cast(caster)
```

<br>

`SpellBehaviour` contains:


- `get_spell_preform()`: A function to preform an attack roll, randomly pulling an interger between a range between the minimum and maximum damage. 
- `cast(battler: Node2D)`: A function to have the spell affect the user's mana by referencing the established mana_cost and taking that amount from the battler's mana.
- `cast_all(battlers: Array[Node2D])`: A currently unused casting type to use on multiple nodes. 
```sh
extends Resource
class_name SpellBehaviour

enum SpellType{
	Healing, Damaging
}



@export var type: SpellType
@export var spell_name: String
@export var min_roll: int
@export var max_roll: int

@export var mana_cost: int

func get_spell_perform() -> int:
	randomize()
	 
	return randi_range(min_roll, max_roll)

func cast(battler: Node2D):
	if mana_cost <= battler.current_mp:
		battler.current_mp -= mana_cost
		

func cast_all(battlers: Array[Node2D]):
	for b in battlers:
		match SpellType:
			SpellType.Healing:
				b.current_hp += get_spell_perform()
			SpellType.Damaging:
				b.current_hp -= get_spell_perform()
``
