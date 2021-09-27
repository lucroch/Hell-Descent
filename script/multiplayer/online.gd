extends Node

var join_attempt: int = 0 # Attempts at joining a lobby

onready var start_scene = preload("res://scene/main/Start.tscn")
onready var hall_scene = preload("res://scene/main/Hall.tscn")
onready var lobby_scene = preload("res://scene/main/Lobby.tscn")
onready var loading_scene = preload("res://scene/main/Loading.tscn")

var server: String = "Lobby/Interface/GUI/Board/ServerName"
var gui: String = "Lobby/Interface/GUI"
var server_name: String

var hall
var lobby
var loading

enum host {Owner, Client}
var status

func _ready():
	
	# CREATES HALL NODE
	var hall_instance = hall_scene.instance()
	add_child(hall_instance)
	hall = hall_instance
	
	# SETS UP SIGNALS
	Steam.connect("lobby_created", self, "_on_lobby_created")
	Steam.connect("lobby_match_list", self, "_on_lobby_match_list")
	Steam.connect("lobby_joined", self, "_on_lobby_joined")
	Steam.connect("lobby_chat_update", self, "_on_lobby_update")
	Steam.connect("lobby_message", self, "_on_lobby_message")
	Steam.connect("lobby_invite", self, "_on_lobby_invite")
	Steam.connect("join_requested", self, "_on_lobby_join_requested")
	Steam.connect("p2p_session_request", self, "_on_p2p_request")
	Steam.connect("p2p_session_connect_fail", self, "_on_p2p_connect_fail")

func _process(_delta) -> void:
	get_input()

func get_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if lobby != null:
			_leave_lobby()
		elif hall != null:
			scene_switch("start")

# CHANGES BETWEEN ONLINE SCENES

func scene_switch(to: String) -> void:
	match to:
		"start":
			get_tree().change_scene_to(start_scene)
		"lobby":
			lobby = _change(hall, lobby_scene)
			hall = null
		"hall":
			hall = _change(lobby, hall_scene)
			lobby = null

func _change(root, path: PackedScene):
	root.call_deferred("free")
	var scene_instance = path.instance()
	add_child(scene_instance)
	return scene_instance

func _loading_screen(called):
	if called:
		var loading_instance = loading_scene.instance()
		lobby.add_child(loading_instance)
		loading = loading_instance
	else:
		if loading:
			loading.call_deferred("free")
		loading = null

func loading_message(message):
	loading.get_node("Text").bbcode_text = "[center][wave]"+message
	
# SERVER MESSAGE

func message(msg):
	if lobby:
		lobby.output(msg)

# WHEN YOU SUCCESSFULLY CREATED A LOBBY

func _on_lobby_created(connect: int, lobbyID: int) -> void:
	if connect == 1:
		_lobby_set_info(lobbyID)

func _lobby_set_info(lobbyID: int) -> void:
	
	# Set the lobby ID
	Steamworks.STEAM_LOBBY_ID = lobbyID
	Steamworks.LOBBY_OWNER = Steam.getLobbyOwner(Steamworks.STEAM_LOBBY_ID)
	get_node(server).set_text(server_name)
	
	# Set some lobby data
	Steam.setLobbyData(lobbyID, "name", get_node(server).get_text())
	Steam.setLobbyData(lobbyID, "mode", "GodotSteam")
	
	# Allow P2P connections to fallback to being relayed through Steam if needed
	var IS_RELAY: bool = Steam.allowP2PPacketRelay(true)
	
	# Makes your player
	_loading_screen(false)

# GETTING LIST OF LOBBIES AVAILABLE

func _on_lobby_match_list(lobbies: Array) -> void:
	# Show the list
	if hall:
		hall._add_lobbylist(lobbies)

# WHEN A LOBBY IS JOINED

