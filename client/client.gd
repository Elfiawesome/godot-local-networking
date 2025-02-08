class_name Client extends Node2D
##Client class handling both client-side logic and local server instantiation

##Handles network communication (local in this case)
var network_layer: NetworkLayer

func _ready() -> void:
	# Choose a network layer
	_init_network_layer()
	
	# Connect to server via network_layer
	network_layer.connect_to_server({"username":"Elfiawesome"})

##Setup integrated network layer for direct local communication
func _init_network_layer() -> void:
	# Since this is a singleplayer game, we will launch our own server instance and connect it directly without any network
	# In this case, we use the integrated network layer so that we can connect to the server instance directly
	network_layer = NetworkLayerIntegrated.new()
	network_layer.data_received.connect(_on_data_received)
	add_child(network_layer)
	
	# Create and add a server instance directly to the client scene
	var server := Server.new()
	add_child(server)
	# Connect the integrated network layer to the local server
	if network_layer is NetworkLayerIntegrated:
		@warning_ignore("unsafe_method_access")
		network_layer.attach_local_server(server)
	
	# Set names for debugging purposes
	network_layer.name = "NetworkLayer"
	server.name = "ServerInstance"

func _on_data_received(packet_name: String, packet_data: Dictionary) -> void:
	var packet: ClientBoundPacket = Registries.get_instance(Registries.CLIENT_BOUND_PACKET, packet_name)
	if !packet: return
	packet.run(self, packet_data)
