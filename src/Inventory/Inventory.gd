extends StaticBody
class_name Inventory



# Varaibles #
var inventory := []



# Signals #
signal inventory_changed
signal item_added(item) # `item` must be Object
signal item_erased(item) # `item` must be Object
signal item_removed(index) # `index` must be int



# Virtuals #
func _render() -> void: pass
func _update() -> void: pass
func _inventory_changed() -> void: pass
func _item_added(item : Object) -> void: pass
func _item_erased(item : Object) -> void: pass
func _item_removed(idnex : int) -> void: pass



func append(item : Object) -> void:
	inventory.append(inventory)
	
	_inventory_changed()
	_item_added(item)
	emit_signal("inventory_changed")
	emit_signal("item_added", item)
	
	update()



func erase(item : Object) -> void:
	inventory.erase(item)
	
	_inventory_changed()
	_item_erased(item)
	emit_signal("inventory_changed")
	emit_signal("item_erased", item)
	
	update()



func remove(index : int) -> void:
	inventory.remove(index)
	
	_inventory_changed()
	_item_removed(index)
	emit_signal("inventory_changed")
	emit_signal("item_removed", index)
	
	update()



func update() -> void:
	_update()
	_render()
