# Basic buttons in the main menu. Currently have an exit button and start button that sends you
# to the prototyping scene. I'll keep the continue button for now so I don't tamper with any
# signals that I enabled, but that's effectively gonna be useless now that the scope of the game
# has changed from a linear campaign to many replayable shorter levels.
extends VBoxContainer

func _on_exit_pressed():
	get_tree().quit()
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://assets/maps/streets/streets.tscn")
	pass

func _on_continue_pressed():
	pass
