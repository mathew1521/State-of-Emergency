# Basic interaction functionality.
extends RigidBody3D

	
@export var items: Array[AddItemData]
@onready var model = $model
@export_enum("item_pickup", "interact_trigger") var type: int
	

signal pickup()

func interact(inventory: Inventory):
	match type:
		0:
			item_pickup(inventory)
		1:
			print("test")

func item_pickup(inventory: Inventory):
	for i in items:
		inventory.AddItem(i.item, i.quantity)
	queue_free()

func interact_trigger():
	# to do
	pass

