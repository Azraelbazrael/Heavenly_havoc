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
