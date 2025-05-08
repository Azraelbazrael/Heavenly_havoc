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
	
