extends Node
enum STATE {
	PLAYING,
	MENU,
	INVENTORY,
	CONSOLE,
}
var currentSTATE: STATE = STATE.PLAYING
var currentSCENE: String = "Menu"
var gameModifier: String = ""
var currentInventory: Array[AddItemData] = []
var currentSlot: int = 0
var defaultViewportRes
var posterization: bool = false
var downscaling: bool = false
var sceneMap = {
	"Industry": "res://assets/maps/industry/industry.tscn",
	"Industry_Apartment": "res://assets/maps/industry/industry_apartment.tscn",
	"Plaza": "res://assets/maps/streets/streets.tscn",
	"Menu": "res://assets/scenes/menus/menu.tscn",
	"ZombieLab": "res://sub_viewport.tscn"
}

func _ready():
	defaultViewportRes = get_viewport().scaling_3d_scale
	
func loadScene(scene: String, modifier: String = ""):
	for sceneName in sceneMap.keys():
		if sceneName == scene:
			get_tree().change_scene_to_file(sceneMap[sceneName])
			Main.currentSTATE = Main.STATE.PLAYING
			Engine.time_scale = 1
			currentSCENE = sceneName
			gameModifier = str(modifier)
	pass
