extends Node

# NODES

onready var online = get_parent()
onready var users = $Users # All characters
onready var spawn = $Room/Spawn
onready var interface = $Interface
onready var playerlist = $Interface/GUI/Board/Members
onready var chat = $Interface/GUI/Chat/Output

# CONSTANT PACKET READING WHILE IN A LOBBY

func _process(_delta):
	if Steamworks.STEAM_LOBBY_ID != 0:
		for index in range(0, Steam.getNumLobbyMembers(Steamworks.STEAM_LOBBY_ID)+1):
			if index != P2P.CHANNEL:
				P2P._read_packet(index)

# SENDS MESSAGE TO THE CHAT

func output(text: String) -> void:
	chat.append_bbcode(text)

# GET THE LOBBY MEMBERS FROM STEAM

func _get_lobby_members():
	
	var PREVIOUS_MEMBERS = Steamworks.LOBBY_MEMBERS
	
	# Clear your previous lobby list
	Steamworks.LOBBY_MEMBERS.clear()
	_clear_playerlist()
	
	# Get the number of members from this lobby from Steam
	var NUM_MEMBERS: int = Steam.getNumLobbyMembers(Steamworks.STEAM_LOBBY_ID)
	var _ACTUAL_LOBBY = Steamworks.STEAM_LOBBY_ID
	print(Steamworks.LOBBY_OWNER)
	
	# Get the data of these players from Steam
	for MEMBER in range(0, NUM_MEMBERS):
		
		var MEMBER_STEAM_ID: int = Steam.getLobbyMemberByIndex(Steamworks.STEAM_LOBBY_ID, MEMBER)
		var MEMBER_STEAM_NAME: String = Steam.getFriendPersonaName(MEMBER_STEAM_ID)
		
		# Attempts to join 5 times if the usernames are undetified
		if MEMBER_STEAM_NAME == "":
			return false
		
		print("CHANNEL " + str(MEMBER+1) + ": " + MEMBER_STEAM_NAME)
		
		if MEMBER_STEAM_ID == Steamworks.STEAM_ID:
			P2P.CHANNEL = MEMBER+1
		
		# Add them to the player list
		interface._add_playerlist(MEMBER_STEAM_ID, MEMBER_STEAM_NAME)
	return true

# CREATES YOUR PLAYER

func _generate_player(spawn: Vector2) -> void:
	online._loading_screen(false)
	if !users.get_node_or_null("Player"):
		users._spawn_player(spawn)

# USER  REMOVAL

func _remove_player(id) -> void:
	Steam.closeP2PSessionWithUser(id)
	if get_node_or_null("Users/"+str(id)):
		get_node("Users/"+str(id)).queue_free()
	if Steamworks.LOBBY_OWNER == id:
		online._leave_lobby()

# CLEARS PLAYERLIST

func _clear_playerlist() -> void:
	for n in playerlist.get_children():
		playerlist.remove_child(n)
		n.queue_free()
