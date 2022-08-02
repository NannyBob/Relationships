extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
var db_name = "res://Database/1.db"
var plane:Node = null

class Entity:
	var ID: int
	var category: String
	func _init(ID,cat):
		self.ID = ID
		if cat == null:
			self.category = ""
		else:
			self.category = cat
		
	static func to_dict(ent_obj:Entity):
		var dict:Dictionary
		dict["ID"] = ent_obj.ID
		dict["Category"] = ent_obj.category
		return dict
	
	static func from_dict(dict):
		return Entity.new(dict["ID"],dict["Category"])

class Name:
	var entityID: int
	var name:String
	var primary:bool
	
	func _init(ID,name,primary):
		self.entityID = ID
		self.name = name
		self.primary = primary
	
	static func to_dict(name_obj:Name):
		var dict:Dictionary
		dict["EntityID"] = name_obj.entityID
		dict["Name"] = name_obj.name
		if name_obj.primary:
			dict["PrimaryName"] = 0
		else:
			dict["PrimaryName"]=1
		return dict
	
	static func from_dict(dict):
		var prim :bool
		if dict["PrimaryName"] == 0:
			prim = false
		else:
			prim = true 
		return Name.new(dict["EntityID"],dict["Name"],prim)

class Relationship:
	var ID: int
	var start: int
	var end: int
	var desc:String
	
	func _init(ID,start,end,desc):
		self.ID = ID
		self.start = start
		self.end = end
		self.desc = desc
	
	static func to_dict(rel_obj:Relationship):
		var dict:Dictionary
		dict["ID"] = rel_obj.ID
		dict["Start"] = rel_obj.start
		dict["End"] = rel_obj.end
		dict["Description"] = rel_obj.desc
		return dict
		
	static func from_dict(dict):
		return Relationship.new(dict["ID"],dict["Start"],dict["End"],dict["Description"])

class Category:
	var colour:Color
	var name:String
	
	func _init(name,colour):
		self.colour = colour
		self.name = name
	
	static func to_dict(cat_obj:Category):
		var dict:Dictionary
		dict["Red"] = cat_obj.colour.r8
		dict["Green"] = cat_obj.colour.g8
		dict["Blue"] = cat_obj.colour.b8
		dict["Name"] = cat_obj.name
		return dict
		
	static func from_dict(dict):
		return Category.new(dict["Name"],Color8(dict["Red"],dict["Green"],dict["Blue"]))
func _ready():
	db = SQLite.new()
	db.path = db_name
	db.foreign_keys = true
	db.open_db()

func switch_db(name):
	db.close_db()
	db.path = name
	db.open_db()

func add_entity(name:String,category:String):
	#returns true on success
	#assumes that no Entity already exists
	var tableName = "Entities"
	var query = "SELECT ID FROM "+tableName +" ORDER BY ID DESC LIMIT 1"
	db.query(query)
	var ID = db.query_result[0]["ID"]+1
	
	var dict : Dictionary = Dictionary()
	dict["Category"] = category
	dict["ID"] = ID
	
	db.insert_row(tableName,dict)
	if(check_if_error()):
		return false
	
	var dict2 : Dictionary = Dictionary()
	tableName = "Names"
	dict2["EntityID"] = ID
	dict2["Name"] = name
	dict2["PrimaryName"] = 1
	db.insert_row(tableName,dict2)
	
	if(check_if_error()):
		db.delete_rows("Entities","ID ="+String(ID))
		return false
	return true
	

func add_relationship(from:int,to:int,desc:String):
	#assumes that Entities already exist
	var tableName = "Relationships"
	var dict: Dictionary = Dictionary()
	dict["Start"] = from
	dict["End"] = to
	dict["Description"] = desc
	
	db.insert_row(tableName,dict)
	if(check_if_error()):
		return false
	return true

func find_entity(name:String):
	#returns entity ID
	var query = 'select ID, Category from Entities JOIN Names WHERE Name ="'+name+'" AND Names.EntityID = Entities.ID;'
	
	db.query(query)
	var res:Array = db.query_result
	
	if res.size() > 0:
		
		return Entity.from_dict(res[0])
	else:
		return null


func find_similar_names(text:String):
	var tableName = "Names"
	
	var patterns: Array = []
	for i in range(text.length()):
		var new_name:String = text
		new_name[i] = "%"
		patterns.append(new_name)
	
	var query = 'SELECT * FROM ' + tableName + ' WHERE Name LIKE "%' +text + '%"'
	for pattern in patterns:
		query += 'OR Name LIKE "' +pattern + '"'
	query += ';'
	
	db.query(query)
	var res:Array = db.query_result
	var names = []
	for result in res:
		names.append(result["Name"])
	return names

