extends Button
class_name Spell_button

@export var spell: SpellData

func _ready() -> void:
	pass
	
func _cast_spell():
	if spell:
		spell.cast(Global.current_turn)
		Global.emit_signal("choose_target")
	


func _on_pressed() -> void:	
	_cast_spell()
			
	
