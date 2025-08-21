class_name DialogueSetVariableNodeData extends DialogueNodeData

enum SaveType {SaveBool,SaveString,SaveInt, SaveFloat}
@export var connected_node_id : int  = -1
@export var save_type : SaveType
@export var saved_key : String
@export var saved_value : String

func get_next_node():
	match save_type:
		SaveType.SaveString:
			SaveController.set_value(saved_key,saved_value)
		SaveType.SaveBool:
			SaveController.set_value_bool(saved_key,saved_value == "true")
		SaveType.SaveInt:
			SaveController.set_value_int(saved_key,int(saved_value))
		SaveType.SaveFloat:
			SaveController.set_value_float(saved_key,float(saved_value))
	return connected_node_id
