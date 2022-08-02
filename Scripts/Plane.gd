extends Node2D
var entity_index:Dictionary
var relationship_index:Dictionary
var entity_scene = preload("res://2d/Entity.tscn")
var branch_scene = preload("res://2d/Branch.tscn")
var forbidden_categories:Array
var entities:Array 
var relationships:Array
var selected :int = -1
const FOLLOW_SPEED = 4.0
signal new_selected
onready var camera:Camera2D = $Camera2D
func _ready():
	DbFunctions.plane = self
	randomize()
	refill()

func refill():
	set_physics_process(false)
	fill_entities()
	fill_relationships()
	set_physics_process(true)

func _physics_process(delta):
	for branch in relationship_index.values():
		change_pos(branch)
	attractive_forces()
	if selected != -1:
		camera.position = camera.position.linear_interpolate(entity_index[String(selected)].position,FOLLOW_SPEED*delta)
		#entity_index[String(selected)].position + Vector2(0*camera.zoom.x,0)

func fill_entities():
	entities = DbFunctions.get_all_entities()
	for entity in entity_index.values():
		remove_child(entity)
		entity.queue_free()
	entity_index.clear()
	for dict in entities:
		var entity = DbFunctions.Entity.from_dict(dict)
		new_entity(entity)

func new_entity(entity:DbFunctions.Entity):
	var node = entity_scene.instance()
	node.fill(entity)
	entity_index[String(entity.ID)] = node
	node.position = Vector2(randi()%1000,randi()%1000)
	add_child(node)
	node.connect("selected",self,"entity_clicked")

func fill_relationships():
	relationships = DbFunctions.get_all_relationships()
	for rel in relationship_index.values():
		remove_child(rel)
		rel.queue_free()
	relationship_index.clear()
	for dict in relationships:
		var rel :DbFunctions.Relationship= DbFunctions.Relationship.from_dict(dict)
		new_branch(rel)

func change_pos(branch:Line2D):
	branch.clear_points()
	
	var rel = branch.relationship
	var node1 :Node2D= entity_index[String(rel.start)]
	var node2 :Node2D= entity_index[String(rel.end)]
	
	var direction :Vector2= node1.position.direction_to(node2.position)
	
	branch.add_point(node1.position+(direction*95))
	branch.add_point(node2.position-(direction*95))
	
	branch.sprout1.position = node1.position+(direction*105)
	branch.sprout2.position = node2.position-(direction*105)
	var angle = direction.angle()
	branch.sprout1.rotation = angle +0.5 *PI
	branch.sprout2.rotation = angle+ 1.5*PI

	
func attractive_forces():
	for branch in relationship_index.values():
		if branch.enabled_count == 2:
			var start_node :RigidBody2D= entity_index[String(branch.relationship.start)]
			var end_node :RigidBody2D= entity_index[String(branch.relationship.end)]
			
			var distance:Vector2 = end_node.position-start_node.position
			var length:float = distance.length()
			var direction := start_node.position.direction_to(end_node.position)
			var k = 0.5
		
			var force = length*k
		
			start_node.add_edge_force(force*direction)
			end_node.add_edge_force(-force*direction)

func entity_clicked(node:RigidBody2D):
	if selected != node.entity_obj.ID:
		$ScreenHUD/DeselectButt.show()
		if selected != -1:
			entity_index[String(selected)].modulate = Color.white
		on_new_entity_selected(node.entity_obj.ID)
	else:
		entity_index[String(selected)].modulate = Color.white
		selected = -1


func _on_HUD_show_relationship_signals():
	for branch in relationship_index.values():
		branch.get_node("Sprout1/Name").show()
		branch.get_node("Sprout2/Name").show()


func _on_HUD_hide_relationship_descriptions():
	for branch in relationship_index.values():
		branch.get_node("Sprout1/Name").hide()
		branch.get_node("Sprout2/Name").hide()


func _on_HUD_updated_entity(ID:int):
	var node = entity_index[String(ID)]
	node.fill(DbFunctions.get_entity(ID))

func _on_HUD_updated_relationship(ID:int):
	var node = relationship_index[String(ID)]
	node.fill(DbFunctions.get_relationship(ID))


func _on_HUD_new_relationship(from:int,to:int):
	var rel :DbFunctions.Relationship = DbFunctions.get_relationship_from_to(from,to)
	new_branch(rel)

func new_branch(rel):
	var ent1 = entity_index[String(rel.start)]
	var ent2 = entity_index[String(rel.end)]
	var branch = branch_scene.instance()
	add_child(branch)
	branch.fill(rel)
	relationship_index[String(rel.ID)] = branch
	
	ent1.connect("enabled",branch,"ent_enabled")
	ent1.connect("disabled",branch,"ent_disabled")
	
	ent2.connect("enabled",branch,"ent_enabled")
	ent2.connect("disabled",branch,"ent_disabled")
	
	branch.gradient.set_color(0,ent1.colour)
	branch.sprout1.self_modulate = ent1.colour
	branch.gradient.set_color(1,ent2.colour)
	branch.sprout2.self_modulate = ent2.colour
	
	change_pos(branch)

func on_delete_relationship(id):
	var rel_node = relationship_index[String(id)]
	relationship_index.erase(String(id))
	remove_child(rel_node)
	rel_node.queue_free()

func on_new_entity(new_name:String):
	var entity = DbFunctions.find_entity(new_name)
	new_entity(entity)

func on_delete_entity(ID):
	set_physics_process(false)
	var entity_node = entity_index[String(ID)]
	entity_index.erase(String(ID))
	remove_child(entity_node)
	entity_node.queue_free()
	
	if selected==ID:
		selected = -1
	
	fill_relationships()
	set_physics_process(true)

func on_new_entity_selected(ID):
		selected = ID
		var node = entity_index[String(ID)]
		node.modulate = Color.red
		emit_signal("new_selected",node.entity_obj)

func filter_update():
	for entity in entity_index.values():
		var obj :DbFunctions.Entity= entity.entity_obj
		if obj.category in forbidden_categories:
			entity.disable()
			remove_child(entity)
		else:
			if entity.enable():
				add_child(entity)



func _on_DeselectButt_pressed():
	var butt :Button= $ScreenHUD/DeselectButt
	butt.hide()
	entity_clicked(entity_index[String(selected)])
