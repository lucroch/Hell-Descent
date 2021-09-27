extends Control

# SCENES

var online = "res://scene/main/Online.tscn"

# MENU BUTTONS

onready var b_solo = $Options/New
onready var b_online = $Options/Online
onready var b_settings = $Options/Settings
onready var font_color = "custom_colors/font_color"
	
# NEW BUTTON

func _on_New_button_up():
	pass
func _on_New_mouse_entered():
	b_solo.grab_focus()
func _on_New_focus_entered():
	b_solo.set(font_color, Color.black)
func _on_New_focus_exited():
	b_solo.set(font_color, Color.white)

# ONLINE BUTTON

func _on_Online_button_up():
	get_tree().change_scene(online)
func _on_Online_mouse_entered():
	b_online.grab_focus()
func _on_Online_focus_entered():
	b_online.set(font_color, Color.black)
func _on_Online_focus_exited():
	b_online.set(font_color, Color.white)

# SETTINGS BUTTON

func _on_Settings_button_up():
	pass
func _on_Settings_mouse_entered():
	b_settings.grab_focus()
func _on_Settings_focus_entered(): 
	b_settings.set(font_color, Color.black)
func _on_Settings_focus_exited():
	b_settings.set(font_color, Color.white)
