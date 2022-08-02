extends CanvasLayer
signal hide_relationship_descriptions
signal show_relationship_signals
signal updated_entity
signal updated_relationship
signal new_relationship
onready var categories: Array = DbFunctions.get_all_categories()


# Called when the node enters the scene tree for the first time.
func _ready():
	fill_category_filters()
	fill_planes()

func fill_category_filters():
	var container = $Control/TabContainer/View/VBoxContainer/CategoryFilters
	for category in categories:
		#filters in View tab
		var node :CheckBox= CheckBox.new()
		node.text = category.name
		node.pressed = true
		node.connect("toggled",self,"_on_CategoryFilter_toggled")
		container.add_child(node)
		

func _on_CategoryFilter_toggled(button_pressed):
	var container = $Control/TabContainer/View/VBoxContainer/CategoryFilters
	var forbidden :Array
	print("togle")
	var kids = container.get_children()
	for kid in kids:
		if kid.pressed == false:
			forbidden.append(kid.text)
	DbFunctions.plane.forbidden_categories = forbidden
	DbFunctions.plane.filter_update()

func _on_ShowNamesBox_toggled(button_pressed):
	if button_pressed:
		emit_signal("show_relationship_signals")
	else:
		emit_signal("hide_relationship_descriptions")



func _on_Create_Association_new_relationship(from:int,to:int):
	emit_signal("new_relationship",from,to)


func _on_Node2D_new_selected(entity:DbFunctions.Entity):
	new_selected(entity)

func new_selected(entity:DbFunctions.Entity):
	var entity_opt := get_node("Control/TabContainer/Selected")
	get_node("Control/TabContainer").current_tab = 0
	var name = DbFunctions.get_primary_name(entity.ID)
	entity_opt.new_entity(entity,name)

func fill_planes():
	$Control/TabContainer/View/VBoxContainer/Planes.fill_planes()


