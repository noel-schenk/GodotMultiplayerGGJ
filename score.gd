extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var localState = State.state["players"].duplicate(true)
	localState.erase("default")
	
	var player_scores = []
	for player in localState.keys():
		player_scores.append(str(localState[player]["score"]))

	$ScoreLabel.text = " vs ".join(player_scores)
