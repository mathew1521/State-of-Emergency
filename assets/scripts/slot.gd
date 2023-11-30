extends Node
class_name Slot

@onready var visual_node = $visual
@onready var item_node = $visual/item
@onready var quantity_node = $visual/item/quantity
@onready var inventory = $"../.."
@onready var slots = $".."
var ishovering: bool
var slot_index: int
var quantity: int
var item: Item
var parentAfterDrag: Node
var parentBeforeDrag: Node
var nodeAfterDrag: Node
var status: String = "None"
var ispicked: bool = false
var isdragging: bool
var candrag: bool
var dragStartPosition
signal mouse_released
signal slotInput(index: int, button: int)

func _ready():
	slot_index = self.get_index()
	pass


func _process(_delta):
		if inventory.isdragging && isdragging:
			inventory.selectedslot = slot_index
			inventory.slots[inventory.selectedslot].item_node.position = self.item_node.get_global_mouse_position()
			inventory.slots[inventory.selectedslot].item_node.top_level = true
			inventory.slots[inventory.selectedslot].item_node.scale = Vector2(0.2, 0.2)
		elif !inventory.isdragging && !isdragging:
			inventory.slots[inventory.selectedslot].item_node.position = Vector2(0,0)
			inventory.slots[inventory.selectedslot].item_node.top_level = false
			inventory.slots[inventory.selectedslot].item_node.scale = Vector2(0.1, 0.1)
			inventory.selectedslot = -1
			pass
		pass
		
func ClearItem():
	if item:
		quantity = 0
		item = null
		item_node.texture = null
		RefreshCount()
	else:
		quantity = 0
		item_node.texture = null
		RefreshCount()
	
func InitialiseItem(newItem: Item, amount: int = 1):
	if newItem:
		item = newItem.duplicate()
		item_node.texture = newItem.texture
		quantity = amount
		item.quantity = quantity
		RefreshCount()
		pass
	else:
		pass

func SwapItem(otherSlot: Slot):
	var _tempItem = item
	var _tempQuantity = quantity
	InitialiseItem(otherSlot.item.duplicate(), otherSlot.quantity)
	otherSlot.InitialiseItem(_tempItem.duplicate(), _tempQuantity)

	RefreshCount()
	otherSlot.RefreshCount()
	
func RefreshCount():
	quantity_node.text = str(quantity)
	var textActive: bool = (quantity > 1)
	quantity_node.visible = textActive

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		candrag = true
		dragStartPosition = event.global_position
		inventory.isdragging = false
		isdragging = false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if !inventory.isdragging && !isdragging:
			inventory.slots[inventory.EQUIPPED_SLOT].visual_node.self_modulate = Color(1,1,1)
			inventory.setEquippedSlot(slot_index)
			inventory.slots[inventory.EQUIPPED_SLOT].visual_node.self_modulate = Color(0,1,0)
		candrag = false
		inventory.isdragging = false
		isdragging = false
		handle_dropped_data(event.global_position)

	if event is InputEventMouseMotion:
		if candrag and dragStartPosition.distance_to(event.global_position) > 10:  # Adjust the threshold as needed
			inventory.isdragging = true
			isdragging = true
		else:
			inventory.isdragging = false
			isdragging = false
			
	
func handle_dropped_data(_position):
	if inventory.ishovering:
		if inventory.hoveredslot != slot_index:
			if inventory.slots[inventory.hoveredslot].item && item:
				SwapItem(inventory.slots[inventory.hoveredslot])
			else:
				inventory.slots[inventory.hoveredslot].InitialiseItem(item, quantity)
				ClearItem()
				
	pass


func _on_mouse_entered():
	ishovering = true
	inventory.ishovering = true
	inventory.hoveredslot = slot_index
	pass # Replace with function body.


func _on_mouse_exited():
	ishovering = false
	inventory.ishovering = false
	inventory.hoveredslot = -1
	pass # Replace with function body.
