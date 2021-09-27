extends Node

var CHANNEL: int = 1
enum SEND {unreliable, unreliable_no_delay, reliable, reliable_with_buffering}
enum PACK {type, position, animation, direction}
enum TYPE {handshake, spawn, move}

# READING STEAM P2P packet

func _read_packet(ch) -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(ch)
	
	if packet_size > 0:
		var packet: Dictionary = Steam.readP2PPacket(packet_size, ch)
		var packet_id: String = str(packet.steamIDRemote)
		var data: Array = bytes2var(packet.data.subarray(1, packet_size - 1))
		
		_open_packet(packet_id, data)

# APPEND LOGIC FOR packet

func _open_packet(ID: String, data: Array) -> void:
	
	var lobby = get_tree().get_root().get_node_or_null("Online/Lobby")
	var users = lobby.get_node_or_null("Users/")
	var player = users.get_node_or_null("Player")
	var friend = users.get_node_or_null(ID)
	
	match data[PACK.type]:
		TYPE.spawn:
			print("Received")
			lobby._generate_player(data[PACK.position])
		TYPE.move:
			if friend: 
				friend.set_position(data[PACK.position])
				friend.set_anim(data[PACK.animation])
				friend.set_dir(data[PACK.direction])
			else:
				users._spawn_friend(int(ID), data[PACK.position])

# SENDING STEAM P2P packet

func _send_packet(chan: int, target: String, type: int, packet_data: Array) -> void:
	
	var DATA: PoolByteArray
	DATA.append(256)
	DATA.append_array(var2bytes(packet_data))
	
	if target == "all":
		if Steamworks.LOBBY_MEMBERS.size() > 1:
			for MEMBER in Steamworks.LOBBY_MEMBERS:
				if MEMBER['steam_id'] != Steamworks.STEAM_ID:
					Steam.sendP2PPacket(MEMBER['steam_id'], DATA, type, chan)
	else:
		Steam.sendP2PPacket(int(target), DATA, type, chan)
