class_name GameController extends Node

static var Instance : GameController	#Set Singleton

# Check if you want to use debug settings and debug menu
@export var _use_debug : bool = false
@export var _debug_mute_music : bool = true

func _ready() -> void:

	# Set singleton
	Instance = self
	
	# Always turn off debug when game is built 
	if !OS.has_feature("debug"):
		_use_debug = false
	
	# play the background music,
	if !_use_debug || !_debug_mute_music:
		AudioManager.play_music("Game Music")
