# This script allows for unique animation "sets", so to speak. Right now, I only need
# zombies to have unique animation sets, so that's all this is used for. However, I intend 
# to come back down the line and improve this to get rid of the redundant and yucky if statements.

# Note to future self:  Use arrays to store animation string names, or make an animation set class.

extends AnimationTree
var rng

func _ready():
	rng = randi_range(0,1) # Always either set 1, or set 2.
	
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
		
	self.active = true # The animation tree is only activated after the entity's animations are assigned.


	# Replace with match statement once additional animation sets are added (in 5 million years)w
