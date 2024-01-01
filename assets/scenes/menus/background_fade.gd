extends TextureRect

@export var textures: Array[Texture2D]
var tween : Tween
var current_index: int = -1
var duration_seconds: float = 5

func _ready():
	tween = get_tree().create_tween()
	fade_in()
	
func fade_in():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	print("Fading in.")
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	await tween.finished
	await get_tree().create_timer(duration_seconds).timeout
	fade_out()
	
func fade_out():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	print("Fading out.")
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.2)
	await tween.finished
	on_fade_out_complete()

func on_fade_out_complete():
	current_index += 1
	if current_index >= textures.size():
		current_index = -1
	if self.texture != textures[current_index]:
		self.texture = textures[current_index]
	elif self.texture == textures[current_index]:
		on_fade_out_complete()
	fade_in()
