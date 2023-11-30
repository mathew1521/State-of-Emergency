extends AnimationTree
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = randi_range(0,1)
	print(rng)
	if rng == 0:
		get_tree_root().get_node("Idle").set_animation("zombieanimations/Idle")
		get_tree_root().get_node("Walk").set_animation("zombieanimations/Walk")
		get_tree_root().get_node("Swipe").set_animation("zombieanimations/Claw")
		pass
	elif rng == 1:
		get_tree_root().get_node("Idle").set_animation("zombieanimations/Idle2")
		get_tree_root().get_node("Walk").set_animation("zombieanimations/Walk2")
		get_tree_root().get_node("Swipe").set_animation("zombieanimations/Claw2")
		pass
	self.active = true
