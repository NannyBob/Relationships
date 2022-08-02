extends HBoxContainer

var plane_name:String
var current:bool = true
signal current_changed
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func fill(txt,current):
	name = txt
	get_node("LineEdit").text = txt
	self.current = current
	
	if current:
		modulate = Color.yellow
		get_node("SelectButt").hide()


func _on_EditButt_pressed():
	var butt = get_node("EditButt")
	var edit = get_node("LineEdit")
	if edit.editable:
		if edit_name(edit.text):
			butt.text = "Edit"
			edit.editable = false
	else:
		butt.text = "Done"
		edit.editable = true


func _on_SelectButt_pressed():
	emit_signal("current_changed")
	modulate = Color.yellow
	get_node("SelectButt").hide()
	DbFunctions.switch_db("res://Database/" + $LineEdit.text + ".db") 
	print(DbFunctions.db_name)
	DbFunctions.plane.refill()
	
	
func selected_lost():
	modulate = Color.white
	get_node("SelectButt").show()


func edit_name(input):
	return DbFunctions.rename_file(plane_name+".db",input+".db")


func _on_LineEdit_text_entered(new_text):
	_on_EditButt_pressed()
