extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_exit_pressed():
	get_tree().quit() # quit the game
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://assets/maps/streets/streets.tscn") # move player to scene
	pass


func _on_continue_pressed():
	pass # currently NOTHING, make compatible later with saving - but we'll cross that bridge when we get there
