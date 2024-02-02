# I like to use composition, because Godot is all about composition. If put inside of a node, it just
# provides health functionality.
extends Node

@export var health: int
@export var maximumhealth: int
var dead = false
signal healthtaken

func damage(damageval):
	health -= damageval
	self.get_parent().knockback()
	emit_signal("healthtaken")
	pass
	
func heal(healval):
	health += healval
	pass

func die():
	var _entity = self.get_parent()
	dead = true
	#entity.queue_free()
	pass
	
func _process(_delta):
	if health <= 0:
		die()
	
func shove(dir):
	var entity = self.get_parent()
	entity.pushback(dir)
