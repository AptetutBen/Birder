extends Node

const footstep_keys = {-1:"water",0:"sand",1:"rock",2:"grass",3:"dirt"}
const audioFormats = ["wav","mp3","ogg"]

var audioStreamPointer2D: int = 0;
var audioStreamPointerMusic: int = 0;
var currentMusicAudioStreamPlayer : AudioStreamPlayer2D
var audioStreamPointer3D: int = 0;
var audioStreamPlayers2D: Array[AudioStreamPlayer2D] = []
var audioStreamPlayers3D: Array[AudioStreamPlayer3D] = []
var musicAudioStreamPlayers: Array[AudioStreamPlayer2D] = []

var sfx_clips = {}
var music_clips = {}

var footstep_clips = {}

# Called when the node enters the scene tree for the first time.
func _init():
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	_get_audio_files("res://Audio/SFX",sfx_clips)
	_get_audio_files("res://Audio/Music",music_clips)
	_get_footstep_audio()
	
	# Add new busses for the sfx and music
	_add_bus("Music")
	_add_bus("SFX")
	
	# create audio source
	_create_2DaudioSources(2)
	_create_3DaudioSources(5)
	_create_musicAudioSources(2)
	
	AudioServer.set_bus_volume_db(0,linear_to_db(SaveController.get_master_volume()))
	AudioServer.set_bus_volume_db(1,linear_to_db(SaveController.get_sfx_volume()))
	AudioServer.set_bus_volume_db(2,linear_to_db(SaveController.get_music_volume()))


# Adds a new bus to the Audio Server with the specified name.
# The bus is added at the first available index.
func _add_bus(bus_name : String):
	AudioServer.add_bus(1)
	AudioServer.set_bus_name(1, bus_name)