func _on_lobby_joined(lobbyID: int, _permissions: int, _locked: bool, _response: int) -> void:
	
	# Set this lobby ID as your lobby ID
	Steamworks.STEAM_LOBBY_ID = lobbyID
	join_attempt += 1
	Steamworks.LOBBY_OWNER = Steam.getLobbyOwner(Steamworks.STEAM_LOBBY_ID)
	
	_lobby_get_info(lobbyID)
	
	if Steamworks.STATUS == host.Owner:
		lobby._generate_player(lobby.spawn.get_position())

func _lobby_get_info(lobbyID):
	
	var name: String = Steam.getLobbyData(lobbyID, "name")
	
	# Get the lobby members
	if lobby._get_lobby_members():
		
		join_attempt = 0
		message("[STEAM] Joined lobby '"+name+"'.\n")
		get_node(server).set_text(str(name))
		_p2p_handshake()
	
	# If player is not identified, attempts to join 5 more times.
	else:
		if join_attempt >= 5:
			join_attempt = 0
			_leave_lobby()
		else:
			Steamworks.STEAM_LOBBY_ID = 0
			Steam.leaveLobby(Steamworks.STEAM_LOBBY_ID)
			for MEMBER in Steamworks.LOBBY_MEMBERS:
				Steam.closeP2PSessionWithUser(MEMBER['steam_id'])
			_join_lobby(lobbyID)

# WHEN YOU ACCEPT A STEAM INVITE

func _on_lobby_join_requested(lobbyID: int, friendID: int) -> void:
	
	# Get the lobby owner's name
	var OWNER_NAME = Steam.getFriendPersonaName(friendID)
	message("[STEAM] Joining "+str(OWNER_NAME)+"'s lobby...\n")
	
	# Attempt to join the lobby
	_join_lobby(lobbyID)

# WHEN A LOBBY MESSAGE IS SENT

func _on_lobby_message(_result: int, user: int, message: String, _type: int) -> void:
	# We are only concerned with who is sending the message and what the message is
	var SENDER = Steam.getFriendPersonaName(user)
	message(str(SENDER)+": "+message+"\n")

# EVERY TIME THE LOBBY UPDATES

func _on_lobby_update(lobbyID: int, changedID: int, makingChangeID: int, chatState: int) -> void:
	
	# Note that chat state changes is: 1 - entered, 2 - left, 4 - user disconnected before leaving
	# 8 - user was kicked, 16 - user was banned
	message("[STEAM] lobby ID: "+str(lobbyID)+", Changed ID: "+str(changedID)+
	", Making Change: "+str(makingChangeID)+", Chat State: "+str(chatState)+"\n")
	var CHANGER = Steam.getFriendPersonaName(makingChangeID)
	
	if chatState == 1: # If a player has joined the lobby
		message("[STEAM] "+str(CHANGER)+" has joined the lobby.\n")
		_p2p_handshake()
		if Steamworks.STATUS == host.Owner:
			_p2p_init(makingChangeID)
	elif chatState == 2: # Else if a player has left the lobby
		message("[STEAM] "+str(CHANGER)+" has left the lobby.\n")
		lobby._remove_player(makingChangeID)
	elif chatState == 8: # Else if a player has been kicked
		message("[STEAM] "+str(CHANGER)+" has been kicked from the lobby.\n")
		lobby._remove_player(makingChangeID)
	elif chatState == 16: # Else if a player has been banned
		message("[STEAM] "+str(CHANGER)+" has been banned from the lobby.\n")
		lobby._remove_player(makingChangeID)
	else: # Else there was some unknown change
		message("[STEAM] "+str(CHANGER)+" did... something.\n")
	
	# Update the lobby now that a change has occurred
	if lobby:
		lobby._get_lobby_members()

# ACCEPTS STEAM P2P SESSION REQUESTS FROM THE HOST

