extends Resource
class_name Item

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var stacksize: int = 1
@export var quantity: int = 1
@export var texture: Texture2D
@export_enum("ranged","melee","consumable") var type: int
@export var audio: AudioStream
@export var scene: PackedScene


