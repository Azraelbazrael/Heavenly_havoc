extends Resource
class_name SpellData


enum Targets{Self, Party, 
Enemy, All_Enemies}

@export var targets: int = Targets.Enemy
@export var spell_name: String
@export var spell_behaviour: SpellBehaviour

func cast(caster: Node2D):
	spell_behaviour.cast(caster)
