extends Panel
var from:DbFunctions.Entity
var to:DbFunctions.Entity
var from_name:String
var to_name:String
onready var entity_lab = get_node("VBoxContainer2/EntityLab")



func _on_StrengthSlider_value_changed(value):
	var label:Label = get_node("VBoxContainer2/StrengthLab")
	label.text = "And Strength: " +String(value)


func _on_PickFrom_found_entity(ID:DbFunctions.Entity,name:String):
	from = ID
	from_name = name
	update_entity_lab()


func _on_PickTo_found_entity(ID:DbFunctions.Entity,name:String):
	to = ID
	to_name = name
	update_entity_lab()

func update_entity_lab():
	entity_lab.text = from_name +"\n\nAnd:\n\n" + to_name
	get_node("VBoxContainer2/DescContainer/VBoxContainer/Label").text = from_name +" To: " +to_name
	get_node("VBoxContainer2/DescContainer/VBoxContainer2/Label").text = to_name +" To: " + from_name


func _on_GoButt_pressed():
	var desc = get_node("VBoxContainer2/DescContainer/VBoxContainer/Description").text
	var desc2 = get_node("VBoxContainer2/DescContainer/VBoxContainer2/Description").text
	var strength = get_node("VBoxContainer2/StrengthSlider").value
	if DbFunctions.add_relationship(from.ID,to.ID,desc,strength) and DbFunctions.add_relationship(to.ID,from.ID,desc2,strength):
		get_node("AnimationPlayer").play("Success")
		
