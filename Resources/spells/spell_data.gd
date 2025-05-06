extends Node2D
class_name SpellData

enum SpellType{
	Healing, Damaging
}

@export var type: SpellType
@export var spell_name: String
@export var spell_behaviour: SpellBehaviour

func cast(caster: Node2D):
	spell_behaviour.cast(caster)
