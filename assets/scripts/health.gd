extends Node

@export var health: int
@export var maximumhealth: int
signal healthtaken

func damage(damageval):
	health -= damageval
	emit_signal("healthtaken")
	pass
	
func heal(healval):
	health += healval
	pass

func die():
	var entity = self.get_parent()
	entity.queue_free()
	pass
	
func _process(_delta):
	if health <= 0:
		die()
		
