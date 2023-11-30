extends Item
class_name GunItem

@export var currentammo: int
@export var maxcurrentammo: int
@export var ammotype: Item
@export var recoil: float
# function vars
@export var spread: float
@export var pellets: int = 1
@export var firerate: float
@export var firemode: String
@export_flags("hitscan","projectile") var Type
@export var effectiverange: int
@export var damage: int
@export var critmultiplier: int
