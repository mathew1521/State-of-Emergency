extends CharacterBody3D
@onready var hud = $hud
@onready var inventory = $hud/inventorylayer/inventory
@onready var console = $hud/consolelayer/console
# node references
@onready var head = $head
@onready var eyes = $head/eyes
@onready var equipped = $head/eyes/maincam/equipped
@onready var standcollider = $standcollider
@onready var duckcollider = $duckcollider
@onready var ray_cast_3d = $groundcolraycast # for crouching and guns
@onready var interactray = $head/eyes/maincam/interactray # separate, for interacting with objects (doors, items..)
# couple local variables to handle movement states and camera logic stuff

enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	CROUCHING,
	AIR
}

var currentState = STATE.IDLE

var canrun = true
var walking = false
var running = false
var ducking = false
var health = 100
var currentspeed = 5.0
var bobbingvector = Vector2.ZERO
var bobbingindex = 0.0
var bobbingintensity = 0.0

@export_group("Camera Shake")
@export var runbobbingstrength = 19.0 # 22.0 default
@export var walkbobbingstrength = 12.0
@export var duckbobbingstrength = 10.0

@export var runbobbingintensity = 0.1
@export var walkbobbingintensity = 0.05
@export var duckbobbingintensity = 0.025

@export_group("Movement Variables")
@export var walkspeed = 3
@export var runspeed = 6 # 8.0 default
@export var duckingspeed = 2.0
@export var jump = 3.2
@export var mousesens = 0.1

var vmlerpspeed = 2.0
var lerpspeed = 10.0
var mouse_input: Vector2
var direction = Vector3.ZERO
var duckingdepth = -0.8
var ismoving = false

# get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# lock cursor
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("interact"):
		interact()
		
func interact():
	if interactray.is_colliding():
		interactray.get_collider().interact(inventory)
		
		
func _input(event):
	if !inventory:
		return
	if inventory.isopen:
		return
	if console.isopen:
		return
	# detect mouse input, handle camera rotation (head), and clamp rotation thereof
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mousesens))
		head.rotate_x(deg_to_rad(-event.relative.y * mousesens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		mouse_input = event.relative

func _physics_process(delta):
	# detect movement inputs (WASD)
	if !inventory:
		return
	if inventory.isopen:
		return
	if console.isopen:
		return
		
	
	# ... existing code ...
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if Input.is_action_pressed("duck"): # detect crouching (CTRL)
		currentspeed = duckingspeed
		head.position.y = lerp(head.position.y, 0.6 + duckingdepth, delta*lerpspeed)
		standcollider.disabled = true
		duckcollider.disabled = false
		
		walking = false
		running = false
		ducking = true
		
	# detect empty space for crouching reasons	
	elif !ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y, 0.6, delta*lerpspeed)
		standcollider.disabled = false
		duckcollider.disabled = true
		
		if Input.is_action_pressed("run"):
			if canrun:
				currentspeed = runspeed
				walking = false
				running = true
				ducking = false
		else:
			currentspeed = walkspeed
			walking = true
			running = false
			ducking = false
			
			
			
	if is_on_floor() && input_dir != Vector2.ZERO:
		# handle camera bobbing, as well as the viewmodel bobbing
		bobbingvector.y = sin(bobbingindex)
		bobbingvector.x = sin(bobbingindex/2)+0.5
		eyes.position.y = lerp(eyes.position.y,bobbingvector.y*(bobbingintensity/2.0),delta*lerpspeed)
		eyes.position.x = lerp(eyes.position.x,bobbingvector.x*bobbingintensity,delta*lerpspeed)
		equipped.position.y = lerp(equipped.position.y,bobbingvector.y*(bobbingintensity/2.0),delta*vmlerpspeed)
		equipped.position.x = lerp(equipped.position.x,bobbingvector.x*bobbingintensity,delta*vmlerpspeed)
	else:
		# lerp positions of camera and vm back to their origin point
		eyes.position.y = lerp(eyes.position.y,0.0,delta*lerpspeed)
		eyes.position.x = lerp(eyes.position.x,0.0,delta*lerpspeed)
		equipped.position.y = lerp(equipped.position.y,0.0,delta*vmlerpspeed)
		equipped.position.x = lerp(equipped.position.x,0.0,delta*vmlerpspeed)
		
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# states
	if running:
		bobbingintensity = runbobbingintensity
		bobbingindex += runbobbingstrength*delta
	elif walking:
		bobbingintensity = walkbobbingintensity
		bobbingindex += walkbobbingstrength*delta
	elif ducking:
		bobbingintensity = duckbobbingintensity
		bobbingindex += duckbobbingstrength*delta
		
	# jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump # go uppppp
		

	# get the input direction and handle the movement/deceleration
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerpspeed)
	if direction:
		velocity.x = direction.x * currentspeed
		velocity.z = direction.z * currentspeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentspeed)
		velocity.z = move_toward(velocity.z, 0, currentspeed)
	if velocity.length() > 1:
		ismoving = true
	else:
		ismoving = false
		
	move_and_slide()
	equipped_sway(delta)
	
func equipped_sway(delta):
	
	var mouseX = mouse_input.x * vmlerpspeed/3000
	var mouseY = mouse_input.y * vmlerpspeed/3000
	
	var rotationY = Basis().rotated(Vector3(0,1,0), mouseX)
	var rotationX = Basis().rotated(Vector3(1,0,0), -mouseY)
	var targetRotation = rotationX * rotationY
	
	equipped.basis = equipped.basis.slerp(targetRotation, 5 * delta)


func hit():
	health = health - 10
