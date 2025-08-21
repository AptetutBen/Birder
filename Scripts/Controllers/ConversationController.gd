class_name ConversationController extends Control

const text_speed : float = 0.01
const text_hyper_multiplyer : float = 0.2

@onready var main_text: RichTextLabel = %"Main Text"
@onready var speaker_name_text: Label = %"Speaker Name Text"
@onready var input_prompt_image: TextureRect = %"Input Prompt Image"
@onready var pivot: Node2D = %Pivot
@onready var speaker_name: Panel = %"Speaker Name"

var input_pressed : bool
var current_node : DialogueConversationNodeData

var effect_list := {}
var effect_pointer : int
var speed_multiplyer : int = 1 


func _ready() -> void:
	pass
	#visible = false
	#EventBus.start_conversation.connect(_on_start_conversation)
	#EventBus.start_display_message.connect(_on_start_display_message)
	#EventBus.finish_conversation.connect(_on_finish_conversation)

func display_conversation_text():
	speaker_name.visible = true
	await show_ui()
	while (true):
		for text in current_node.text.split("~"):
			await display_text(text)
		current_node = current_node.dialoge_data.get_next_node(current_node,0)
		if current_node == null:
			break
	
	await hide_ui()
	EventBus.finish_conversation.emit()

func display_message_text(textArray : Array[String], title : String):
	speaker_name_text.text = title
	speaker_name.visible = title != ""
	await show_ui()
	for text in textArray:
		await display_text(text)
	
	await hide_ui()
	EventBus.finish_conversation.emit()

func show_ui():
	visible = true
	input_prompt_image.visible = false
	main_text.visible_characters = 0
	pivot.scale = Vector2.ZERO
	pivot.position = Vector2.ZERO
	await  get_tree().process_frame
	var panel_show_tween = create_tween()
	panel_show_tween.tween_interval(0.1)
	panel_show_tween.tween_property(pivot,"scale:x",1,0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	panel_show_tween.parallel().tween_property(pivot,"scale:y",1,0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await panel_show_tween.finished

func hide_ui():
	var panel_hide_tween = create_tween()
	panel_hide_tween.tween_property(pivot,"position:y",230,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	panel_hide_tween.parallel().tween_property(pivot,"scale:y",0.5,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	panel_hide_tween.parallel().tween_property(pivot,"scale:x",0.8,0.4).set_delay(0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await panel_hide_tween.finished
	
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("UI Accept") || event.is_action_pressed("UI Accept"):
		speed_multiplyer = text_hyper_multiplyer  
		input_pressed = true
	if event.is_action_released("UI Accept")  || event.is_action_released("UI Accept"):
		speed_multiplyer = 1

func display_text(text : String):
	effect_list.clear()
	text = text.strip_edges()
	
	var current_text_speed : float = text_speed
	
	# Build Effects
	
	effect_pointer = 0
	var clean_text : Array[String]
	var builder_index : int = 0
	
	while (builder_index < text.length()):
		if text[builder_index] == "{":
			var finish_index = text.find("}", builder_index)
			if finish_index < 0:
				printerr("no closing effect bracket")
				builder_index+=1
				continue
				
			var command_length = finish_index - builder_index - 1
			var command = text.substr(builder_index +1, command_length)
			effect_list[builder_index] = command
			builder_index+= command_length + 2
			continue
			
		clean_text.append(text[builder_index])
		builder_index+=1
	
	main_text.visible_characters = 0
	input_prompt_image.visible = false
	main_text.text = String("").join(clean_text)
	
	input_pressed = false
	for i in main_text.text.length():
		
		# Check for effects
		
		if effect_list.has(i):
			
			var split_pos : int = effect_list[i].find(":")
			var key : String
			var value : String
			
			if split_pos < 0:
				key = effect_list[i]
			else:		
				key = effect_list[i].substr(0,effect_list[i].find(":"))
				value = effect_list[i].substr(split_pos +1,-1)
			
			match key:
				"p":
					await get_tree().create_timer(float(value ) * speed_multiplyer).timeout
				"s":
					current_text_speed = float(value) if value != "r" else text_speed
			
		main_text.visible_characters = i+1
		if main_text.text[i] != " ":
			AudioManager.play_sfx("Key Tap",0.2,randf_range(0.8,1.2))
		#if input_pressed:
			#main_text.visible_characters = -1
			#break
		await get_tree().create_timer(current_text_speed * speed_multiplyer).timeout
	
	var blinking_tween = create_tween()
	blinking_tween.set_loops()
	blinking_tween.tween_property(input_prompt_image,"visible",true,0)
	blinking_tween.tween_interval(0.5)
	blinking_tween.tween_property(input_prompt_image,"visible",false,0)
	blinking_tween.tween_interval(0.5)

	AudioManager.play_sfx("click1")
	input_pressed = false
	while (!input_pressed):
		await get_tree().process_frame
	blinking_tween.stop()

func _on_start_display_message(textArray : Array[String], title: String):
	display_message_text(textArray,title)
	
func _on_start_conversation(dialogue_node : DialogueConversationNodeData, _node : Node3D):
	if dialogue_node == null:
		printerr("Conversation is null")
		await get_tree().process_frame
		await hide_ui()
		EventBus.finish_conversation.emit()
		return
	current_node = dialogue_node
	if current_node.character_id > 0:
		speaker_name_text.text = current_node.get_character().name
	display_conversation_text()

func _on_finish_conversation():
	visible = false
