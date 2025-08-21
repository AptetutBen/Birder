@tool
extends EditorPlugin

const editorAddon = preload("res://addons/weekendSpreadsheets/Scenes/google_sheets_control.tscn")

var dockedScene

func _enter_tree():
	dockedScene = editorAddon.instantiate()
	add_control_to_bottom_panel(dockedScene, "weekend Sheets")

func _exit_tree():
	remove_control_from_bottom_panel(dockedScene)
	dockedScene.free()
