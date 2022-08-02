extends RigidBody2D
var entity_obj :DbFunctions.Entity
export var edge_force :Vector2
var prev_edge_force:= Vector2.ZERO
export var colour:Color
signal selected
signal enabled
signal disabled
var enabled = true 
var anchored = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var label = get_node("Label")
	label.show_on_top = true
	pass # Replace with function body.

func _physics_process(delta):
	applied_force += edge_force-prev_edge_force
	prev_edge_force = edge_force
	edge_force = Vector2.ZERO

func disable():
	if enabled:
		enabled = false
		emit_signal("disabled")

#returns true if enabled
func enable():
	if not enabled:
		enabled = true
		emit_signal("enabled")
		return true
	return false

func anchor():
	anchored = true
	mode = MODE_STATIC
	rotation = 0
	$Anchor.show()
	
func deanchor():
	anchored = false
	mode = MODE_RIGID
	$Anchor.hide()

func fill(entity):
	entity_obj = entity
	get_node("Label").text = DbFunctions.get_primary_name(entity.ID)
	colour = DbFunctions.get_category_colour(entity.category)
	get_node("Sprite").modulate = colour

func add_edge_force(vct):
	edge_force += vct


func _on_Entity_input_event(viewport, event:InputEvent, shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected",self)
	elif event.is_action_pressed("rclick"):
		if anchored:
			deanchor()
		else:
			anchor()
	
