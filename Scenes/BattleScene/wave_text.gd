extends Label
class_name Wave_text

func _ready() -> void:
	Global.connect("wave_complete", update_text)

func update_text():
	text = "wave %s" % [Global.current_wave]
