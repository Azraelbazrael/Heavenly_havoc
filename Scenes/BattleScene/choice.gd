extends VBoxContainer
@onready var choice_buttons = get_children()
@onready var attack_button: Button = $attack
@onready var spell_button: Button = $spell
@onready var defend_button: Button = $defend


func _on_attack_pressed() -> void:
	Global.emit_signal("choose_target")


func _on_defend_pressed() -> void:
	pass # Replace with function body.


func _on_spell_pressed() -> void:
	pass # Replace with function body.


func _on_party_pressed() -> void:
	pass # Replace with function body.
