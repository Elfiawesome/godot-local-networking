extends ClientBoundPacket

func run(client: Client, data: Dictionary) -> void:
	var scene: PackedScene = Registries.get_resource(Registries.LOCAL_WORLD, data["id"])
	if !scene: return
	var local_world: LocalWorld = scene.instantiate()
	client.add_child(local_world)
