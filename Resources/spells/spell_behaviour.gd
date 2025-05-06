extends Node2D
class_name SpellBehaviour

@export var spell_name: String
@export var min_roll: int
@export var max_roll: int

@export var mana_cost: int


func get_spell_perform() -> int:
	return randi_range(min_roll, max_roll)

func cast(battler: Node2D):
	pass
	

	#match SpellData.SpellType:
		#SpellType.Healing:
			#Battler.current_hp += get_spell_perform()
		#SpellType.Damaging:
			#B#attler.current_hp -= get_spell_perform()
	#print(caster.current_hp)
