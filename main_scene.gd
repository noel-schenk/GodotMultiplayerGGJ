# extends Node2D

# @export var CharacterScene: PackedScene;

# var peer = ENetMultiplayerPeer.new()

# # Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	load_skins()


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass


# func _on_host_button_pressed() -> void:
# 	State.state["self"]["name"] = $NameField.text
# 	peer.create_server(135)
# 	multiplayer.multiplayer_peer = peer
# 	multiplayer.peer_connected.connect(_add_player)
# 	_add_player()


# func _on_join_button_pressed() -> void:
# 	State.state["self"]["name"] = $NameField.text
# 	peer.create_client("localhost", 135)
# 	multiplayer.multiplayer_peer = peer
# 	#multiplayer.connected_to_server.connect(func():
# 		#_add_player(multiplayer.get_unique_id())
# 	#)

# func _add_player(id = 1):
# 	var cScene = CharacterScene.instantiate()
# 	cScene.name = str(id)
# 	State.state["players"][str(id)] = State.state["players"]["default"].duplicate(true)
	
# 	add_child(cScene)
	
# 	print('added character with id: %s and name: %s' % [id, str(id)])
	


# func load_skins() -> void:
# 	var allPanelContainers = []
# 	Utils.for_each(DirAccess.get_files_at("res://Skins/"), func(file_name):
# 		if not file_name.ends_with(".png"):
# 			return
		
# 		var image = ResourceLoader.load("res://Skins/" + file_name)
# 		var borderSkinTextureRect = PanelContainer.new()
# 		var skinTextureRect = TextureRect.new()
		
# 		var defaultBorderStyle = StyleBoxFlat.new()
# 		defaultBorderStyle.border_color = Color(0, 0, 0)
# 		defaultBorderStyle.set_border_width_all(4)
		
# 		var borderStyle = StyleBoxFlat.new()
# 		borderStyle.border_color = Color(1, 0, 0)
# 		borderStyle.set_border_width_all(4)
		
# 		borderSkinTextureRect.add_theme_stylebox_override("panel", defaultBorderStyle)
# 		allPanelContainers.append(borderSkinTextureRect)
		
# 		skinTextureRect.custom_minimum_size = Vector2(100, 100)
# 		skinTextureRect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
# 		skinTextureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
# 		skinTextureRect.texture = image
# 		skinTextureRect.gui_input.connect(func(event):
# 			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
# 				State.state["self"]["texture"] = image.resource_path
# 				Utils.for_each(allPanelContainers, func(allPanelContainer):
# 					allPanelContainer.add_theme_stylebox_override("panel", defaultBorderStyle)
# 				)
# 				borderSkinTextureRect.add_theme_stylebox_override("panel", borderStyle)
# 		)
		
		
# 		borderSkinTextureRect.add_child(skinTextureRect)
# 		$Skins.add_child(borderSkinTextureRect)
# 		$Skins.queue_sort()
# 	)
	
	
extends Node2D

@export var CharacterScene: PackedScene;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_skins()


func _on_host_button_pressed() -> void:
	State.state["self"]["name"] = $NameField.text

	multiplayer.peer_connected.connect(_add_player)
	_add_player()


func _on_join_button_pressed() -> void:
	State.state["self"]["name"] = $NameField.text
	#multiplayer.connected_to_server.connect(func():
		#_add_player(multiplayer.get_unique_id())
	#)

func _add_player(id = 1):
	var cScene = CharacterScene.instantiate()
	cScene.name = str(id)
	State.state["players"][str(id)] = State.state["players"]["default"].duplicate(true)
	
	add_child(cScene)
	
	print('added character with id: %s and name: %s' % [id, str(id)])
	


func load_skins() -> void:
	var allPanelContainers = []
	Utils.for_each(DirAccess.get_files_at("res://Skins/"), func(file_name):
		if not file_name.ends_with(".png"):
			return
		
		var image = ResourceLoader.load("res://Skins/" + file_name)
		var borderSkinTextureRect = PanelContainer.new()
		var skinTextureRect = TextureRect.new()
		
		var defaultBorderStyle = StyleBoxFlat.new()
		defaultBorderStyle.border_color = Color(0, 0, 0)
		defaultBorderStyle.set_border_width_all(4)
		
		var borderStyle = StyleBoxFlat.new()
		borderStyle.border_color = Color(1, 0, 0)
		borderStyle.set_border_width_all(4)
		
		borderSkinTextureRect.add_theme_stylebox_override("panel", defaultBorderStyle)
		allPanelContainers.append(borderSkinTextureRect)
		
		skinTextureRect.custom_minimum_size = Vector2(100, 100)
		skinTextureRect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		skinTextureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		skinTextureRect.texture = image
		skinTextureRect.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				State.state["self"]["texture"] = image.resource_path
				Utils.for_each(allPanelContainers, func(allPanelContainer):
					allPanelContainer.add_theme_stylebox_override("panel", defaultBorderStyle)
				)
				borderSkinTextureRect.add_theme_stylebox_override("panel", borderStyle)
		)
		
		
		borderSkinTextureRect.add_child(skinTextureRect)
		$Skins.add_child(borderSkinTextureRect)
		$Skins.queue_sort()
	)
	
	
