extends Node

onready var lobbylist = $Servers/Scroll/VBox
var LobbyButton: PackedScene = preload("res://scene/packed/LobbyButton.tscn")

func _ready():
	_open_lobbylist()

func _open_lobbylist():
	Steam.addRequestLobbyListDistanceFilter(3)
	Steam.addRequestLobbyListStringFilter("mode", "GodotSteam", 0)
	for n in lobbylist.get_children():
		n.queue_free()
	Steam.requestLobbyList()

func _add_lobbylist(lobbies) -> void:
	
	for LOBBY in lobbies:
		# Pull lobby data from Steam
		var LOBBY_NAME: String = Steam.getLobbyData(LOBBY, "name")
		var LOBBY_MODE: String = Steam.getLobbyData(LOBBY, "mode")
		var LOBBY_NUMBER: int = Steam.getNumLobbyMembers(LOBBY)
		
		# Name it untitled
		if LOBBY_NAME == "":
			LOBBY_NAME = "Untitled"
		
		# Create a button for the lobby
		var LOBBY_BUTTON = LobbyButton.instance()
		var _connection = LOBBY_BUTTON.connect("pressed", get_parent(), "_join_lobby", [LOBBY])
		
		# Add the new lobby to the list
		lobbylist.add_child(LOBBY_BUTTON)
		LOBBY_BUTTON.set_server(str(LOBBY_NAME))
		LOBBY_BUTTON.set_players(str(LOBBY_NUMBER) + "/20")
		LOBBY_BUTTON.set_mode(str(LOBBY_MODE))
		LOBBY_BUTTON.set_name("lobby_"+str(LOBBY))
