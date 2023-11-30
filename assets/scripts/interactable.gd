extends RigidBody3D

	
@export var items: Array[AddItemData]
@onready var model = $model
@export_enum("item_pickup", "interact_trigger") var type: int
	

signal pickup()

func interact(inventory: Inventory):
	match type:
		"item_pickup":
			item_pickup(inventory)
		"interact_trigger":
			print("test")

func item_pickup(inventory: Inventory):
	for i in items:
		inventory.AddItem(i.item, i.quantity)
	queue_free()


func _ready():
	pass


func _process(delta):
	pass
