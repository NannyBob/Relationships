extends Panel
signal delete_relationship
signal update_relationship
signal new_entity
signal update_entity

func _ready():
	get_node("TabContainer").current_tab=0

func _on_Chooser_found_entity(entity:DbFunctions.Entity,name:String):
	new_entity(entity,name)


func _on_BackButton_pressed():
	back()

func new_entity(entity:DbFunctions.Entity,name:String):
	get_node("TabContainer/VBoxContainer/Manage").clear()
	get_node("TabContainer/VBoxContainer/Manage").fill(entity)
	get_node("TabContainer").current_tab = 1

func back():
	get_node("TabContainer/VBoxContainer/Manage").clear()
	get_node("TabContainer").current_tab=0



func _on_Manage_delete_entity():
	pass # Replace with function body.


