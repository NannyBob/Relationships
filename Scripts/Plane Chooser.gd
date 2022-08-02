extends VBoxContainer
var plane_box = preload("res://Interface/Plane Details.tscn")

func fill_planes():
	var planes :Array
	var dir = Directory.new()
	if dir.open("res://Database/") == OK:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file =="":
				break
			elif not file.begins_with("."):
				planes.append(file)
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
	
	var container = $VBoxContainer
	for plane in planes:
		var name = plane.rstrip(".db")
		var new_box = plane_box.instance()
		new_box.fill(name,is_current_plane(name))
		new_box.connect("current_changed",self,"current_plane_changed")
		container.add_child(new_box)

func current_plane_changed():
	var planes :Array= $VBoxContainer.get_children()
	for plane in planes:
		plane.selected_lost()

func is_current_plane(plane:String):
	return plane == DbFunctions.db_name.lstrip("res://Database/").rstrip(".db")
