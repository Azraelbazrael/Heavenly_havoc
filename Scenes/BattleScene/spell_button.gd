extends Button
class_name Spell_button

@export var spell: SpellData

func _ready() -> void:
	pass
	
func _cast_spell():
	match spell.Targets:
		spell.Targets.Self:
			spell.cast(Global.current_turn)
		spell.Targets.Party:
			spell.cast_all(get_tree().get_nodes_in_group("PlayerBattler"))
		spell.Targets.Enemy:
			spell.cast(Global.chosen_enemy)
		spell.Target.All_enemies:
			spell.cast_all(get_tree().get_nodes_in_group("EnemyBattler"))
