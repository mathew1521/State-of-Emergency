extends Node
class_name Console
var isopen: bool = false
@onready var output = $panel/output
@onready var input = $panel/input
var itemArrayNames = []
var itemArrayResources = []
var resourcesDir = "res://assets/resources"
@onready var inventory = $"../../inventorylayer/inventory"

var helpString: String = """!help - ALL AVAILABLE COMMANDS
!give - GIVES AN ITEM ( ex. !give 'item_name' 'quantity' )
..cont.	  - MUST USE RESOURCE NAME ("Pistol Ammo" - pistol_ammo)
!resourcelist - OUTPUTS ALL (ITEM) RESOURCE NAMES"""

# Called when the node enters the scene tree for the first time.
func _ready():
	isopen = false
	self.visible = false
	loadResources(resourcesDir)
	output.push_color(Color("yellow"))
	output.add_text("DEVELOPER CONSOLE. COMMAND PREFIX: '!'. TYPE '!help' TO VIEW AVAILABLE COMMANDS.")
	output.newline()
	output.pop()
	if !inventory:
		output.push_color(Color("red"))
		output.add_text("WARNING! INVENTORY UI MISSING. CERTAIN COMMANDS OMITTED.")
		output.newline()
		output.pop()
	pass # Replace with function body.

func loadResources(directory):
	var dir = DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var item_name = file_name.trim_suffix(".tres")
				var item_resource = ResourceLoader.load("res://assets/resources/" + file_name)
				if item_resource != null:
					itemArrayNames.append(item_name)
					itemArrayResources.append(item_resource)
				else:
					pass
			file_name = dir.get_next()
	else:
		pass
	return itemArrayNames
	return itemArrayResources
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_just_pressed("console"):
		if isopen:
			isopen = false
			self.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif !isopen:
			isopen = true
			self.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func _on_input_text_submitted(command):
	if command:
		output.push_color("white")
		output.add_text(handle_command(str(command)))
		output.newline()
		output.pop()
	pass
	
func handle_command(command: String):
	var cmdparts = command.split(" ")
	
	match cmdparts[0]:
		"!help":
			return str(helpString)
		"!give":
			if cmdparts.size() == 3:
				var targetName = cmdparts[1]
				var amount = cmdparts[2].to_int()
				var index = itemArrayNames.find(targetName)
				if !inventory:
					output.push_color("red")
					return("Unable to add: " + targetName + " of Quantity: " + str(amount) + ", the player's inventory is missing.")
				if index != -1:
					var item = itemArrayResources[index]
					inventory.AddItem(item, amount)
					output.push_color("green")
					return ("Added: " + item.name + " of Quantity: " + str(amount))
				else:
					return "Invalid name or quantity."
			else:
				return "Invalid format."
		"!resourcelist":
			return ("Valid resource names located in res://assets/resources: " + str(itemArrayNames))
		_:
			return("Invalid command: " + "'" + command + "'.")
