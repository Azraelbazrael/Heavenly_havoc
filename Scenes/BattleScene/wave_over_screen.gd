extends Panel


var flavor_text: RichTextLabel
var _button: Button
var exp_label = preload("res://Scenes/BattleScene/exp_text.tscn")


@onready var win_lose_text = $"Win_lose text"
@onready var exp_text_handler = $exp_text
@onready var cont_button = $continue_button

func _ready() -> void:
	Global.connect("wave_complete", on_win)
	Global.connect("game_over", on_lose)
	cont_button.pressed.connect(cont_pressed)
	
##changing text	
func change_win_text(message: String):
	win_lose_text.clear()
	win_lose_text.append_text(message)
	
	
func change_button_text(message:String):
	_button = cont_button
	_button.text = (message)
	
func on_win():
	self.show()
	change_win_text("[center]BATTLE COMPLETE[/center]")
	change_button_text("CONTINUE?")
	update_exp()
	
func on_lose():
	self.show()
	#win_lose_text = flavor_text
	change_win_text("[center]BATTLE LOST[/center]")
	change_button_text("RETRY")

	
func update_exp():
	var pb = get_tree().get_nodes_in_group("PlayerBattler")
	


	if exp_text_handler.get_child_count() != 0:
		for etc in exp_text_handler.get_children():
			exp_text_handler.remove_child(etc)
			etc.queue_free()
	
	for i in pb.size():
		var exp_text = exp_label.instantiate()
		pb[i].gain_exp(Global.total_enemy_exp)
		exp_text_handler.add_child(exp_text)
		exp_text.text = ("%s lv. %s, current exp: %s, exp req: %s" %[pb[i].stats_resource.char_name, pb[i].level, pb[i].current_exp, pb[i].exp_required])
	# append_text("%s lv. %s, current exp: %s, exp req: %s" %[pb[i].stats_resource.char_name, pb[i].level, pb[i].current_exp, pb[i].exp_required])
	return
	
	
##showing visibility
func cont_pressed():
	self.hide()
	Global.emit_signal("init_battle")
