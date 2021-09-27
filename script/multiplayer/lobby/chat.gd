extends Panel

onready var type = $Type

var lobby = get_parent()

func _on_Type_text_entered(new_text):
	
	# Get the entered chat message
	var MESSAGE: String = type.get_text()
	
	if new_text.length() != 0:
		
		# Pass the message to Steam
		var IS_SENT: bool = Steam.sendLobbyChatMsg(Steamworks.STEAM_LOBBY_ID, MESSAGE)
		
		# Was it sent successfully?
		if not IS_SENT:
			lobby.output("[ERROR] Chat message failed to send.\n")
		
		# Clear the chat input
		type.clear()
