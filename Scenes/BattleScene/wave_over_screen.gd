extends Panel


var flavor_text: RichTextEffect
var cont_button: Button
@onready var win_lose_text = $"Win_lose text"

func _ready() -> void:
	pass

##changing text	
func change_win_text(message: String):
	flavor_text.clear()
	flavor_text.append_text(message)
	
	
func change_button_text(message:String):
	pass
	#cont_button.text.clear()
	#cont_button.append_text(message)
	
func on_win():
	win_lose_text = flavor_text
	change_win_text("BATTLE COMPLETE")
	change_button_text("CONTINUE?")
	update_exp()
	return
	
func on_lose():
	win_lose_text = flavor_text
	change_win_text("BATTLE LOST")
	change_button_text("RETRY")
	return
	
func update_exp():
	var pbattlers = get_tree().get_nodes_in_group("PlayerBattler")
	for pb in pbattlers.size():
		pb[i].gain_exp(exp_earned)
		exp_text.append_text("%s lv. %s, current exp: %s, exp req: %s" %[pb[i].stats_resource.char_name, pb[i].level, pb[i].current_exp, pb[i].exp_required])
##showing visibility

func show_screen():
	pass

func hide_screen_():
	pass
	
