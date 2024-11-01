extends Node2D


var defaultPos
var defaultPosKnifeCollidor

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	$RigidBody2D.set_meta('multiplayer_id', name.to_int())

	$RigidBody2D.contact_monitor = true
	$RigidBody2D.max_contacts_reported = 10
	
	defaultPos = $RigidBody2D/knife_sprite.position
	defaultPosKnifeCollidor = $RigidBody2D/Area2D/knife.position
	
	if is_multiplayer_authority():
		update_texture()
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	if Input.is_key_pressed(KEY_D):
		$RigidBody2D.apply_force(Vector2(50000 * delta, 0))
	if Input.is_key_pressed(KEY_W):
		$RigidBody2D.apply_force(Vector2(0, -50000 * delta))
	if Input.is_key_pressed(KEY_S):
		$RigidBody2D.apply_force(Vector2(0, 50000 * delta))
	if Input.is_key_pressed(KEY_A):
		$RigidBody2D.apply_force(Vector2(-50000 * delta, 0))
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$RigidBody2D/knife_sprite.position += Vector2(20,0)
		$RigidBody2D/Area2D/knife.position += Vector2(20,0)
		await get_tree().create_timer(0.4).timeout
		$RigidBody2D/knife_sprite.position = defaultPos
		$RigidBody2D/Area2D/knife.position = defaultPosKnifeCollidor


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return

	if body.has_meta("multiplayer_id"): print(body.get_meta("multiplayer_id"))
	print("Body has meta Name %s" % body.has_meta("Name"))
	if body.has_meta("Name") && body.get_meta("Name") == "Character":
		State.state["players"][str($RigidBody2D.get_meta("multiplayer_id"))]["score"] += 1
		update_score()
		body.get_node('Splatter').visible = true
		await get_tree().create_timer(1).timeout
		body.get_node('Splatter').visible = false

@rpc("any_peer")
func set_update_score(newLocalState):
	State.state["players"] = newLocalState

func update_score():
	rpc("set_update_score", State.state["players"])

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	$RigidBody2D.linear_velocity = Vector2(0,0)
	$RigidBody2D.apply_force(Vector2(randf_range(-10000, 10000), -50000))


@rpc("any_peer")
func update_character_texture(sender_id: int, texture_data: PackedByteArray):
	if name.to_int() == sender_id:
		var image = Image.new()
		image.load_png_from_buffer(texture_data)
		var texture = ImageTexture.create_from_image(image)
		$RigidBody2D/Character.texture = texture

func update_texture():
	var texture = load(State.state["self"]["texture"]) as Texture2D
	if texture:
		var image = texture.get_image()
		
		#Change local
		$RigidBody2D/Character.texture = texture
		
		var texture_data = image.save_png_to_buffer()
		rpc("update_character_texture", name.to_int(), texture_data)
