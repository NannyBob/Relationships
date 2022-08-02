extends WindowDialog

export var new_name:String
signal entity_created
# Called when the node enters the scene tree for the first time.
func _ready():
	var categories = DbFunctions.get_all_categories()
	var dropdown :OptionButton= get_node("HBoxContainer/Categories")
	for cat in categories:
		dropdown.add_item(cat.name)

func fill():
	get_node("HBoxContainer/EntityNameLab").text = "Creating Entity: " + new_name
	
	




func _on_CreateButt_pressed():
	var dropdown :OptionButton= get_node("HBoxContainer/Categories")
	var category = dropdown.get_item_text(dropdown.selected)
	DbFunctions.add_entity(new_name,category)
	emit_signal("entity_created")
	DbFunctions.plane.on_new_entity(new_name)
	hide()
