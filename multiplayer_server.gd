extends Container

@export var text := ""
@export var uuid := ""
@export var _on_pressed : Signal

@onready var multiplayer_server_text:= $HBoxContainer/multiplayer_server_text
@onready var join_button:= $join_button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_server_text.text = text
	_on_pressed = join_button.pressed



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
