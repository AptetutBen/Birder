extends Node

var audio_source : AudioStreamPlayer2D


func _ready() -> void:
	
	audio_source = AudioManager.play_sfx("Weekend Sting")
	await audio_source.finished
	FlowController.load_main_menu()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		FlowController.load_main_menu()
		audio_source.stop()