func _on_p2p_request(remoteID: int) -> void:
	
	# Get the requester's name
	var REQUESTER: String = Steam.getFriendPersonaName(remoteID)
	
	# Print the debug message to output
	message("[STEAM] P2P session request from "+str(REQUESTER)+"\n")
	print("Session request from "+str(REQUESTER))
	
	# Accept the P2P session; can apply logic to deny this request if needed
	Steam.acceptP2PSessionWithUser(remoteID)
	
	# Make the initial handshake
	_p2p_handshake()

# WHAT TO DO IN EACH SESSION ERROR

func _on_p2p_connect_fail(lobbyID: int, session_error: int) -> void:
	
	# If no error was given
	if session_error == 0: 
		message("[WARNING] Session failure with "+str(lobbyID)+" [no error given].\n")
	
	# If target user was not running the same game
	elif session_error == 1: 
		message("[WARNING] Session failure with "+str(lobbyID)+" [target user not running the same game].\n")
	
	# If local user doesn't own app / game
	elif session_error == 2:
		message("[WARNING] Session failure with "+str(lobbyID)+" [local user doesn't own app / game].\n")
	
	# If target user isn't connected to Steam
	elif session_error == 3: 
		message("[WARNING] Session failure with "+str(lobbyID)+" [target user isn't connected to Steam].\n")
	
	#  If connection timed out
	elif session_error == 4:
		message("[WARNING] Session failure with "+str(lobbyID)+" [connection timed out].\n")
		
	# If unused
	elif session_error == 5:
		message("[WARNING] Session failure with "+str(lobbyID)+" [unused].\n")
	
	# Else no known error
	else:
		message("[WARNING] Session failure with "+str(lobbyID)+" [unknown error "+str(session_error)+"].\n")

# REQUIRED FOR MEMBER CONNECTION

func _p2p_handshake() -> void:
	message("[STEAM] Sent a P2P handshake to the lobby.\n")
	P2P._send_packet(0, "all", P2P.SEND.reliable, [
		P2P.TYPE.handshake
	])

func _p2p_init(id) -> void:
	P2P._send_packet(0, str(id), P2P.SEND.reliable, [
		P2P.TYPE.spawn,
		lobby.spawn.get_position()
	])
	print("Sent information to "+str(id))

# FUNCTION FOR JOINING A LOBBY

func _join_lobby(lobbyID: int) -> void:
	if Steamworks.STEAM_LOBBY_ID == 0:
		
		Steamworks.STATUS = host.Client # Identifies you as a client
		
		Steam.joinLobby(lobbyID)
		if !lobby:
			scene_switch("lobby")
		if !loading:
			_loading_screen(true)
			loading_message("Joining lobby...")

# WHEN A LOBBY IS CREATED BY YOU

func _create_lobby(text: String) -> void:
	if Steamworks.STEAM_LOBBY_ID == 0:
		
		Steamworks.STATUS = host.Owner # Identifies you as the owner of the lobby
		
		server_name = text
		Steam.createLobby(2, 20)
		scene_switch("lobby")
		_loading_screen(true)
		loading_message("Creating lobby...")

# FUNCTION FOR LEAVING THE LOBBY

func _leave_lobby() -> void:
	
	if loading:
		_loading_screen(false)
	# If in a lobby, leave it
	if Steamworks.STEAM_LOBBY_ID != 0:
		
		message("[STEAM] Leaving lobby "+str(Steamworks.STEAM_LOBBY_ID)+".\n")
		Steam.leaveLobby(Steamworks.STEAM_LOBBY_ID)
		Steamworks.STEAM_LOBBY_ID = 0
		
		# Close session with all users
		for MEMBER in Steamworks.LOBBY_MEMBERS:
			Steam.closeP2PSessionWithUser(MEMBER['steam_id'])
		
		# Clear the local lobby list
		Steamworks.LOBBY_MEMBERS.clear()
		Steamworks.MEMBER_LIST.clear()
		Steamworks.MEMBER_ID = 0
		
		scene_switch("hall")
