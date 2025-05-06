extends Label


func update_text(char_name, lvl, expee, req_exp):
	text = """ %s lv. %s
	Exp: %s
	Required Exp: %s
	""" % [char_name, lvl,expee, req_exp]
