extends Button

onready var server = $HBox/Name 
onready var mode = $HBox/Mode 
onready var status = $HBox/Status 
onready var players = $HBox/Players

func set_server(value: String):
	server.set_text(value)

func set_mode(value: String):
	mode.set_text(value)

func set_status(value: String):
	status.set_text(value)

func set_players(value: String):
	players.set_text(value)

func _on_LobbyButton_mouse_entered():
	server.set("custom_colors/font_color", Color(1,1,1,1))
	mode.set("custom_colors/font_color", Color(1,1,1,1))
	status.set("custom_colors/font_color", Color(1,1,1,1))
	players.set("custom_colors/font_color", Color(1,1,1,1))

func _on_LobbyButton_mouse_exited():
	server.set("custom_colors/font_color", Color(1,1,1,0.58))
	mode.set("custom_colors/font_color", Color(1,1,1,0.58))
	status.set("custom_colors/font_color", Color(1,1,1,0.58))
	players.set("custom_colors/font_color", Color(1,1,1,0.58))
