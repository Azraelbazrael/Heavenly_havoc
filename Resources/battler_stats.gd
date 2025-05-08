class_name BattlerStats
extends Resource


enum BattlerType{
	Enemy, Player
}

@export_category("Battler Info")
@export var type: BattlerType
@export var char_name: String
@export var max_hp : int

@export var turn_speed : int 

@export_category("Battler Stats")
@export var attack : int
@export var defense : int
@export var magic: int
@export var unity: int
@export var intelligence: int
@export var style: int

@export_category("Player Stats")
@export var max_mana: int
@export var defending: bool
@export var base_lvl: int
@export var experience: int
#
@export var spell_slots: Movepool

func cast():
	pass
