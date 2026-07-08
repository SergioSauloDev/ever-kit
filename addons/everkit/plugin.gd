@tool
extends EditorPlugin

func _enable_plugin() -> void:
	print("EverKit enabled")

func _disable_plugin() -> void:
	print("EverKit disabled")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
