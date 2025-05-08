extends Panel


var flavor_text: RichTextEffect
var _button: Button

@onready var win_lose_text = $"Win_lose text"
@onready var exp_text = $exp_text
@onready var cont_button = $continue_button

func _ready() -> void:
	Global.connect("init_battle", hide_screen_)
	Global.connect("wave_complete", on_win)
	Global.connect("game_over", on_lose)

##changing text	
func change_win_text(message: String):
	flavor_text.clear()
	flavor_text.append_text(message)
	
	
func change_button_text(message:String):
	_button = cont_button
	_button.text = (message)
	
func on_win():
	self.show()
	win_lose_text = flavor_text
	change_win_text("BATTLE COMPLETE")
	change_button_text("CONTINUE?")
	update_exp()
	return
	
func on_lose():
	self.show()
	win_lose_text = flavor_text
	change_win_text("BATTLE LOST")
	change_button_text("RETRY")
	return
	
func update_exp():
	var pb = get_tree().get_nodes_in_group("PlayerBattler")
	exp_text - flavor_text
	for i in pb.size():
		pb[i].gain_exp(Global.total_enemy_exp)
		change_win_text("%s lv. %s, current exp: %s, exp req: %s" %[pb[i].stats_resource.char_name, pb[i].level, pb[i].current_exp, pb[i].exp_required])
	return
	
	
##showing visibility
func hide_screen_():
	self.hide()
	
