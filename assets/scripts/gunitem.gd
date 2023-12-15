# This is basically an addon for the item class. If the item is a gun, this class should be used
# instead of the default item class. There are a couple things that are unnecessary, like
# differentiating between hitscan and projectile weaponry, but I'll keep it just in case for now.
extends Item
class_name GunItem

@export var currentammo: int
@export var maxcurrentammo: int
@export var ammotype: Item
@export var recoil: float
@export var stamina_drain: int = 0
@export var stamina_needed: int = 0

@export var spread: float
@export var pellets: int = 1
@export var firerate: float
@export var firemode: String
@export_flags("hitscan","projectile") var Type
@export var effectiverange: float
@export var damage: int
@export var critmultiplier: int
