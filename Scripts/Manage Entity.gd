extends Panel
var names:Array
var relationships:Array
var name_box = preload("res://Interface/Name Details.tscn")
var rel_box = preload("res://Interface/Relationship Details.tscn")
var entity :DbFunctions.Entity= null

# Called when the node enters the scene tree for the first time.

func fill(entity):
	self.entity = entity
	names = DbFunctions.get_all_names(entity.ID)
	relationships = DbFunctions.get_relationships(entity.ID)
	get_node("VBoxContainer/NameLab").text = DbFunctions.get_primary_name(entity.ID)
	fill_relationships()
	fill_names()
	get_node("VBoxContainer/TabContainer/Category").fill(entity)

func fill_names():
	for name in names:
		new_name(name)

func new_name(name):
	var container:=get_node("VBoxContainer/TabContainer/Names/VBoxContainer/ScrollContainer/VBoxContainer")
	var new_box = name_box.instance()
	container.add_child(new_box)
	new_box.fill(name)
	new_box.connect("primary_change",self,"primary_change")

func fill_relationships():
	var container = get_node("VBoxContainer/TabContainer/Relationships/ScrollContainer/VBoxContainer")
	for rel in relationships:
		var new_box = rel_box.instance()
		container.add_child(new_box)
		new_box.fill(rel,entity.ID)

func primary_change():
	var container:=get_node("VBoxContainer/TabContainer/Names/VBoxContainer/ScrollContainer/VBoxContainer")
	var kids = container.get_children()
	for kid in kids:
		kid.primary_lost()

func clear_node_children(node:Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func clear():
	names.clear()
	relationships.clear()
	$VBoxContainer/NameLab.text =""
	$VBoxContainer/TabContainer/Other/VBoxContainer/DeleteButt.text = "Delete"
	get_node("VBoxContainer/TabContainer/Category").clear()
	clear_node_children(get_node("VBoxContainer/TabContainer/Names/VBoxContainer/ScrollContainer/VBoxContainer"))
	clear_node_children(get_node("VBoxContainer/TabContainer/Relationships/ScrollContainer/VBoxContainer"))

func plane_selected(entity_obj):
	pass


func _on_NewNameButt_pressed():
	var new_name = $VBoxContainer/TabContainer/Names/VBoxContainer/HBoxContainer/LineEdit.text
	if DbFunctions.add_psuedonym(entity.ID,new_name):
		new_name(DbFunctions.Name.new(entity.ID,new_name,false))


func _on_DeleteButt_pressed():
	var butt = $VBoxContainer/TabContainer/Other/VBoxContainer/DeleteButt
	if butt.text == "Delete":
		butt.text = "Press again to delete."
		$VBoxContainer/TabContainer/Other/VBoxContainer/DeleteButt/DeleteTimer.start(5)
	else:
		if DbFunctions.delete_entity(entity.ID):
			DbFunctions.plane.on_delete_entity(entity.ID)
			clear()


func _on_DeleteTimer_timeout():
	$VBoxContainer/TabContainer/Other/VBoxContainer/DeleteButt.text = "Delete"
