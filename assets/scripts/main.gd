# This is going to serve as a game manager of sorts. I'll have a look at it tomorrow
# if I have some time. Sometimes I wish I had the schedule that 8 year old me did.
# I sure could use all that time on my hands now.
extends Node
enum STATE {
	PLAYING,
	MENU,
	INVENTORY,
	CONSOLE,
}
var currentSTATE: STATE = STATE.PLAYING
var currentSCENE: String = "Menu"

var currentInventory: Array[AddItemData] = []
var currentSlot: int = 0
var sceneMap = {
	"Industry": "res://assets/maps/industry/industry.tscn",
	"Industry_Apartment": "res://assets/maps/industry/industry_apartment.tscn",
	"Plaza": "res://assets/maps/streets/streets.tscn",
	"Menu": "res://assets/scenes/menus/menu.tscn",
	"ZombieLab": "res://sub_viewport.tscn"
}

func loadScene(scene: String, modifier: String = ""):
	for sceneName in sceneMap.keys():
		if sceneName == scene:
			get_tree().change_scene_to_file(sceneMap[sceneName])
			Main.currentSTATE = Main.STATE.PLAYING
			Engine.time_scale = 1
			currentSCENE = sceneName
			print(currentSCENE + " on difficulty " + modifier)
	pass
