class_name BattlerStats
extends Resource


enum BattlerType{
	Enemy, Player
}

@export var type: BattlerType
@export var char_name: String
@export var max_hp : int

@export var turn_speed : int 


@export var attack : int
@export var defense : int
@export var magic: int
@export var unity: int
@export var intelligence: int
@export var style: int

@export var max_mana: int
@export var defending: bool
@export var base_lvl: int
@export var experience: int
#
@export var spell_slots: Movepool
#@export var spell_list: SpellBehaviour
