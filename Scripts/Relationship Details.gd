extends VBoxContainer
var rel_obj:DbFunctions.Relationship
var owner_ent:int
var other_ent:int


func fill(rel,owner):
	rel_obj = rel
	owner_ent = owner
	other_ent = get_other()
	contract()
	get_node("ShowHideButt").text = DbFunctions.get_primary_name(other_ent)
	get_node("DescContainer/Description").text = rel_obj.desc

func get_other():
	var other
	if rel_obj.start != owner_ent:
		other = rel_obj.start
	else:
		other = rel_obj.end
	return other

func contract():
	get_node("DescContainer").hide()
	get_node("DeleteButt").hide()
	$SelectButt.hide()
	$HSeparator.hide()
	
func expand():
	get_node("DescContainer").show()
	get_node("DeleteButt").show()
	$SelectButt.show()
	$HSeparator.show()

func _on_EditButt_pressed():
	var butt = get_node("DescContainer/EditButt")
	var textbox = get_node("DescContainer/Description")
	if textbox.readonly:
		butt.text = "Done"
		textbox.readonly = false
	else:
		if check_textbox():
			if DbFunctions.change_relationship_desc(rel_obj,textbox.text):
				rel_obj.desc = textbox.text
				textbox.readonly = true
				butt.text = "Edit"
			else:
				OS.alert('Query failure', 'Message Title')
		else:
			butt.text = "Edit"
			textbox.text = rel_obj.name
			textbox.readonly = true

func check_textbox():
	var textbox = get_node("DescContainer/Description")
	if textbox.text == "":
		return false
	return true

func _on_ShowHideButt_pressed():
	if get_node("DescContainer").visible:
		contract()
	else:
		expand()


func _on_DeleteButt_pressed():
	DbFunctions.delete_relationship(rel_obj.ID)
	DbFunctions.plane.on_delete_relationship(rel_obj.ID)
	queue_free()


func _on_SelectButt_pressed():
	DbFunctions.plane.on_new_entity_selected(other_ent)
