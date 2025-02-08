extends Node

class CategoryRegistry:
	var resources: Dictionary[String, Resource] = {}
	var instances: Dictionary[String, Object] = {}

# Default registry categories
const CLIENT_BOUND_PACKET := "client_bound_packet"
const SERVER_BOUND_PACKET := "server_bound_packet"
const LOCAL_WORLD := "local_world"
const LOCAL_ENTITY := "local_entity"


# Main registry storage
var registries: Dictionary[String, CategoryRegistry] = {}

func _ready() -> void:
	_auto_load_registries_debug()

func register_resource(category: String, key: String, resource: Resource) -> void:
	_ensure_category_exists(category)
	registries[category].resources[key] = resource

func register_script_instance(category: String, key: String, resource: GDScript) -> void:
	_ensure_category_exists(category)
	registries[category].instances[key] = resource.new()

func register_instance(category: String, key: String, instance: Object) -> void:
	_ensure_category_exists(category)
	registries[category].instances[key] = instance

func get_resource(category: String, key: String) -> Resource:
	if not registries.has(category):
		push_error("Category not found: ", category)
		return null
		
	return registries[category].resources.get(key, null)

func get_instance(category: String, key: String) -> Object:
	if not registries.has(category):
		push_error("Category not found: ", category)
		return null
		
	return registries[category].instances.get(key, null)

func _ensure_category_exists(category: String) -> void:
	if not registries.has(category):
		registries[category] = CategoryRegistry.new()

func _auto_load_registries_debug() -> void:
	# TODO: This must not be here
	var client_packet_path := "res://client/packet/"
	for filepath in _get_all_files_from_directory(client_packet_path):
		var gdscript: GDScript = load(filepath)
		var packet: ClientBoundPacket = gdscript.new()
		var filename := filepath.split(client_packet_path)[-1].split(".")[0]
		register_instance(CLIENT_BOUND_PACKET, filename, packet)
	var local_world_path := "res://client/world/"
	for filepath in _get_all_files_from_directory(local_world_path, "tscn"):
		var scene: PackedScene = load(filepath)
		var filename := filepath.split(local_world_path)[-1].split(".")[0]
		register_resource(LOCAL_WORLD, filename, scene)
	
	var server_packet_path := "res://server/packet/"
	for filepath in _get_all_files_from_directory(server_packet_path):
		var gdscript: GDScript = load(filepath)
		var packet: ServerBoundPacket = gdscript.new()
		var filename := filepath.split(server_packet_path)[-1].split(".")[0]
		register_instance(SERVER_BOUND_PACKET, filename, packet)


func _get_all_files_from_directory(path : String, file_ext:= "gd", files: Array[String] = []) -> Array[String]:
	var resources := ResourceLoader.list_directory(path)
	for res in resources:
		if res.ends_with("/"): 
			var _a := _get_all_files_from_directory(path+res, file_ext, files)
		elif file_ext && res.ends_with(file_ext): 
			files.append(path+res)
	return files
