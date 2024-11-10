extends Node2D

var peer1 = WebRTCPeerConnection.new()
var ch1 = peer1.create_data_channel("chat", {"id": 1, "negotiated": true})

func _on_peer1_offer_created(type: String, sdp: String):
	print("_on_peer1_offer_created")



func _ready():	
	peer1.session_description_created.connect(_on_peer1_offer_created)
	peer1.create_offer()
	peer1.poll()
