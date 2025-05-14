extends Node2D

#@export var spells: Array[SpellData]
@export var stats_resource : BattlerStats
@onready var hp_bar = $ProgressBar
@onready var mana_bar = $ProgressBar2
@onready var animation_player = $AnimationPlayer
@onready var _focus = $Focus
@onready var Enemy_targets: Node2D

@onready var level: int = stats_resource.base_lvl
@onready var current_exp: int = stats_resource.experience

@onready var dmg_label: Label = $dmg_label


var current_hp : int
var current_mp: int
var sp_damage: int
var exp_required = get_level_exp(level +1)
#var enemy_battlers = []
signal dead(this_battler: Node2D)
signal turn_ended

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
		
func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()
	
func start_turn() -> void:
	focus()
	
func stop_turn() -> void:
	animation_player.play("RESET")
	unfocus()
	


## Attacks start here
func start_attacking(enemy_target: Node2D) -> void:
	
	await get_tree().create_timer(0.3).timeout
	play_attack_anim()
	await get_tree().create_timer(0.6).timeout
	enemy_target.play_hit_anim()
	await get_tree().create_timer(0.6).timeout
	enemy_target.take_damage(_get_attack_damage())
	await get_tree().create_timer(0.6).timeout
	turn_ended.emit()

	
func play_attack_anim():
	animation_player.play("Attack")
	
func play_hit_anim():
	animation_player.play("Hurt")

func _get_attack_damage() -> int:
	return round( 1.5 * stats_resource.attack)

	
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

func _show_label():
	dmg_label.show()
	await get_tree().create_timer(0.6).timeout	
	dmg_label.hide()
	
func take_damage(amount: int)-> void:
	
	if stats_resource.defending == true:
		current_hp -= round(amount - stats_resource.defense * 1.2)
	else:
		current_hp -= round(amount - stats_resource.defense)
	
	_show_label()
	
	if current_hp <=0:
		current_hp = 0
		visible = false
		dead.emit(self)
		queue_free()
	_update_progress_bar()
	
## Level experience	

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
