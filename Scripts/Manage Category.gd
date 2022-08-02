extends Panel
var entity_obj : DbFunctions.Entity
onready var categories:Array= DbFunctions.get_all_categories()

func _ready():
	clear()

func fill(entity):
	$VBoxContainer/HBoxContainer/ChangeButt.disabled = false
	entity_obj = entity
	get_node("VBoxContainer/Category Label").text = "Current Category: " + entity_obj.category
	var options :OptionButton= get_node("VBoxContainer/HBoxContainer/OptionButton")
	for cat in categories:
		if cat.name != entity.category:
			options.add_item(cat.name)

func clear():
	var options :OptionButton= get_node("VBoxContainer/HBoxContainer/OptionButton")
	options.clear()
	$VBoxContainer/HBoxContainer/ChangeButt.disabled = true


func _on_ChangeButt_pressed():
	var options :OptionButton= get_node("VBoxContainer/HBoxContainer/OptionButton")
	var old_category = entity_obj.category
	entity_obj.category =  options.get_item_text(options.selected)
	if DbFunctions.change_entity_category(entity_obj):
		get_node("VBoxContainer/Category Label").text = "Current Category: " + entity_obj.category
	else:
		entity_obj.category = old_category
		OS.alert('Query failure', 'Message Title')
