extends Panel

onready var hall = get_parent()
onready var refresh = $Refresh

# FUNCTION

func _on_Refresh_button_up():
	hall._open_lobbylist()

# VISUAL

func _on_Refresh_mouse_exited():
	refresh.set_modulate(Color(1,1,1,0.6))
func _on_Refresh_mouse_entered():
	refresh.set_modulate(Color(1,1,1,1))
