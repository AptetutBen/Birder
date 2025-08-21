extends Node

var currentScene : Node = null
var sceneDirectory = {}

var active_pause_panel : Node
var started_from_main_menu : bool = false

var scene_to_load : String = ""
var is_currently_loading : bool

var loading_scene : LoadingScreen

func _init() -> void:
	print(" ---- o ---- ")
	print("Project Name: " + ProjectSettings.get_setting("application/config/name"))
	print("version: " + ProjectSettings.get_setting("application/config/version"))
	print("Date: " + Time.get_date_string_from_system())
	print("Time: " + Time.get_time_string_from_system())
	print("In Editor: " + str(OS.has_feature("editor")))
	print("Debug Build: " + str(OS.has_feature("debug")))
	print("Platform: " + OS.get_name())
	print(" ---- o ---- ")

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	currentScene = root.get_child(root.get_child_count() - 1)
	
	dir_contents("res://Scenes")
	
	SaveController._load_settings_data()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SaveController.get_is_fullscreen() else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveController.get_is_vsync() else DisplayServer.VSYNC_DISABLED)
	
	var window_size : Vector2i = SaveController.get_resolution()
	DisplayServer.window_set_size(window_size)
	
	var screen_size : Vector2i = DisplayServer.screen_get_size()
	var centered = Vector2(screen_size.x / 2 - window_size.x / 2, screen_size.y / 2 - window_size.y / 2)
	DisplayServer.window_set_position(centered)

func start_game() -> void:
	started_from_main_menu = true
	active_pause_panel = null
	load_scene("Game",true)

# Pausing the game
func pause_game(active_panel : Node = null) -> void:
	active_pause_panel = active_panel
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false
	active_pause_panel = null

func load_main_menu():
	load_scene("Main Menu")

func reload_current_scene():
	load_scene(currentScene.name)

func load_scene(scene_name , use_loading_screen : bool = false):
	
	if is_currently_loading:
		return
		
	get_tree().paused = false
	call_deferred("_deferred_goto_scene", scene_name,use_loading_screen)
	
func _deferred_goto_scene(scene_name, use_loading_screen):

	if !sceneDirectory.has(scene_name):
		print("** Error ** Can't find scene: " + scene_name)
		return
		
	scene_to_load = sceneDirectory[scene_name]
	
	if OS.get_name() == "Web":
		
		if currentScene:
			currentScene.queue_free()
		# Use non-threaded loading for WebGL
		var scene = ResourceLoader.load(scene_to_load)
		if !scene:
			printerr("Scene %s not loaded"% scene_to_load)
		currentScene = scene.instantiate()
			
		# Add it to the active scene, as child of root.
		get_tree().root.add_child(currentScene)

		# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
		get_tree().current_scene = currentScene
		return
	
	is_currently_loading = true
	var progress : Array[float]

	if use_loading_screen:
		var prefab : PackedScene = ResourceLoader.load(sceneDirectory["Loading"])
		loading_scene = prefab.instantiate() as LoadingScreen
		add_child(loading_scene)
		await loading_scene.activate()

		currentScene.queue_free()
	
	# Load the new scene.
	ResourceLoader.load_threaded_request(scene_to_load)

	while true:
		
		var loading_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	
		match loading_status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
				#print("loading: " + str(progress[0]))
			ResourceLoader.THREAD_LOAD_LOADED:
				break
			ResourceLoader.THREAD_LOAD_FAILED:
				# Well some error happend:
				printerr("Error. Could not load Resource")
				return
		
		await get_tree().process_frame
	
	if loading_scene != null:
		loading_scene.finish_loading_scene()
		loading_scene = null

	if currentScene != null:
		# It is now safe to remove the current scene.
		currentScene.free()
	
	# Instance the new scene.
	currentScene = ResourceLoader.load_threaded_get(scene_to_load).instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(currentScene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = currentScene
	
	is_currently_loading = false
	

func dir_contents(path):
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Recursively call dir_contents for subdirectories
				dir_contents(path + "/" + file_name)
			else:
				if file_name.get_extension().to_lower() == "tscn":
					sceneDirectory[file_name.substr(0,file_name.length()-5)] = path + "/" + file_name
				elif file_name.get_extension().to_lower() == "remap":
					sceneDirectory[file_name.substr(0,file_name.length()-len(".tscn.remap"))] = path + "/" + file_name.substr(0,file_name.length()-len(".remap"))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
