extends Panel


var flavor_text: RichTextLabel
var _button: Button

@onready var win_lose_text = $"Win_lose text"
@onready var exp_text = $exp_text
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
	change_win_text("BATTLE COMPLETE")
	change_button_text("CONTINUE?")
	update_exp()
	
func on_lose():
	self.show()
	#win_lose_text = flavor_text
	change_win_text("BATTLE LOST")
	change_button_text("RETRY")

	
func update_exp():
	var pb = get_tree().get_nodes_in_group("PlayerBattler")
	exp_text.clear()
	for i in pb.size():
		pb[i].gain_exp(Global.total_enemy_exp)
		exp_text.append_text("%s lv. %s, current exp: %s, exp req: %s" %[pb[i].stats_resource.char_name, pb[i].level, pb[i].current_exp, pb[i].exp_required])
	return
	
	
##showing visibility
func cont_pressed():
	self.hide()
	Global.emit_signal("init_battle")
