extends Control

onready var text_entry :LineEdit= get_node("VBoxContainer/HBoxContainer/TextEntry")
onready var butt_container :VBoxContainer= get_node("VBoxContainer/ScrollContainer/ButtContainer")
onready var new_entity_butt:Button = get_node("VBoxContainer/HBoxContainer/NewEntityButt")
signal found_entity

func _on_SearchButt_pressed():
	clear_butt_container_children()
	new_entity_butt.hide()
	var entity :DbFunctions.Entity= DbFunctions.find_entity(text_entry.text)
	if entity == null:
		
		var similar_names :Array= DbFunctions.find_similar_names(text_entry.text)
		new_entity_butt.show()
		for name in similar_names:
			add_selection_butt(name)
		
	else:
		clear_butt_container_children()
		emit_signal("found_entity",entity,text_entry.text)
		return
		

func selection_butt_pressed(name:String):
	text_entry.text = name
	get_node("VBoxContainer/HBoxContainer/NewEntityButt").hide()
	clear_butt_container_children()
	emit_signal("found_entity",DbFunctions.find_entity(name),name)

func add_selection_butt(name:String):
	var new_butt:Button = Button.new()
	new_butt.text = name
	new_butt.connect("button_up",self,"selection_butt_pressed",[name])
	butt_container.add_child(new_butt)

func clear_butt_container_children():
	for n in butt_container.get_children():
		butt_container.remove_child(n)
		n.queue_free()

func _ready():
	new_entity_butt.hide()
	text_entry.modulate = Color.white


func _on_NewEntityButt_pressed():
	var popup :WindowDialog= get_node("MakeEntityPop")
	popup.show()
	popup.new_name = text_entry.text
	popup.fill()
	clear_butt_container_children()
	

func _on_TextEntry_text_changed(new_text):
	get_node("VBoxContainer/HBoxContainer/NewEntityButt").hide()



func _on_MakeEntityPop_entity_created():
	_on_SearchButt_pressed()


func _on_TextEntry_text_entered(new_text):
	_on_SearchButt_pressed()
