extends Node
#class_name Global
signal init_battle
signal spell_options
signal be_selected(this_target: Node2D)
signal choose_target
signal wave_complete
signal game_over

var current_turn: Node2D
var chosen_enemy: Node2D
var casting_spell: bool = false

var current_wave: int = 0
var total_enemy_exp: int = 0
