extends Resource
class_name Map

@export var map_name: String = ""
@export_multiline var description: String = ""
@export var thumbnail: Texture2D
@export_enum("objective","defense","sandbox") var type: int
@export var map_scene: PackedScene
