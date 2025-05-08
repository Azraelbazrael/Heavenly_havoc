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