func play_sfx_fade(clip_name : String, play_from_random_point : bool = false, fade_in_duration : float = 3, play_duration : float= 5, fade_out_duration : float = 10) -> AudioStreamPlayer2D:
	var player = play_sfx(clip_name)
	
	if play_from_random_point:
		player.play(randf_range(0,player.stream.get_length()))

	player.volume_db = linear_to_db(1)
	
	var audio_tween : Tween = get_tree().create_tween()
	if(fade_in_duration > 0):
		player.volume_db = -80
	audio_tween.tween_property(player, "volume_db",0, fade_in_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	audio_tween.tween_interval(play_duration)
	if(fade_out_duration > 0):
		audio_tween.tween_property(player, "volume_db",-80, fade_out_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		audio_tween.tween_callback(func(): player.stop())
	
	return player

# Play a sfx with a fade in, play and fade out duration in seconds
func play_sfx(clip_name : String,volume : float = 1, pitch : float = 1) -> AudioStreamPlayer2D:
	if volume <= 0.1:
		return
	if !sfx_clips.has(clip_name):
		print("*** Audio File: %s not found." %clip_name )
		return
	var clip = ResourceLoader.load(sfx_clips[clip_name])
	return _play_2d_audio(clip,volume,pitch)
	
func _play_2d_audio(clip : AudioStream,volume : float = 1, pitch : float = 1) -> AudioStreamPlayer2D:
	var player : AudioStreamPlayer2D = audioStreamPlayers2D[audioStreamPointer2D]
	player.pitch_scale = pitch
	player.volume_db = linear_to_db(volume)
	audioStreamPointer2D = (audioStreamPointer2D+1)%audioStreamPlayers2D.size()
	player.stream = clip
	player.play()
	return player

func play_footstep_sound(texure_index : int, volume : float):
	if !footstep_keys.has(texure_index):
		return
	_play_2d_audio(ResourceLoader.load(footstep_clips[footstep_keys[texure_index]].pick_random()),volume,randf_range(0.6,1.4))

func play_sfx_at_position(clip_name : String, position: Vector3,volume : float = 1, pitch : float = 1) -> AudioStreamPlayer3D:
	if volume <= 0.1:
		return
	if !sfx_clips.has(clip_name):
		print("*** Audio File: %s not found." %clip_name )
		return
	var clip = ResourceLoader.load(sfx_clips[clip_name])
	return _play_3d_audio(clip,position,volume,pitch)

func _play_3d_audio(clip : AudioStream, position: Vector3,volume : float = 1, pitch : float = 1) -> AudioStreamPlayer3D:
	var player : AudioStreamPlayer3D = audioStreamPlayers3D[audioStreamPointer3D]
	player.volume_db = linear_to_db(volume)
	player.pitch_scale = pitch
	audioStreamPointer3D = (audioStreamPointer3D+1)%audioStreamPlayers3D.size()
	player.global_position = position
	player.stream = clip
	player.play()
	return player

func play_music(clip_name : String, fade_duration : float = 1) -> AudioStreamPlayer2D:
	if !music_clips.has(clip_name):
		print("*** Audio File: %s not found." %clip_name )
		return
	var clip = ResourceLoader.load(music_clips[clip_name])
	var asp = _play_music_clip(clip,fade_duration)
	return asp

func _play_music_clip(clip : AudioStream, fade_duration : float = 1) -> AudioStreamPlayer2D:
	var currentPlayer : AudioStreamPlayer2D = musicAudioStreamPlayers[audioStreamPointerMusic]
	_fade_song_out(currentPlayer)
	
	
	audioStreamPointerMusic = (audioStreamPointerMusic+1)%musicAudioStreamPlayers.size()
	
	var nextPlayer : AudioStreamPlayer2D = musicAudioStreamPlayers[audioStreamPointerMusic]
	nextPlayer.stream = clip
	_fade_song_in(musicAudioStreamPlayers[audioStreamPointerMusic],fade_duration)
	currentMusicAudioStreamPlayer = nextPlayer
	return nextPlayer

func fade_current_song() -> void:
	_fade_song_out(currentMusicAudioStreamPlayer)

# Coroutine to fade out a song
func _fade_song_out(audio_source : AudioStreamPlayer2D):
	
	if audio_source == null || !audio_source.playing:
		return
		
	# Set the timer to whatever the audio_source currently is
	var timer = get_tree().create_timer(1.0)
	
	# Loop until timer gets below or equal to 0
	while timer.time_left > 0:
		# Set the audio_source's volume to be whatever the timer currently is
		audio_source.set_volume_db(linear_to_db(timer.time_left))
		# Wait till the next frame to loop around again.
		await get_tree().process_frame
		
	# Stop the audio_source from playing music
	audio_source.stop()

# Coroutine to fade out a song
func _fade_song_in(audio_source : AudioStreamPlayer2D, duration : float = 1):
	
	# Set the timer to whatever the audio_source currently is
	var timer = get_tree().create_timer(duration)
	audio_source.play()

	# Loop until timer gets below or equal to 0
	while timer.time_left > 0:
		# Set the audio_source's volume to be whatever the timer currently is
		audio_source.set_volume_db(linear_to_db(1-timer.time_left/duration))
		# Wait till the next frame to loop around again.
		await get_tree().process_frame

func _create_2DaudioSources(count : int):
	for n in range(0,count):
		var newAudioStreamPlayer : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(newAudioStreamPlayer)
		audioStreamPlayers2D.append(newAudioStreamPlayer)
		newAudioStreamPlayer.bus = "SFX"

func _create_3DaudioSources(count : int):
	for n in range(0,count):
		var newAudioStreamPlayer : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		add_child(newAudioStreamPlayer)
		audioStreamPlayers3D.append(newAudioStreamPlayer)
		newAudioStreamPlayer.bus = "SFX"
		
func _create_musicAudioSources(count : int):
	for n in range(0,count):
		var newAudioStreamPlayer : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(newAudioStreamPlayer)
		musicAudioStreamPlayers.append(newAudioStreamPlayer)
		newAudioStreamPlayer.bus = "Music"

func _get_footstep_audio():
	_build_footstep_audio_dic("res://Audio/Footsteps/Dirt","dirt")
	_build_footstep_audio_dic("res://Audio/Footsteps/Grass","grass")
	_build_footstep_audio_dic("res://Audio/Footsteps/Rock","rock")
	_build_footstep_audio_dic("res://Audio/Footsteps/Sand","sand")
	_build_footstep_audio_dic("res://Audio/Footsteps/Water","water")

func _build_footstep_audio_dic(path : String, key : String):
	footstep_clips[key] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != '':
		
		if filename.get_extension() == "import":
			#print(filename)
			filename = filename.left(len(filename) - len('.import'))
			
			if audioFormats.has(filename.get_extension().to_lower()):
				footstep_clips[key].append(ProjectSettings.globalize_path( path + "/" + filename))
				
		filename = dir.get_next()

# get all audio files in the 'Audio' folder and store them in a dictionary
func _get_audio_files(path,dic):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != '':

		if dir.current_is_dir():
			_get_audio_files(path + "/" + filename,dic)
		
		if filename.get_extension() == "import":
			filename = filename.left(len(filename) - len('.import'))
			if audioFormats.has(filename.get_extension().to_lower()):
				var shortName = filename.left(len(filename) - (len(filename.get_extension() )+ 1))
				dic[shortName] = ProjectSettings.globalize_path( path + "/" + filename)
				
		filename = dir.get_next()

func get_master_volume() -> float:
	return SaveController.get_master_volume()
	
func get_sfx_volume() -> float:
	return SaveController.get_sfx_volume()
	
func get_music_volume() -> float:
	return SaveController.get_music_volume()

func set_master_volume(value : float):
	SaveController.set_master_volume(value)
	AudioServer.set_bus_volume_db(0,linear_to_db(value))

func set_sfx_volume(value : float):
	SaveController.set_sfx_volume(value)
	AudioServer.set_bus_volume_db(1,linear_to_db(value))

func set_music_volume(value : float):
	SaveController.set_music_volume(value)
	AudioServer.set_bus_volume_db(2,linear_to_db(value))
	
