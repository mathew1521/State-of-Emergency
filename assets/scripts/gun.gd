# Every equippable thing in the game inherits from this class. Depending on the item type located in the equipped item's
# attached Item class, the player will either be able to shoot, or not. Soon, I'll add consumables as well (medkits, pills..)
# There are things to improve here. There's a bit of deprecated code left around, too. I'll come back to comment everything
# thoroughly soon.
extends Node3D

@onready var audioplayer = $audioplayer
@onready var animplayer = $animplayer
@onready var cameracolraycast = $"../../cameracolraycast"
@onready var bulletpoint = $"../../../.."
@onready var timer = $timer
@onready var model = $model
@onready var inventory = $"../../../../../hud/inventorylayer/inventory"
@onready var camera_shake = $"../.."
@onready var player = $"../../../../.."
var canreload: bool = false
var isEquipped: bool = false
var canshoot: bool = false
var canshove: bool = false
var equipped: bool = false
var isshooting: bool = false
var isreloading: bool = false
var cooldown: int
#var currentammo: int
var item: Item
var playingAnim: bool = false
var isshoving: bool = false
var isrunning: bool = false
var isaiming: bool = false
var reserveammo: int
var ammochecktimer = 0.0

var mouse_mov = Vector2()

enum STATE {
	IDLE,
	RELOADING,
	SHOVING,
	SHOOTING,
	RUNNING,
	UNEQUIPPING,
	EQUIPPING,
	AMMOCHECKING,
}

var currentState: STATE = STATE.IDLE

func setState(newState: STATE):
	currentState = newState
	match currentState:
		STATE.IDLE:
			pass
		STATE.RELOADING:
			pass
		STATE.SHOVING:
			pass
		STATE.SHOOTING:
			pass
		STATE.RUNNING:
			pass
		STATE.EQUIPPING:
			pass
		STATE.UNEQUIPPING:
			pass
			
func equip(itemA: Item = null):
	if currentState == STATE.IDLE:
		currentState = STATE.EQUIPPING
		canshoot = false
		equipped = false
		if !itemA:
			return
		item = itemA
		if ("firerate") in item:
			cooldown = item.firerate
			timer.wait_time = item.firerate
		if !inventory.isopen:
			animplayer.play("equip")
		await get_tree().create_timer(0.1).timeout
		self.visible = true
		playingAnim = true
		if animplayer.is_playing(): await animplayer.animation_finished
		playingAnim = false
		canshoot = true
		canreload = true
		equipped = true
		canshove = true
		currentState = STATE.IDLE
	
func unequip():
	if currentState == STATE.IDLE:
		currentState = STATE.UNEQUIPPING
		canshoot = false
		canshove = false
		if !inventory.isopen:
			animplayer.play("unequip")
		playingAnim = true
		if animplayer.is_playing(): await animplayer.animation_finished
		playingAnim = false
		equipped = false
		self.visible = false
		currentState = STATE.IDLE
		player.canrun = true
	
func _ready():
	self.visible = false
	equipped = false
	#loop_print()
	pass
	
func loop_print():
	while true:
		print(currentState)
		await get_tree().create_timer(0.5).timeout

func _ammocheck():
	if item.type == 0:
		if currentState == STATE.IDLE:
			currentState = STATE.AMMOCHECKING
			playingAnim = true
			animplayer.play("ammocheck")
			print(item.currentammo)
			if animplayer.is_playing(): await animplayer.animation_finished
			currentState = STATE.IDLE
			playingAnim = false
			
func _reload():
	if item.type == 0:
		if currentState == STATE.IDLE:
			reserveammo = inventory.GetTotalItemQuantity(item.ammotype)
			if item.currentammo == item.maxcurrentammo: return
			if reserveammo == 0: return
			currentState = STATE.RELOADING
			playingAnim = true
			isreloading = true
			animplayer.play("reload")
			if animplayer.is_playing(): await animplayer.animation_finished
			currentState = STATE.IDLE
			playingAnim = false
			isreloading = false
			var ammoReloaded = item.maxcurrentammo - item.currentammo
			if (ammoReloaded > reserveammo):
				item.currentammo = reserveammo + item.currentammo
				reserveammo = 0
				inventory.DeductItems(item.ammotype, ammoReloaded, inventory.GetTotalItemQuantity(item.ammotype))
			else:
				reserveammo = reserveammo - ammoReloaded
				item.currentammo = item.maxcurrentammo
				inventory.DeductItems(item.ammotype, ammoReloaded, inventory.GetTotalItemQuantity(item.ammotype))
			pass

func decrement_reserves():
	pass
func _shove():
	if currentState == STATE.IDLE:
		playingAnim = true
		isshoving = true
		if "recoil" in item:
			camera_shake.add_trauma(item.recoil*10)
		else:
			camera_shake.add_trauma(5)
		animplayer.play("shove")
		var cameracol = getcameracol(0.035)
		hitscan(cameracol)
		currentState = STATE.SHOVING
		player.canrun = false
		if animplayer.is_playing(): await animplayer.animation_finished
		player.canrun = true
		currentState = STATE.IDLE
		isshoving = false
		playingAnim = false

func _signal_disable_monitoring():
	$model/StaticBody3D.monitoring = false
	
func _shoot():
	if item.type == 1:
		if currentState == STATE.IDLE:
			if not timer.is_stopped():
				return
			timer.start()
			var cameracol = getcameracol(item.effectiverange)
			if animplayer.is_playing():
				pass
			else:
			#	var cameracollision = Get_Camera_Collision()
				camera_shake.add_trauma(item.recoil)
#				var rng: int = randi_range(1,2)
				melee_anim_dir()
