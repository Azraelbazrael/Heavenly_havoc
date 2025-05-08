extends SpellBehaviour
class_name AngelicWhim

func cast(battler: Node2D):
	if mana_cost <= battler.current_mp:
		battler.current_mp -= mana_cost
	else:
		print("spell failed!")
