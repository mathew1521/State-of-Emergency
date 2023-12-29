extends Node
class_name Inventory
var EQUIPPED_SLOT: int = 0
var isopen: bool = false
var isdragging: bool = false
var ishovering: bool = false
var slots: Array[Node]
var selectedslot: int
var hoveredslot: int
var isAnimating: bool = false
signal inventory_closed
signal inventory_opened
var defaultcolour: Color = Color(1,1,1)
@export var selectedcolour: Color
@onready var player = $"../../.."
@onready var item = $item
@onready var equipped = $"../../../head/eyes/maincam/equipped"
@onready var slotsholder = $slots
@export var startingItems: Array[AddItemData]
@export var hasStartingItems: bool = false
var currentItems: Array[AddItemData]

var itemEquipMap = {
	"Pistol": "pistol",
	"Shotgun": "shotgun",
}
	
func updateInventory():
	currentItems.clear()
	for slot in slots:
		if slot.item != null:
			var itemNew = AddItemData.new()
			itemNew.item = slot.item
			itemNew.quantity = slot.quantity
			currentItems.append(itemNew)
	Main.currentInventory = currentItems
			
func _ready():
	slots = slotsholder.get_children()
	EQUIPPED_SLOT = Main.currentSlot
	slots[EQUIPPED_SLOT].visual_node.self_modulate = selectedcolour
	self.visible = false
	isopen = false
	if hasStartingItems:
		for i in startingItems:
			AddItem(i.item, i.quantity)
		pass
		
	currentItems = Main.currentInventory
	
	if currentItems:
		for i in currentItems:
			AddItem(i.item, i.quantity)

func setEquippedSlot(slot: int):
	var origSlot = EQUIPPED_SLOT
	var origItem = slots[EQUIPPED_SLOT].item
	if isAnimating: return
	if player.currentState == player.STATE.RUNNING: return
	EQUIPPED_SLOT = slot
	Main.currentSlot = EQUIPPED_SLOT
	setItemName()
	handleEquip(origSlot, origItem)
	
func setItemName(clear = false):
	if slots[EQUIPPED_SLOT].item:
		item.text = slots[EQUIPPED_SLOT].item.name
	elif slots[EQUIPPED_SLOT].item == null:
		item.text = ""
	if clear:
		item.text = ""
		
#func handleEquip(origSlot = null, origItem: Item = null):
#	var currentItem = GetSelectedItem()
#	var currentItemName = currentItem.name if currentItem else null
#	for itemName in itemEquipMap.keys():
#		var nodePath = itemEquipMap[itemName]
#		var nodeToCheck = equipped.get_node(nodePath)
#		if !nodeToCheck:
#			return
#		if nodeToCheck.isEquipped:
#			if nodeToCheck.animplayer.is_playing():
#				EQUIPPED_SLOT = origSlot
#				setItemName(true)
#				return
#			nodeToCheck.unequip()
#			if nodeToCheck.animplayer.is_playing():
#				await nodeToCheck.animplayer.animation_finished
#			nodeToCheck.isEquipped = false
#
#	for itemName in itemEquipMap.keys():
#		var nodePath = itemEquipMap[itemName]
#		var nodeToEquip = equipped.get_node(nodePath)
#
#		if !nodeToEquip:
#			return
#
#		if nodeToEquip && (nodeToEquip.playingAnim && nodeToEquip.isEquipped):
#			EQUIPPED_SLOT = origSlot
#			setItemName(true)
#			return
#
#		if nodeToEquip.isEquipped:
#			if nodeToEquip.animplayer.is_playing():
#				await nodeToEquip.animplayer.animation_finished
#			nodeToEquip.unequip()
#			if nodeToEquip.animplayer.is_playing(): await nodeToEquip.animplayer.animation_finished
#			nodeToEquip.isEquipped = false
#
#		if currentItemName == itemName:
#			nodeToEquip.equip(currentItem)
#			if nodeToEquip.animplayer.is_playing(): await nodeToEquip.animplayer.animation_finished
#			nodeToEquip.isEquipped = true
#
#		else:
#			if nodeToEquip.isEquipped:
#				nodeToEquip.unequip()
#				if nodeToEquip.animplayer.is_playing(): await nodeToEquip.animplayer.animation_finished
#				nodeToEquip.isEquipped = false