#				if rng == 1:
#					animplayer.play("shoot")
#				if rng == 2:
#					animplayer.play("shoot_2")
				$model/StaticBody3D.monitoring = true
				isshooting = true
				playingAnim = true
				audioplayer.play()
				#hitscan(cameracol)
				currentState = STATE.SHOOTING
				if animplayer.is_playing(): await animplayer.animation_finished
				currentState = STATE.IDLE
				$model/StaticBody3D.monitoring = false
				self.translate(Vector3(0,0,0))
				playingAnim = false
				isshooting = false
				pass
	if item.type == 0:
		if currentState == STATE.IDLE:
			if not timer.is_stopped():
				return
			if (item.currentammo >= 1):
				item.currentammo -=1
				timer.start()
			else: return
			var cameracol = getcameracol(item.effectiverange)
			if animplayer.is_playing():
				pass
			else:
				camera_shake.add_trauma(item.recoil)
				animplayer.play("shoot")
				isshooting = true
				playingAnim = true
				audioplayer.play()
				if item.firemode == "semi":
					hitscan(cameracol)
				elif item.firemode == "pump":
					shotgun_hitscan(cameracol)
				currentState = STATE.SHOOTING
				if animplayer.is_playing(): await animplayer.animation_finished
				currentState = STATE.IDLE
				playingAnim = false
				isshooting = false
				pass
				

		
func _process(_delta):
	if Input.is_action_pressed("reload"):
		ammochecktimer += _delta
		if ammochecktimer >= 1.0:
			_ammocheck()
			ammochecktimer = 0.0
	if Input.is_action_just_released("reload"):
		ammochecktimer = 0.0
		_reload()
	if player.currentState == player.STATE.RUNNING && player.ismoving:
		if currentState == STATE.IDLE:
			animplayer.play("run", 0.35)
			currentState = STATE.RUNNING
	else:
		if currentState == STATE.RUNNING:
			animplayer.play("idling", 0.35)
			if animplayer.is_playing(): await animplayer.animation_finished
			currentState = STATE.IDLE
	match currentState:
		STATE.IDLE:
			player.canrun = true
			pass
		STATE.RELOADING:
			pass
		STATE.SHOVING:
			pass
		STATE.SHOOTING:
			pass
		STATE.RUNNING:
			pass
		STATE.EQUIPPING:
			player.canrun = false
			pass
		STATE.UNEQUIPPING:
			player.canrun = false
			pass
			
func _run():
	pass
		
func melee_anim_dir():
	var angle = mouse_mov.angle_to(Vector2(1, 0))  # Assuming right is the initial direction
	if abs(mouse_mov.y) > abs(mouse_mov.x):
		if mouse_mov.y < 0:
			animplayer.play("shoot_4")
		else:
			animplayer.play("shoot_2")
	else:
		if angle < 0:
			animplayer.play("shoot")
		else:
			animplayer.play("shoot_3")
			
func _input(_event):
	if !Main.currentSTATE == Main.STATE.PLAYING:
		return
	if !equipped:
		return
	if currentState == STATE.IDLE:
		if _event is InputEventMouseMotion:
			mouse_mov = _event.relative
		if Input.is_action_pressed("ui_text_backspace"):
			if equipped:
				unequip()
			if !equipped:
				equip()
		if Input.is_action_just_pressed("leftclick"):
			_shoot()
		if Input.is_action_just_released("leftclick"):
			pass
		if Input.is_action_pressed("shove"):
			_shove()
	if Input.is_action_just_pressed("run"):
		_run()
	if Input.is_action_just_released("run"):
		_run()
# Called every frame. 'delta' is the elapsed time since the previous frame.



func getcameracol(range: float)->Vector3:
	var cam = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	var rayorigin = cam.project_ray_origin(viewport/2)
	var rayend = rayorigin + cam.project_ray_normal(viewport/2)*range # Find a way to get stuff rolling
	var newintersection = PhysicsRayQueryParameters3D.create(rayorigin,rayend)
	var intersection = get_world_3d().direct_space_state.intersect_ray(newintersection)
	
	if not intersection.is_empty():
		var colpoint = intersection.position
		return colpoint
	else:
		return rayend
		
func hitscan(colpoint):
	var dir = (colpoint - bulletpoint.get_global_transform().origin).normalized()
	var newintersection = PhysicsRayQueryParameters3D.create(bulletpoint.get_global_transform().origin, colpoint + dir * 2)
	var bulletcol = get_world_3d().direct_space_state.intersect_ray(newintersection)
	
	if bulletcol:
		damage(bulletcol.collider)

func shotgun_hitscan(colpoint):
	for i in range(item.pellets):
		var spreadDirection = (colpoint - bulletpoint.get_global_transform().origin).normalized()
		var spreadDirection2 = spreadDirection.rotated(Vector3.UP, randf_range(-item.spread, item.spread))
		var newintersection = PhysicsRayQueryParameters3D.create(bulletpoint.get_global_transform().origin, colpoint + spreadDirection * 2 + spreadDirection2)
		var bulletcol = get_world_3d().direct_space_state.intersect_ray(newintersection)
		print(bulletcol)

		if bulletcol:
			damage(bulletcol.collider)
		
		

func damage(Collider):
	if Collider.is_in_group("zombie"):
		print(Collider.get_parent().get_parent().get_parent().get_parent().name)
		var tryhealth = Collider.get_parent().get_parent().get_parent().get_parent().get_node("health")
		if tryhealth:
			if "damage" in item:
				tryhealth.damage(item.damage/10)
			else:
				tryhealth.damage(5)
		pass
		

func _on_static_body_3d_body_entered(body):
	if body.is_in_group("zombie"):
		damage(body)
	pass # Replace with function body.
