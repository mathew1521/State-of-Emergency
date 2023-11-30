extends CharacterBody3D
var state_machine
var player = null
var attacking = false
var isactive = true
var playerspotted = false
var SPEED = randf_range(0.5, 1.5)
var FOV = 91.0
const ATTACK_RANGE = 1.5
const DET_RANGE = 30.0
@export var player_path: NodePath
@onready var nav_agent = $navigation
@onready var anim_tree = $animtree
@onready var anim_player = $animplayer
@onready var health = $health
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(SPEED)
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	#anim_tree.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
#	if attacking:
#		return
		
	if !isactive: 
		anim_tree.active = false
		anim_player.stop()
		return
	
	if !playerspotted:
		if _target_acquired():
			playerspotted = true
		else:
			return

#	else: anim_tree.active = true
	
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Walk":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
#			look_at(Vector3(global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
			faceplayer(player.global_position, 0.1)
			#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"Swipe":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	anim_tree.set("parameters/conditions/idle", !playerspotted)
	anim_tree.set("parameters/conditions/swipe", _target_in_range())
	anim_tree.set("parameters/conditions/walk", !_target_in_range())
	anim_tree.set("parameters/conditions/walk", await _on_health_healthtaken())
	
	anim_tree.get("parameters/playback")
	move_and_slide()
	
#	await get_tree().create_timer(5).timeout
#	isactive = false
#	await get_tree().create_timer(5).timeout
#	isactive = true
	pass
	
func _target_in_range():
	if anim_tree.get("parameters/conditions/swipe"):
		if anim_player.animation_finished:
			return
		return global_position.distance_to(player.global_position) < ATTACK_RANGE
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.6:
		var dir = global_position.direction_to(player.global_position)
		player.hit()

func _target_acquired():
	if global_position.distance_to(player.global_position) < DET_RANGE:
		var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
		var angle_to_player = acos(direction_to_player.dot(-global_transform.basis.z))
		if (angle_to_player) <= deg_to_rad(FOV):
			var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(global_transform.origin, player.global_transform.origin))
			if result:
				if result.collider == player:
					return true
	return false


func faceplayer(pos, weight):
	var rot = Quaternion.from_euler(rotation)
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	var target_rot = Quaternion.from_euler(rotation)
	rotation = rot.slerp(target_rot, weight).get_euler()
	
func _on_health_healthtaken():
	await get_tree().create_timer(0.1).timeout
	playerspotted = true
	anim_tree.set("parameters/conditions/walk", true)
	return true
