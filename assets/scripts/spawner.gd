extends Node3D

@export var objectToSpawn: PackedScene
@export var objectQuantity: int = 1
@onready var stage = $".."
@onready var player = $"../../../player"

func _ready():
	var objectInit = objectToSpawn.instantiate()
	objectInit.position = self.position
	print(objectInit.name + str(objectInit.position))
	stage.add_child.call_deferred(objectInit)
	$preview.queue_free()
	pass

func _process(_delta):
	pass
