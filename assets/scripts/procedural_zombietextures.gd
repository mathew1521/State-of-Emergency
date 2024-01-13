extends SubViewport
@onready var mesh = $"../armature/skeleton/mesh"
@export var masc_mesh: Mesh
@export var fem_mesh: Mesh
@onready var cur_mesh = $"../armature/skeleton/mesh"
@onready var hair_mesh = $"../armature/skeleton/head/hair"
@export var shirtTextures: Array[Texture2D]
@export var pantsTextures: Array[Texture2D]
@export var jacketTextures: Array[Texture2D]
@export var masc_hairTextures: Array [Texture2D]
@export var fem_hairTextures: Array [Texture2D]
@export var bodyTextures: Array[CompressedTexture2D]
@export var shoeTextures: Array [Texture2D]
@export var fem_hairMeshes: Array[Mesh]
@export var masc_hairMeshes: Array[Mesh]
@export var hairTextures: Array[Texture2D]
@onready var jacket = $jacket
@onready var shirt = $shirt
@onready var pants = $pants
@onready var skin = $skin
@onready var hair = $hair
@onready var shoes = $shoes
@onready var grime = $grime
@onready var parent = $".."

func _ready():
	_refresh()
	pass

func _refresh():
	var rng = randi_range(0,1)
	match rng:
		0:
			cur_mesh.mesh = masc_mesh
			hair_mesh.mesh = masc_hairMeshes[randi() % masc_hairMeshes.size()]
			#hair.texture = masc_hairTextures[randi() % masc_hairTextures.size()]
			hair.z_index = 2
		1:
			cur_mesh.mesh = fem_mesh
			#hair.texture = fem_hairTextures[randi() % fem_hairTextures.size()]
			hair_mesh.mesh = fem_hairMeshes[randi() % fem_hairMeshes.size()]
			hair.z_index = 6
	shoes.texture = shoeTextures[randi() % shoeTextures.size()]
	skin.texture = bodyTextures[randi() % bodyTextures.size()]
	pants.texture = pantsTextures[randi() % pantsTextures.size()]
	shirt.texture = shirtTextures[randi() % shirtTextures.size()]
	jacket.texture = jacketTextures[randi() % jacketTextures.size()]
	shirt.z_index = 3
	pants.z_index = 4
	skin.z_index = 0
	shoes.z_index = 1
	jacket.z_index = 5
	grime.z_index = 10
	if jacket.texture == jacketTextures[0]:
		$"../armature/skeleton/torso/jacketdecal".visible = true
	var texture = self.get_texture()
	var hairTexture = hairTextures[randi() % hairTextures.size()]
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_texture = texture
	hair_mesh.material_override = hair_mesh.material_override.duplicate()
	hair_mesh.material_override.albedo_texture = hairTexture

