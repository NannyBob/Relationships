extends Panel
var from:DbFunctions.Entity
var to:DbFunctions.Entity
var from_name:String
var to_name:String
onready var entity_lab = get_node("VBoxContainer2/EntityLab")
signal new_relationship



func _on_PickFrom_found_entity(ID:DbFunctions.Entity,name:String):
	from = ID
	from_name = name
	update_entity_lab()


func _on_PickTo_found_entity(ID:DbFunctions.Entity,name:String):
	to = ID
	to_name = name
	update_entity_lab()

func update_entity_lab():
	entity_lab.text = from_name +"\n\nTo:\n\n" + to_name


func _on_GoButt_pressed():
	var desc = get_node("VBoxContainer2/Description").text
	if check_if_relationship(from.ID,to.ID) and not from.ID == to.ID:
		if DbFunctions.add_relationship(from.ID,to.ID,desc):
			get_node("AnimationPlayer").play("Success")
			emit_signal("new_relationship",from.ID,to.ID)
	else:
		get_node("AnimationPlayer").play("Success (copy)")
		
func check_if_relationship(entity1,entity2):
	return DbFunctions.get_relationship_from_to(entity1,entity2) == null and DbFunctions.get_relationship_from_to(entity2,entity1) == null
