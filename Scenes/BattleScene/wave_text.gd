extends Label
class_name Wave_text

func _ready() -> void:
	Global.connect("init_battle", update_text)

func update_text():
	Global.current_wave += 1
	text = "wave %s" % [Global.current_wave]
