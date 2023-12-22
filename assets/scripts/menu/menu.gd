extends Control
@onready var cursor = $cursor/centercontainer/texture
@onready var buttonclick = $click
@onready var mapmenu = $map_selection/mapmenu
@onready var modifiermenu = $map_selection/modifiermenu
func _ready():
	Main.currentSTATE = Main.STATE.MENU
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	cursor.show()
	
	var map_popup = mapmenu.get_popup()
	map_popup.id_pressed.connect(on_mapmenu_pressed)
	var modifier_popup = modifiermenu.get_popup()
	modifier_popup.id_pressed.connect(on_modifiermenu_pressed)
	pass

func _process(delta):
	cursor.position = cursor.get_global_mouse_position()
	pass


func _on_start_pressed():
	buttonclick.play()
	await buttonclick.finished
	$title.hide()
	$version.hide()
	$buttons.hide()
	$map_selection.show()
	pass


func _on_settings_pressed():
	buttonclick.play()
	await buttonclick.finished
	pass


func _on_credits_pressed():
	buttonclick.play()
	await buttonclick.finished
	pass


func _on_exit_pressed():
	buttonclick.play()
	await buttonclick.finished
	get_tree().quit()


func on_mapmenu_pressed(index):
	buttonclick.play()
	var popup = mapmenu.get_popup()
	mapmenu.text = mapmenu.get_popup().get_item_text(index)

func on_modifiermenu_pressed(index):
	buttonclick.play()
	var popup = modifiermenu.get_popup()
	modifiermenu.text = modifiermenu.get_popup().get_item_text(index)


func _on_menus_pressed():
	buttonclick.play()
	await buttonclick.finished
	pass


func _on_realstart_pressed():
	buttonclick.play()
	await buttonclick.finished
	var map = mapmenu.text
	var modifier = modifiermenu.text
	
	match modifier:
		"28 Days Later":
			print("28 days")
		"PTSD":
			print("PTSD")
		_:
			pass
			
	match map:
		"<Random Map>":
			random_map()
		"Industry":
			Main.loadScene("Industry")
		"Plaza":
			Main.loadScene("Plaza")
		_:
			pass
			
func random_map():
	var rng = randi_range(0,1)
	
	match rng:
		0:
			Main.loadScene("Industry")
		1:
			Main.loadScene("Plaza")
