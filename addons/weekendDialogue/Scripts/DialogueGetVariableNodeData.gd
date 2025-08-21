class_name DialogueGetVariableNodeData extends DialogueNodeData

enum GetVariableType {Has,IsTrue,Equals,GreaterThan,GreateOrEqualThan,LessThan,LessOrEqualThan}

@export var key : String
@export var connected_node_id_true : int = -1
@export var connected_node_id_false : int = -1
@export var type : GetVariableType
@export var value : String

func get_next_node():
	var connected_node_index : int = 1
	match type:
		GetVariableType.Has:
			if SaveController.has_variable(key):
				return connected_node_id_true
		GetVariableType.IsTrue:
			if SaveController.get_value_bool(key,false):
				return connected_node_id_true
		GetVariableType.Equals:
			if SaveController.is_value(key,value):
				return connected_node_id_true
		GetVariableType.GreaterThan:
			if float(value) > SaveController.get_value_float(key,-1000000):
				return connected_node_id_true
		GetVariableType.GreateOrEqualThan:
			if float(value) >= SaveController.get_value_float(key,-1000000):
				return connected_node_id_true
		GetVariableType.LessThan:
			if float(value) < SaveController.get_value_float(key,1000000):
				return connected_node_id_true
		GetVariableType.LessOrEqualThan:
			if float(value) <= SaveController.get_value_float(key,1000000):
				return connected_node_id_true
	return connected_node_id_false
