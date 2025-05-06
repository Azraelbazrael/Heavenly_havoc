extends Node2D

@export var stats_resource : BattlerStats
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _focus: Sprite2D = $Focus
@onready var select_target_button: Button = $SelectTargetButton

@onready var dmg_label: Label = $dmg_label

var current_hp : int

signal be_selected(this_target: Node2D)
signal dead(this_enemy: Node2D)
signal deal_damage(damage: int)


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

func show_select_button():
	select_target_button.show()

func hide_select_button():
	select_target_button.hide()
	
func _on_select_target_button_pressed() -> void:
	be_selected.emit(self)	
	
## ATTACKS START HERE

	
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
