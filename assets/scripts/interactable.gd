# Basic interaction functionality.
extends Node3D

	
@export var items: Array[AddItemData]
@onready var model = $model
@onready var shader = $model.material_override.next_pass
@export_enum("item_pickup", "interact_trigger", "teleport") var type: int
@export var maxHighlight: float
@export var sceneToTeleport: String
var mouseHOVERED = false : set = changeMouseHOVERED
signal pickup()
func interact(inventory: Inventory):
	match type:
		0:
			item_pickup(inventory)
		1:
			print("test")
		2:
			Main.loadScene(sceneToTeleport)

func item_pickup(inventory: Inventory):
	for i in items:
		inventory.AddItem(i.item, i.quantity)
	queue_free()

func interact_trigger():
	# to do
	pass
	
func changeMouseHOVERED(value: bool):
	mouseHOVERED = value
	var tween = get_tree().create_tween()
	if mouseHOVERED:
		tween.tween_method(changeShaderValue, 0.0, maxHighlight, 0.12)
	else:
		tween.tween_method(changeShaderValue, maxHighlight, 0.0, 0.12)

func changeShaderValue(strengthval: float):
	shader.set_shader_parameter("strength", strengthval)
