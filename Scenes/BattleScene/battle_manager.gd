extends Node2D

@export var stats_resource : BattlerStats
@onready var turn_action_buttons: VBoxContainer = $CanvasLayer/choice
@onready var attack_button: Button = $CanvasLayer/choice/attack
@onready var defend_button: Button = $CanvasLayer/choice/defend
@onready var spell_button: Button = $CanvasLayer/choice/spell


@onready var textbox: MarginContainer = $CanvasLayer/textbox
@onready var textbox_text: RichTextLabel = $CanvasLayer/textbox/text/RichTextLabel
@onready var spell_options: GridContainer = $CanvasLayer/textbox/text/SpellOptions




@onready var player_status_text: Label = $CanvasLayer/hp_boxes/hp_text
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player_battlers = [] 
@onready var enemy_battlers = [] 


#var text_boxes = preload("res://Scenes/exp_textbox.tscn")
var enemy_scene = preload("res://Scenes/NotMilesEdgeworth/enemy_battler.tscn")
var all_battlers = []
var current_spells = []

#@onready var wave_check: Label = $CanvasLayer/wave_check/wave_text


var current_turn_index: int
var ready_completed: bool


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

	
func attack_random_player_battler(damage: int) -> void:
	var rand = randi_range(0, player_battlers.size() - 1)
	
	player_battlers[rand].play_hit_anim()
	await get_tree().create_timer(0.6).timeout
	player_battlers[rand].take_damage(damage)
	player_battlers[rand].dmg_label._update_text(damage)
	await get_tree().create_timer(0.1).timeout
	_next_turn()

func _defending_turn():
	_defending(Global.current_turn)

func _defending(current_player: Node2D) -> void:
	current_player.stats_resource.defending = true
	_show_flavor_text("%s defends themselves!" %[current_player.stats_resource.char_name])
	_next_turn()
	
func _no_longer_defending():
	Global.current_turn.stats_resource.defending = false
	
	
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
	
func _show_flavor_text(message: String) -> void:
	textbox_text.clear()
	textbox_text.append_text(message)
	textbox_text.show()

	

	
