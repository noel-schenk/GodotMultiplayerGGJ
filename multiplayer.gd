extends Node

# Peer connections
var peer1 = WebRTCPeerConnection.new()
var peer2 = WebRTCPeerConnection.new()

func _ready():
	# Set up session description and ICE candidate signals for Peer 1
	peer1.session_description_created.connect(_on_peer1_offer_created)
	peer1.ice_candidate_created.connect(_on_peer1_ice_candidate_created)

	# Set up session description and ICE candidate signals for Peer 2
	peer2.session_description_created.connect(_on_peer2_answer_created)
	peer2.ice_candidate_created.connect(_on_peer2_ice_candidate_created)

	# Begin the connection process by creating an offer on Peer 1
	var peer1offerStatus = peer1.create_offer()
	print("peer1 create_offer: ", peer1offerStatus == OK)

# ---- Peer 1 Offer and ICE Candidate Handling ----

func _on_peer1_offer_created(type: String, sdp: String) -> void:
	print("_on_peer1_offer_created - type:", type)
	if type == "offer":
		print("Peer 1 Offer SDP:", sdp)
		# Send the offer SDP to Peer 2 (in a real app, send through a signaling server)
		peer2.set_remote_description("offer", sdp)
		peer2.create_answer()

func _on_peer1_ice_candidate_created(mid_name: String, index: int, sdp: String) -> void:
	print("Peer 1 ICE Candidate:", sdp)
	# Send this ICE candidate to Peer 2 (signaling server in a real app)
	peer2.add_ice_candidate(mid_name, index, sdp)

# ---- Peer 2 Answer and ICE Candidate Handling ----

func _on_peer2_answer_created(type: String, sdp: String) -> void:
	if type == "answer":
		print("Peer 2 Answer SDP:", sdp)
		# Send the answer SDP back to Peer 1
		peer1.set_remote_description("answer", sdp)

func _on_peer2_ice_candidate_created(mid_name: String, index: int, sdp: String) -> void:
	print("Peer 2 ICE Candidate:", sdp)
	# Send this ICE candidate back to Peer 1
	peer1.add_ice_candidate(mid_name, index, sdp)
