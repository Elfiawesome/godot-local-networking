class_name Server extends Node

signal disconnect_player(player_id: String)
signal send_data_to_player(player_id: String, packet_name: String, packet_data: Dictionary)

var global_player_list: Dictionary[String, PlayerData] = {}

func _ready() -> void:
	pass

func run_server() -> void:
	pass

func send_data(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	send_data_to_player.emit(player_id, packet_name, packet_data)

func _on_data_received(sender_id: String, packet_name: String, packet_data: Dictionary) -> void:
	var packet: ServerBoundPacket = Registries.get_instance(Registries.SERVER_BOUND_PACKET, packet_name)
	if !packet: return
	packet.run(self, sender_id, packet_data)

class PlayerData:
	var username
	var id
	
	func _init(player_id: String) -> void:
		id = player_id
