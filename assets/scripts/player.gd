# Player handler.
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
@onready var cursorcentercontainer = $hud/cursor/centercontainer
@onready var cursor = $hud/cursor/centercontainer/texture
# couple local variables to handle movement states and camera logic stuff

enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	CROUCHING,
	AIR
}

var currentState: STATE = STATE.IDLE

var canrun = true

var stamina_cooldown = 0
var dangerousfall: bool
var falldamage: float
@export_group("Player Statistics")
@export var stamina = 100
@export var health = 100
@export var stamina_chargetime = 5
@export var stamina_chargerate = 0.18
@export var stamina_drainrate = 0.5
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
@export var duckingspeed = 1.0
@export var jump = 3.2
@export var mousesens = 0.1
@export var footsteps_sfx: Array[AudioStreamWAV]
@onready var walking_streamplayer = $player_audio/walking
var walksfx_index = -1

var vmlerpspeed = 2.0
var lerpspeed = 10.0
var mouse_input: Vector2
var direction = Vector3.ZERO
var duckingdepth = -0.7
var ismoving = false
var seeing = null
# get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# lock cursor
func _ready():
	#defaultcursorpos = cursor.position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(_event: InputEvent):
	if Engine.time_scale == 0:
		return
	if Input.is_action_just_pressed("interact"):
		interact()
		
func interact():
	if interactray.is_colliding():
		if interactray.get_collider().has_method("interact"):
			interactray.get_collider().interact(self)

func interactHOVER():
		var collider = interactray.get_collider()
		if !interactray.is_colliding() || collider == null:
			$hud/interact.hide()
		if collider != seeing:
			if collider != null and "mouseHOVERED" in collider:
				$hud/interact.text = collider.interactPrompt
				$hud/interact.show()
				collider.mouseHOVERED = true
			if seeing != null and "mouseHOVERED" in seeing:
				$hud/interact.hide()
				seeing.mouseHOVERED = false
			seeing = collider
		
func interactPROMPT(text: String):
	$hud/interact2.text = text
	$hud/interact2.show()
	if not $hud/interact2/timer.is_stopped():
		$hud/interact2/timer.wait_time = 1
	$hud/interact2/timer.start()
	await $hud/interact2/timer.timeout
	$hud/interact2.text = ""
	$hud/interact2.hide()
	
func _input(event):
	
	if Input.is_action_pressed("quit"):
		Main.loadScene("Menu")
		
	if Engine.time_scale == 0:
		return
	if !inventory:
		return
#	if !Main.currentSTATE == Main.STATE.PLAYING:
#		return
	# detect mouse input, handle camera rotation (head), and clamp rotation thereof
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mousesens))
		head.rotate_x(deg_to_rad(-event.relative.y * mousesens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		mouse_input = event.relative
		
func _process(_delta):
	if Main.currentSTATE == Main.STATE.PLAYING:
		interactHOVER()
		cursor.position = get_viewport().size / 2.0
		pass
	else:
		cursor.position = cursor.get_global_mouse_position()
		
func _physics_process(delta):
	if Engine.time_scale == 0:
		return
	# detect movement inputs (WASD)
	if !inventory:
		return
#	if !Main.currentSTATE == Main.STATE.PLAYING:
#		return
		
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if Input.is_action_pressed("duck"): # detect crouching (CTRL)
		currentspeed = duckingspeed
		head.position.y = lerp(head.position.y, 0.6 + duckingdepth, delta*lerpspeed)
		standcollider.disabled = true
		duckcollider.disabled = false
		currentState = STATE.CROUCHING
		# detect empty space for crouching reasons	
	elif !ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y, 0.6, delta*lerpspeed)
		standcollider.disabled = false
		duckcollider.disabled = true
		
		if Input.is_action_pressed("run"):
			if canrun && stamina > 0:
				currentspeed = runspeed
				currentState = STATE.RUNNING
			else:
				currentspeed = walkspeed
				currentState = STATE.WALKING
		else:
			currentspeed = walkspeed
			currentState = STATE.WALKING	
	if is_on_floor() && dangerousfall:
		health -= falldamage
		dangerousfall = false
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
		if velocity.y < -10:
			dangerousfall = true
			falldamage = floorf(-velocity.y) * 5
	
	# states
	match currentState:
		STATE.RUNNING:
			bobbingintensity = runbobbingintensity
			bobbingindex += runbobbingstrength*delta
		STATE.WALKING:
			bobbingintensity = walkbobbingintensity
			bobbingindex += walkbobbingstrength*delta
		STATE.CROUCHING:
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
		walking_streamplayer.stop()
		ismoving = false
	
	if !ismoving:
		currentState = STATE.IDLE
	
	if ismoving && currentState == STATE.RUNNING:
		stamina_decrement()
	elif !currentState == STATE.RUNNING:
		if stamina_cooldown > 0:
			stamina_cooldown -= delta
		elif stamina_cooldown <= 0:
			stamina_increment()
			
	move_and_slide()
	equipped_sway(delta)
	
	if direction != Vector3() and is_on_floor():
		if $player_audio/timer.time_left <= 0:
			var current_walksfx_index = randi() % footsteps_sfx.size()
			if current_walksfx_index == walksfx_index:
				while current_walksfx_index == walksfx_index:
					current_walksfx_index = randi() % footsteps_sfx.size()
			walking_streamplayer.pitch_scale = randf_range(1.2, 1)
			walking_streamplayer.stream = footsteps_sfx[current_walksfx_index]
			walking_streamplayer.play()
			walksfx_index = current_walksfx_index
			match currentState:
				STATE.WALKING:
					$player_audio/timer.start(0.5)
				STATE.RUNNING:
					$player_audio/timer.start(0.35)
				STATE.CROUCHING:
					print("wtf")
					$player_audio/timer.start(1)
				STATE.IDLE:
					walking_streamplayer.stop()
		
	
func stamina_decrement():
	stamina -= stamina_drainrate
	if stamina < 0:
		stamina = 0
	stamina_cooldown = stamina_chargetime
		
func stamina_increment():
	stamina += stamina_chargerate
	if stamina > 100:
		stamina = 100

func stamina_drain_other(todrain: int = 0):
	stamina -= todrain
	if stamina < 0:
		stamina = 0
	stamina_cooldown = stamina_chargetime
	
func equipped_sway(delta):
	
	
	var mouseX = mouse_input.x * vmlerpspeed/3000
	var mouseY = mouse_input.y * vmlerpspeed/3000
	
	
	var rotationY = Basis().rotated(Vector3(0,1,0).normalized(), mouseX)
	var rotationX = Basis().rotated(Vector3(1,0,0).normalized(), -mouseY)
	var targetRotation = rotationX * rotationY
	equipped.basis = equipped.basis.orthonormalized().slerp(targetRotation, 5 * delta)

func hit():
	health = health - 10
