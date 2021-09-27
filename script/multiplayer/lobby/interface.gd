extends CanvasLayer

# NODES

onready var board = $GUI/Board
onready var chat = $GUI/Chat
onready var type = $GUI/Chat/Type
onready var playerlist = $GUI/Board/Members

var button_style = preload("res://resource/ButtonText.tres")

# UI INPUT RECEIVING

func _process(_delta) -> void:
	get_input()

func get_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		show_chat()
	if Input.is_action_pressed("ui_board"):
		board.show()
	else:
		board.hide()

# SHOW/HIDE CHAT AND PLAYER LIST

func show_chat() -> void:
	if !type.has_focus():
		chat.show()
		type.placeholder_text = "Send a message"
		type.grab_focus()
	else:
		type.placeholder_text = ""
		type.release_focus()

# ADDS PLAYERS WHEN JOINING A LOBBY

func _add_playerlist(steam_id: int, steam_name: String) -> void:
	Steamworks.LOBBY_MEMBERS.append({"steam_id":steam_id, "steam_name":steam_name})
	_member_button(steam_name)

# CREATES PLAYER BUTTON

func _member_button(steam_name) -> void:
	var PLAYER_BUTTON: Button = Button.new()
	PLAYER_BUTTON.set_text(str(steam_name))
	PLAYER_BUTTON.set_text_align(1)
	PLAYER_BUTTON.set_flat(true)
	PLAYER_BUTTON.set("custom_fonts/font", button_style)
	PLAYER_BUTTON.set("custom_styles/normal", StyleBoxEmpty.new())
	PLAYER_BUTTON.set("custom_styles/pressed", StyleBoxEmpty.new())
	PLAYER_BUTTON.set("custom_colors/font_color", Color.white)
	PLAYER_BUTTON.enabled_focus_mode = false
	playerlist.add_child(PLAYER_BUTTON)
