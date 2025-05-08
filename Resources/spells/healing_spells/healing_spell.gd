extends SpellBehaviour
class_name HealingSpell

	
func cast(battler: Node2D):
	if mana_cost <= battler.current_mp:
		battler.current_mp -= mana_cost
		battler.current_hp += get_spell_perform()
	else:
		print("spell failed!")