func get_relationships(ID:int):
	#gets all relationships of a specific entity
	var tableName = "Relationships"
	var query = 'select * from ' + tableName + ' WHERE Start =' +String(ID) + ' OR End =' +String(ID)
	print(query)
	db.query(query)
	var res:Array = db.query_result
	var relationships = []
	for result in res:
		relationships.append(Relationship.from_dict(result))
	return relationships

func get_relationship(ID):
	#gets a single relationship by ID
	var query = 'SELECT * from Relationships Where ID = ' + String(ID)
	db.query(query)
	var res:Array = db.query_result
	if not res.empty():
		return Relationship.from_dict(res[0])
	else:
		return null

func get_relationship_from_to(from:int,to:int):
	var query = 'SELECT * from Relationships Where Start = ' + String(from) + ' AND End = ' +String(to)
	db.query(query)
	var res:Array = db.query_result
	if not res.empty():
		return Relationship.from_dict(res[0])
	else:
		return null

func add_psuedonym(entity: int, name: String):
	
	# assumes that entity exists
	var tableName = "Names"
	
	var dict : Dictionary = Dictionary()
	dict["EntityID"] = entity
	dict["Name"] = name
	dict["PrimaryName"] = 0
	db.insert_row(tableName,dict)
	if(check_if_error()):
		return false
	return true

func get_all_names(entity:int):
	var tableName = "Names"
	var query = 'select * from ' + tableName + ' WHERE EntityID ="' +String(entity) + '";'
	
	db.query(query)
	var res:Array = db.query_result
	var names: Array
	for result in res:
		names.append(Name.from_dict(result))
	print(names[0].entityID)
	return names
	
func get_primary_name(entity:int):
	var tableName = "Names"
	var query = 'select Name from ' + tableName + ' WHERE EntityID ="' +String(entity) + '" AND PrimaryName > 0;'
	db.query(query)
	var res:Array = db.query_result
	if not res.empty():
		return res[0]["Name"]
	else:
		return null

func change_psuedonym(name:Name,new_name:String):
	# returns true upon success
	var query = "UPDATE Names SET Name = '"+new_name+"' WHERE Name = '"+name.name+"';"
	return db.query(query)
	
func change_relationship_desc(rel:Relationship,new_desc:String):
	# returns true upon success
	var query = "UPDATE Relationships SET Description = '"+new_desc+"' WHERE ID = '"+String(rel.ID)+"';"
	return db.query(query)


func make_primary(name:Name):
	var query = "UPDATE Names SET PrimaryName = 0 WHERE EntityID = '"+String(name.entityID)+"';"
	db.query(query)
	query = "UPDATE Names SET PrimaryName = 1 WHERE Name = '"+name.name+"';"
	return db.query(query)

func delete_name(name:Name):
	var query = "DELETE FROM Names WHERE Name = '"+name.name+"'"
	db.query(query)

func delete_relationship(ID:int):
	var query = "DELETE FROM Relationships WHERE ID = "+String(ID)
	db.query(query)

func delete_entity(ID:int):
	var relationships = get_relationships(ID)
	for rel in relationships:
		delete_relationship(rel.ID) 
	
	var names = get_all_names(ID)
	for name in names:
		delete_name(name)

	var query = "DELETE FROM Entities WHERE ID = "+String(ID)
	db.query(query)
	return true

func get_all_categories():
	var query = "SELECT * FROM Categories"
	db.query(query)
	var res:Array = db.query_result
	var to_return :Array = []
	for result in res:
		to_return.append(Category.from_dict(result))
	return to_return

func change_entity_category(entity):
	#changes entity category to the one stored in the object
	#returns true upon success
	var query = "UPDATE Entities SET Category = '"+String(entity.category)+"' WHERE ID = '"+String(entity.ID)+"';"
	return db.query(query)

func check_if_error():
	var msg = db.error_message
	if (msg == "not an error"):
		return false
	else:
		return true

func get_all_entities():
	var query = "SELECT * FROM Entities"
	db.query(query)
	var res:Array = db.query_result
	return res

func get_all_relationships():
	var query = "SELECT * FROM Relationships"
	db.query(query)
	var res:Array = db.query_result
	return res

func get_entity(ID):
	var query = 'SELECT * from Entities Where ID = ' + String(ID)
	db.query(query)
	var res:Array = db.query_result
	if not res.empty():
		return Entity.from_dict(res[0])
	else:
		return null
		
func get_category_colour(category:String):
	var query = 'Select * from Categories Where Name = "'+category +'"'
	db.query(query)
	var res:Array = db.query_result
	if not res.empty():
		return Category.from_dict(res[0]).colour
	else:
		return null

func custom_query(query:String):
	db.query(query)
	return db.query_result


func rename_file(from:String,to:String):
	var dir :Directory= Directory.new()
	if dir.open("res://Database/") == OK:
		return dir.rename(from,to)
