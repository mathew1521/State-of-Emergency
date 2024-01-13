@tool
extends Node

var prop = preload("res://assets/models/zombie.tscn")

func _process(delta):
	pass
		
func place_prop():
	if prop:
		get_tree().get_edited_scene_root().add_child(prop.instantiate())
		prop.global_transform.origin = get_viewport().get_global_mouse_position()
