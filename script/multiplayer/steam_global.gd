extends Node

# STEAM

var IS_OWNED: bool = false
var IS_ONLINE: bool = false
var STEAM_ID: int = 0
var STEAM_USERNAME: String

# LOBBY

var STEAM_LOBBY_ID: int = 0
var LOBBY_MEMBERS: Array = []
var LOBBY_OWNER
var LOBBY_INVITE_ARG: bool = false
var MEMBER_ID = 0 
var MEMBER_LIST: Dictionary = {}
var STATUS: int

# START STEAMWORKS

func _ready():
	_initialize_Steam()

func _initialize_Steam() -> void:
	
	# ATTEMPT TO INITIALIZE STEAM
	
	var INIT: Dictionary = Steam.steamInit()
	if INIT['status'] != 1:
		OS.alert("[STEAM] Failed to initialize: "+str(INIT['verbal']), 'ERROR')
		get_tree().quit()
	
	# USER INFO
	
	IS_ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	IS_OWNED = Steam.isSubscribed()
	STEAM_USERNAME = Steam.getPersonaName()

# PROCESS ALL STEAMWORKS CALLBACKS

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	_check_command_line()

# STEAM BUILT-IN FRIEND INVITATION

func _check_command_line() -> void:
	var ARGUMENTS = OS.get_cmdline_args()
	if ARGUMENTS.size() > 0:
		for ARGUMENT in ARGUMENTS:
			# An invite argument was passed
			if LOBBY_INVITE_ARG:
				var online = load("res://scene/main/Online.tscn")
				get_tree().change_scene("res://scene/main/Online.tscn")
				online._join_lobby(int(ARGUMENT))
			# A Steam connection argument exists
			if ARGUMENT == "+connect_lobby":
				LOBBY_INVITE_ARG = true

# RETURNS AVATAR TEXTURE

func _avatar(steamID, pixels):
	
	var size = Steam.getMediumFriendAvatar(steamID)
	if size != null:
		# Using the small avatar handle
		var IMAGE: Dictionary = Steam.getImageSize(size)
		var IMAGE_DATA: Dictionary = Steam.getImageRGBA(size)
		
		# Now create the avatar like before
		var AVATAR: Image = Image.new()
		var AVATAR_TEXTURE: ImageTexture = ImageTexture.new()
		AVATAR.create(IMAGE['width'], IMAGE['height'], false, Image.FORMAT_RGBAF)
		
		if IMAGE_DATA["success"] == true:
			# Lock the image and fill the pixels from the data buffer
			AVATAR.lock()	
			for y in range(0, pixels):
				for x in range(0, pixels):
					var pixel: int = 4 * (x + y * pixels)
					var r: float = float(IMAGE_DATA['buffer'][pixel]) / 255
					var g: float = float(IMAGE_DATA['buffer'][pixel+1]) / 255
					var b: float = float(IMAGE_DATA['buffer'][pixel+2]) / 255
					var a: float = float(IMAGE_DATA['buffer'][pixel+3]) / 255
					AVATAR.set_pixel(x, y, Color(r, g, b, a))
			AVATAR.unlock()
			
			# Now apply the texture
			AVATAR_TEXTURE.create_from_image(AVATAR)
			return AVATAR_TEXTURE
		else: return null
