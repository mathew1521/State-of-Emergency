# Not sure where I'm going with this just yet. The plan is for each map to be 
# separated into its own folder containing its own map resource and map scene.
# Example: assets/maps/streets/streets.tres, streets.tscn
extends Resource
class_name Map

@export var map_name: String = ""
@export_multiline var description: String = ""
@export var thumbnail: Texture2D
@export_enum("objective","defense","sandbox") var type: int
@export var map_scene: PackedScene
