extends Control
@onready var cursor = $cursor/centercontainer/texture
@onready var buttonclick = $click
@onready var mapmenu = $map_selection/mapmenu
@onready var modifiermenu = $map_selection/modifiermenu
@onready var resolutionmenu = $settings/resolutionmenu
@onready var fullscreenmenu = $settings/fullscreenmenu

func _ready():
	Main.posterization = false
	Main.downscaling = false
	Main.currentSTATE = Main.STATE.MENU
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	cursor.show()
	
	var map_popup = mapmenu.get_popup()
	map_popup.id_pressed.connect(on_mapmenu_pressed)
	var modifier_popup = modifiermenu.get_popup()
	modifier_popup.id_pressed.connect(on_modifiermenu_pressed)
	
	var fullscreen_popup = fullscreenmenu.get_popup()
	fullscreen_popup.id_pressed.connect(_on_fullscreenmenu_pressed)
	var resolution_popup = resolutionmenu.get_popup()
	resolution_popup.id_pressed.connect(_on_resolutionmenu_pressed)


	var fs_mode = get_window().get_mode()
	match fs_mode:
		0:
			$settings/fullscreenmenu.text = "Windowed"
		3:
			$settings/fullscreenmenu.text = "Borderless Fullscreen"
		4:
			$settings/fullscreenmenu.text = "Fullscreen"
	pass
	
	var res = get_window().size
	$settings/resolutionmenu.text = str(res)
	
func _process(delta):
	cursor.position = cursor.get_global_mouse_position()
	pass


func _on_start_pressed():
	buttonclick.play()
	await buttonclick.finished
	$logo.hide()
	#$title.hide()
	$version.hide()
	$buttons.hide()
	$map_selection.show()
	pass


func _on_settings_pressed():
	buttonclick.play()
	await buttonclick.finished
	#$title.hide()
	$logo.hide()
	$version.hide()
	$buttons.hide()
	$settings.show()
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
			random_map(modifier)
		"Industry":
			Main.loadScene("Industry", modifier)
		"Gameplay Testing":
			Main.loadScene("Plaza", modifier)
		"Zombie Skins Testing":
			Main.loadScene("ZombieLab", modifier)
		_:
			pass
			
func random_map(modifier: String = ""):
	var rng = randi_range(0,1)
	
	match rng:
		0:
			Main.loadScene("Industry",  modifier)
		1:
			Main.loadScene("Plaza", modifier)
		2:
			Main.loadScene("ZombieLab", modifier)



func _on_settings_back_pressed():
	buttonclick.play()
	await buttonclick.finished
	$settings.hide()
	$logo.show()
	#$title.show()
	$version.show()
	$buttons.show()
	pass


func _on_map_back_pressed():
	buttonclick.play()
	await buttonclick.finished
	$map_selection.hide()
	$logo.show()
	#$title.show()
	$version.show()
	$buttons.show()
	pass

func _on_fullscreenmenu_pressed(index):
	buttonclick.play()
	await buttonclick.finished
	var popup = fullscreenmenu.get_popup()
	fullscreenmenu.text = fullscreenmenu.get_popup().get_item_text(index)
	
	match index:
		0:
			get_window().mode = 4
			get_window().borderless = true
		1:
			get_window().mode = 3
			get_window().borderless = false
		2:
			get_window().mode = 0
			get_window().borderless = false
			
	


func _on_resolutionmenu_pressed(index):
	buttonclick.play()
	await buttonclick.finished
	var popup = resolutionmenu.get_popup()
	resolutionmenu.text = resolutionmenu.get_popup().get_item_text(index)
	
	match index:
		0:
			get_window().size = Vector2(1920,1080)
		1:
			get_window().size = Vector2(1600,900)
		2:
			get_window().size = Vector2(1280,720)




func _on_posterization_toggled(button_pressed):
	if !Main.posterization:
		Main.posterization = true
	else:
		Main.posterization = false
	pass # Replace with function body.


func _on_downscale_toggled(button_pressed):
	if !Main.downscaling:
		Main.downscaling = true
	else:
		Main.downscaling = false
	pass # Replace with function body.