func handleEquip(origSlot = null, _origItem: Item = null):
	if Main.currentSTATE == Main.STATE.INVENTORY:
		await inventory_closed
	var origiItem = equipped.get_children()
	if !origiItem:
		pass
	var currentItem = GetSelectedItem()
	if currentItem:
		if origiItem:
			for child in origiItem:
				if child.item == currentItem: return
				if child.animplayer.is_playing():
					EQUIPPED_SLOT = origSlot
					Main.currentSlot = EQUIPPED_SLOT
					setItemName()
					return
				child.unequip()
				isAnimating = true
				if child.animplayer.is_playing(): await child.animplayer.animation_finished
				isAnimating = false
				child.queue_free()
				if currentItem.scene != null:
					var scene = currentItem.scene.instantiate()
					var scene2 = scene
					equipped.add_child(scene2)
					scene2.equip(currentItem)
					isAnimating = true
					if child.animplayer.is_playing(): await child.animplayer.animation_finished
					isAnimating = false
					scene2.isEquipped = true
		else:
			if currentItem.scene != null:
				var scene = currentItem.scene.instantiate()
				var scene2 = scene
				equipped.add_child(scene2)
				scene2.equip(currentItem)
				isAnimating = true
				if scene2.animplayer.is_playing(): await scene2.animplayer.animation_finished
				isAnimating = false
				scene2.isEquipped = true
	else:
		for child in origiItem:
			if child.animplayer.is_playing():
				EQUIPPED_SLOT = origSlot
				Main.currentSlot = EQUIPPED_SLOT
				setItemName()
				return
			child.unequip()
			isAnimating = true
			if child.animplayer.is_playing(): await child.animplayer.animation_finished
			isAnimating = false
			child.queue_free()
				
func _input(_event):
	if _event is InputEventKey and (_event.keycode >= KEY_1 && _event.keycode <= KEY_8) and not _event.echo and _event.is_pressed() and Main.currentSTATE == Main.STATE.PLAYING:
		slots[EQUIPPED_SLOT].visual_node.self_modulate = defaultcolour
		setEquippedSlot(int(_event.keycode) - 49)
		slots[EQUIPPED_SLOT].visual_node.self_modulate = selectedcolour
	if Input.is_action_just_pressed("inventory"):
		if Main.currentSTATE == Main.STATE.INVENTORY:
			close()
		elif Main.currentSTATE == Main.STATE.PLAYING:
			open()
	pass

func close():
	self.visible = false
	Main.currentSTATE = Main.STATE.PLAYING
	Engine.time_scale = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("inventory_closed")
	if isdragging:
		isdragging = false
		slots[selectedslot].isdragging = false
		slots[selectedslot].candrag = false
		slots[selectedslot].item_node.position = Vector2(0,0)
		slots[selectedslot].item_node.top_level = false
		selectedslot = -1
		
func open():
	self.visible = true
	Main.currentSTATE = Main.STATE.INVENTORY
	Engine.time_scale = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	emit_signal("inventory_opened")
func AddItem(_item: Item, amount: int = 1):
	_item = _item.duplicate()
	if HasSpaceForItem():
		for i in slots.size():
			var slot = slots[i]
			if (slot.item != null &&
				slot.item.name == item.name &&
				slot.quantity <= item.stacksize &&
				item.stackable == true):
					var spaceLeftInStack = item.stacksize - slot.quantity
					if amount <= spaceLeftInStack:
						slot.quantity += amount
						slot.RefreshCount()
						return true
					else:
						slot.quantity = item.stacksize
						slot.RefreshCount()
						amount -= spaceLeftInStack
					updateInventory()

		while amount > 0:
			for i in slots.size():
				var slot = slots[i]
				if (slot.item == null):
					SpawnNewItem(_item, slot, min(amount, _item.stacksize))
					updateInventory()
					if slot.get_index() == EQUIPPED_SLOT:
						setEquippedSlot(EQUIPPED_SLOT)
					amount -= min(amount, _item.stacksize)
					if amount <= 0:
						return true
		return false
	else:
		pass

func SpawnNewItem(_item: Item, slot: Slot, amount: int = 1):
	slot.InitialiseItem(_item, amount)
	
func GetSelectedItem(use: bool = false):
	var itemInSlot = slots[EQUIPPED_SLOT]
	if itemInSlot:
		var _item = itemInSlot.item
		if (use):
			itemInSlot.quantity = itemInSlot.quantity-1
			if (itemInSlot.quantity <= 0):
				itemInSlot.ClearItem()
			else:
				itemInSlot.RefreshCount()
		if _item:
			return _item
	pass
	

func GetTotalItemQuantity(targetItem: Item):
	var totalQuantity: int = 0
	for i in slots.size():
		var slot = slots[i]
		if (slot.item != null && slot.item.name == targetItem.name):
			totalQuantity += slot.quantity
	return totalQuantity

func HasItem(targetItem: Item):
	for i in slots.size():
		var slot = slots[i]
		var _item = slot.item
		if (_item != null && _item == targetItem):
			return true
	return false
	
func HasSpaceForItem():
	for i in slots.size():
		var slot = slots[i]
		var _item = slot.item
		if (_item == null):
			return true
	
func DeductItems(targetItem: Item, amount: int, _total: int):
	var remainingAmount: int = amount
	var stacks: Array[Slot] = []
	for i in slots.size():
		var slot = slots[i]
		var _item = slot.item
		if (_item != null && _item.name == targetItem.name):
			stacks.append(slot)
		
	stacks.sort_custom(CompareCounts)
	for stack in stacks:
		if remainingAmount <= 0:
			break
			
		var itemsToDeduct: int = min(stack.quantity, remainingAmount)
		stack.quantity -= itemsToDeduct
		remainingAmount -= itemsToDeduct
		
		if (stack.quantity <= 0):
			stack.ClearItem()
		stack.RefreshCount()


func CompareCounts(a,b):
	return a.quantity - b.quantity
