class_name WorldManager extends Node

var _loaded_worlds: Dictionary[String, World] = {}

func get_world(world_id: String) -> World:
	if world_id in _loaded_worlds:
		return _loaded_worlds[world_id]
	else:
		_load_world(world_id)
		return _loaded_worlds[world_id]

func _load_world(world_id: String) -> void:
	var world := World.new(world_id)
	_loaded_worlds[world_id] = world

class World:
	var id: String
	var _entities: Dictionary[String, Entity] = {}
	
	func _init(world_id: String) -> void:
		id = world_id
	
	func add_entity() -> Entity:
		var entity := Entity.new(generate_entity_id())
		_entities[entity.id] = entity
		return entity
	
	func get_entity(entity_id: String) -> Entity:
		return _entities.get(entity_id, null)
	
	func remove_entity(entity_id: String) -> void:
		if entity_id in _entities:
			_entities.erase(entity_id)
	
	var _entity_id_counter: int = 0
	func generate_entity_id() -> String:
		_entity_id_counter += 1
		return (str(_entity_id_counter)+"-"+str(Time.get_ticks_usec())).sha256_text()
	
	func to_data_entity_pov(pov_entity_id: String) -> Dictionary:
		var d := {
			"id":id,
			"entities":{}
		}
		for entity_id in _entities:
			var entity := _entities[entity_id]
			d["entities"][entity_id] = entity.serialize()
		return d

class Entity:
	var id: String
	var transform: Transform2D = Transform2D(0.0, Vector2.ONE, 0.0, Vector2.ZERO)
	
	func _init(entity_id: String) -> void:
		id = entity_id
	
	func serialize() -> Dictionary:
		var d := {
			"id": id,
			"transform": transform,
		}
		return d
