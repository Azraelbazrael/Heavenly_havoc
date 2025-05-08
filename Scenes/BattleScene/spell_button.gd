extends Button
class_name Spell_button

@export var spell: SpellData

func _ready() -> void:
	pass
	
func _cast_spell():
	match spell.targets:
		spell.Targets.Self:
			spell.cast(Global.current_turn)
		spell.Targets.Party:
			spell.cast_all(get_tree().get_nodes_in_group("PlayerBattler"))
		spell.Targets.Enemy:
			Global.emit_signal("choose_target")
		
		spell.Targets.All_Enemies:
			spell.cast_all(get_tree().get_nodes_in_group("EnemyBattler"))
	


func _on_pressed() -> void:	
	_cast_spell()
			
	
