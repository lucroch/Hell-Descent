extends Panel

onready var online = get_node("../..")
onready var edit = $Setup/Name/Edit

func _on_Button_button_up():
	if edit.text.length() > 1:
		online._create_lobby(edit.text)
		edit.clear()

func _on_Edit_text_entered(new_text):
	_on_Button_button_up()
