extends Resource
class_name SpellBehaviour

enum SpellType{
	Healing, Damaging
}



@export var type: SpellType
@export var spell_name: String
@export var min_roll: int
@export var max_roll: int

@export var mana_cost: int

func get_spell_perform() -> int:
	return randi_range(min_roll, max_roll)

func cast(battler: Node2D):
	
	match SpellType:
		SpellType.Healing:
			battler.current_hp += get_spell_perform()
		SpellType.Damaging:
			battler.current_hp -= get_spell_perform()

func cast_all(battlers: Array[Node2D]):
	for b in battlers:
		match SpellType:
			SpellType.Healing:
				b.current_hp += get_spell_perform()
			SpellType.Damaging:
				b.current_hp -= get_spell_perform()
