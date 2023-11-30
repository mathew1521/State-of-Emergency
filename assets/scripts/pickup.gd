extends RigidBody3D

	
@export var items: Array[AddItemData]
@onready var model = $model

	

signal pickup()
# Called when the node enters the scene tree for the first time.

func interact(inventory: Inventory):
	for i in items:
		inventory.AddItem(i.item, i.quantity)
	queue_free()
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
