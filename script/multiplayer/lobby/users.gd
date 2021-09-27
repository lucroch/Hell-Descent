extends Node2D

# NODES

onready var room = get_parent().get_node("Room")

# RESOURCES

var button_style = preload("res://style/selected_menu.tres")
var friend_character = preload("res://scene/character/Friend.tscn")
var player_character = preload("res://scene/character/Player.tscn")
var player # Player instance

# WHEN PLAYER ENTERS THE LOBBY

func _spawn_friend(player_id, player_position) -> void:
	if player_id != Steamworks.STEAM_ID and !get_node_or_null(str(player_id)):
		var player_name: String = Steam.getFriendPersonaName(player_id)
		var new_player = friend_character.instance()
		new_player.position = player_position
		new_player.set_name(str(player_id))
		new_player.get_node("Name").set_text(str(player_name))
		self.add_child(new_player)

# SPAWNS YOUR PLAYER

func _spawn_player(spawn: Vector2) -> void:
	player = player_character.instance()
	player.position = spawn
	player.set_name("Player")
	player.get_node("Name").set_text(Steamworks.STEAM_USERNAME)
	self.add_child(player)
