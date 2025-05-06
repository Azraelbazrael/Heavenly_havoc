extends Label
func _show_hp_text(current_char_name, current_lvl, current_hp, max_hp, current_mp, max_mp):
	text = """%s lv.%s
	HP: %s/%s
	MP: %s/%s""" %[current_char_name, current_lvl, current_hp, max_hp, current_mp, max_mp]
	## Have this eventually include name and MP
	
