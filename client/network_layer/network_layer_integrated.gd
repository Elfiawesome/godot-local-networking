class_name NetworkLayerIntegrated extends NetworkLayer
##Integrated network implementation for direct local server communication

var _server: Server

func connect_to_server(user_data: Dictionary) -> void:
	my_player_id = generate_player_id(user_data["username"])

func send_data(packet_name: String, packet_data: Dictionary) -> void:
	_server._on_data_received(my_player_id, packet_name, packet_data)

func generate_player_id(username: String) -> String:
	return username.sha256_text()

func attach_local_server(server_: Server) -> void:
	_server = server_
	_server.send_data_to_player.connect(_on_server_data_send)

func _on_server_data_send(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	if player_id == my_player_id:
		data_received.emit(packet_name, packet_data)
	else:
		# Send to other players
		pass
