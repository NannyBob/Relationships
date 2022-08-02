extends Line2D
onready var sprout1 = get_node("Sprout1")
onready var sprout2 = get_node("Sprout2")
var relationship :DbFunctions.Relationship
var enabled_count = 2

func fill(rel):
	show_behind_parent = true
	relationship = rel
	var uno = $Sprout1/Name
	var dos = $Sprout2/Name
	uno.text = relationship.desc
	dos.text = relationship.desc
	uno.hide()
	dos.hide()
	uno.show_on_top = true
	dos.show_on_top = true

func ent_enabled():
	enabled_count = enabled_count+1
	if enabled_count == 2:
		show()

func ent_disabled():
	hide()
	enabled_count = enabled_count-1
