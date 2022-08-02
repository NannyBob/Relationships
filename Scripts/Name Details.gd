extends HBoxContainer
var name_obj:DbFunctions.Name
onready var textbox = get_node("LineEdit")
var editing:bool = false
signal primary_change

func fill(name):
	name_obj = name
	if name_obj.primary == true:
		modulate = Color.yellow
		get_node("PrimaryButt").hide()
		get_node("DeleteButt").hide()
	textbox.text = name_obj.name

func _on_EditButt_pressed():
	var butt = get_node("EditButt")
	if not textbox.editable:
		butt.text = "Done"
		textbox.editable = true
	else:
		if check_textbox():
			if DbFunctions.change_psuedonym(name_obj,textbox.text):
				name_obj.name = textbox.text
				butt.text = "Edit"
				textbox.text = name_obj.name
				textbox.editable = false
			else:
				OS.alert('Query failure', 'Message Title')
		else:
			butt.text = "Edit"
			textbox.text = name_obj.name
			textbox.editable = false

func check_textbox():
	#checks if there is text in the textbox, and that it is unique
	return DbFunctions.find_entity(textbox.text) == null and textbox.text != ""


func primary_lost():
	modulate = Color.white
	get_node("PrimaryButt").show()
	get_node("DeleteButt").show()

func _on_PrimaryButt_pressed():
	emit_signal("primary_change")
	DbFunctions.make_primary(name_obj)
	name_obj.primary = true
	modulate = Color.yellow
	get_node("PrimaryButt").hide()
	get_node("DeleteButt").hide()


func _on_DeleteButt_pressed():
	DbFunctions.delete_name(name_obj)
	self.queue_free()


func _on_LineEdit_text_entered(new_text):
	_on_EditButt_pressed()
