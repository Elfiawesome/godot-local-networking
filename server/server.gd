class_name Server extends Node

signal disconnect_player(player_id: String)
signal send_data_to_player(player_id: String, packet_name: String, packet_data: Dictionary)

var world_manager: WorldManager

var global_player_list: Dictionary[String, PlayerData] = {}

func _ready() -> void:
	# Initialize
	world_manager = WorldManager.new()
	world_manager.name = "WorldManager"
	add_child(world_manager)
	
	# Setup server
	run_server()

func run_server() -> void:
	var world := world_manager.get_world("crystal_bay")
	# Create a bunch of random entities
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))
	world.add_entity().transform.origin = Vector2(randi_range(10,500), randi_range(10,500))

func connection_request(player_id: String, _request_data: Dictionary) -> void:
	if player_id in global_player_list:
		printerr("Duplicate ids connection request")
		return
	
	global_player_list[player_id] = PlayerData.new(player_id)
	player_join_world(player_id, "crystal_bay")

func get_player(player_id: String) -> PlayerData:
	return global_player_list.get(player_id, null)

func player_join_world(player_id: String, world_id: String) -> void:
	var player := get_player(player_id)
	if !player: return
	if player._current_world_id && player._entity_id:
		var world := world_manager.get_world(player._current_world_id)
		var player_avatar := world.get_entity(player._entity_id)
		if !player_avatar: return
		world.remove_entity(player_avatar.id)
	
	var world := world_manager.get_world(world_id)
	var player_avatar := world.add_entity()
	
	
	send_data(player_id, "world_state/world_load_package", world.to_data_entity_pov(player_avatar.id))



##Send data to a player
func send_data(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	send_data_to_player.emit(player_id, packet_name, packet_data)

##Received data from player
func _on_data_received(sender_id: String, packet_name: String, packet_data: Dictionary) -> void:
	var packet: ServerBoundPacket = Registries.get_instance(Registries.SERVER_BOUND_PACKET, packet_name)
	if !packet: return
	packet.run(self, sender_id, packet_data)

class PlayerData:
	var username: String
	var id: String
	
	var _current_world_id: String
	var _entity_id: String
	
	func _init(player_id: String) -> void:
		id = player_id
