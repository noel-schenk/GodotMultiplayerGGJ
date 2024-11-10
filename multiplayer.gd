#extends Node
#
#var peer1 := WebRTCPeerConnection.new()
#var ch1
#var signalingData = {}
#var selectedLobbyName
#var is_server = false
#var connection_est_has_run_once = false
#
#@export var mutliplayer_server_node: PackedScene
#@export var lobbyUrl:= "https://godot-multiplayer-ggj.vercel.app"
#@export var projectName:= "ggj25"
#
#func _ready():
	#await get_tree().create_timer(0.4).timeout
	#initialize_peer1()
	#$HTTPRequest_create_lobby.request_completed.connect(_on_create_lobby_completed)
	#$HTTPRequest_get_lobbies.request_completed.connect(_on_request_server_browser_completed)
	#$HTTPRequest_add_client.request_completed.connect(_on_join_lobby_completed)
	#$HTTPRequest_get_lobby.request_completed.connect(_on_request_lobby_completed)
	#$HTTPRequest_get_lobby_to_join.request_completed.connect(_on_request_lobby_to_join_completed)
	#request_server_browser()
#
#func _process(_delta):
	#$HBoxContainer.visible = true
	#$Loading.visible = false
	##if ch1:
		##if ch1.get_ready_state() == ch1.STATE_OPEN and ch1.get_available_packet_count() > 0:
			##print("?? received: ", ch1.get_packet().get_string_from_utf8())
		#
	#if signalingData.size() > 1:
		#if connection_est_has_run_once:
			#return
		#
		#connection_est_has_run_once = true
		#
		#if is_server:
			##create lobby
			#POST({
				#"offer": signalingData.offer,
				#"ice": signalingData.ice,
				#"is_public": 1 if $HBoxContainer/MarginContainer/create_lobby_step_1/VBoxContainer2/VBoxContainer/create_lobby_is_public_button.is_pressed() else 0,
				#"project": projectName,
				#"name": $HBoxContainer/MarginContainer/create_lobby_step_1/VBoxContainer2/VBoxContainer/create_lobby_name_input.text
			#}, "create-lobby", $HTTPRequest_create_lobby)
		#else:
			#POST({
				#"offer": signalingData.offer,
				#"ice": signalingData.ice,
				#"project": projectName,
				#"name": $HBoxContainer/MarginContainer2/MarginContainer/VBoxContainer2/VBoxContainer/join_lobby_name_input.text
				#}, "add-client", $HTTPRequest_add_client)
		#
		##ch1.put_packet("Hi from ??".to_utf8_buffer())
		#pass
#
#func initialize_peer1():
	#peer1.initialize({"iceServers" = [{"urls": "stun:stun.l.google.com:19302"}]})
	#ch1 = peer1.create_data_channel("chat", { "id": 1, "negotiated": true })
	#
	#peer1.session_description_created.connect(_on_peer1_offer_created)
	#peer1.ice_candidate_created.connect(_on_peer1_ice_candidate_created)
	#
	#
#func _on_peer1_offer_created(type: String, sdp: String) -> void:
	#peer1.set_local_description(type, sdp)
	#print("_on_peer1_offer_created - type:", type)
	#if type == "offer":
		#signalingData["offer"] = {"type": type, "sdp": sdp}
		#print("Peer 1 Offer SDP:", sdp)
#
#func _on_peer1_ice_candidate_created(media: String, index: int, name: String) -> void:
	#print("Peer 1 ICE Candidate name: ", name)
	#signalingData["ice"] = {"media": media, "index": index, "name": name}
#
#func POST(data, path: String, http_request: HTTPRequest):
	#var json_data = JSON.stringify(data)
	#http_request.request("%s/%s" % [lobbyUrl, path], ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)
	#print("%s/%s" % [lobbyUrl, path])
	#print(json_data)
#
#func _on_joing_lobby_reload_server_browser_pressed() -> void:
	#request_server_browser()
#
#func request_server_browser():
	#for n in $HBoxContainer/MarginContainer2/MarginContainer/VBoxContainer2/PanelContainer2/MarginContainer/ScrollContainer/join_lobby_browser.get_children():
		#n.free()
		#
	#$HTTPRequest_get_lobbies.request("%s/get-lobbies?project=%s" % [lobbyUrl, projectName.uri_encode()])
#
#func _on_request_server_browser_completed(result, response_code, headers, body):
	#if response_code == 200 || response_code == 201:
		#var data = JSON.parse_string(body.get_string_from_utf8())
		#print(data)
		#if data && typeof(data) == TYPE_ARRAY && data[0]:
			#for lobby in data:
				#var mpScene = mutliplayer_server_node.instantiate()
				#mpScene.text = lobby["name"]
				#$HBoxContainer/MarginContainer2/MarginContainer/VBoxContainer2/PanelContainer2/MarginContainer/ScrollContainer/join_lobby_browser.add_child(mpScene)
				#print("Lobby:", lobby)
				#print("---")
		#else:
			#print("Failed to parse JSON:", data)
	#else:
		#print("Request failed with code:", response_code)
#
#func _on_create_lobby_create_button_pressed() -> void:
	#is_server = true
	#peer1.create_offer()
	#peer1.poll()
#
#func _on_create_lobby_completed(result, response_code, headers, body):
	#if response_code == 200 || response_code == 201:
		#var data = JSON.parse_string(body.get_string_from_utf8())
		#print(typeof(data))
		#if data && typeof(data) == TYPE_DICTIONARY:
			#print("Lobby:", data)
			#request_server_browser()
			#lobby_created(data.name)
		#else:
			#print("Failed to parse JSON2:", data)
	#else:
		#print("Request failed with code:", response_code)
#
#func lobby_created(lobbyName):
	#selectedLobbyName = lobbyName
	#$HBoxContainer/MarginContainer/create_lobby_step_2/VBoxContainer2/VBoxContainer/create_lobby_lobby_name_label.text = "Lobby name: %s" % lobbyName
	#$HBoxContainer/MarginContainer/create_lobby_step_1.visible = false
	#$HBoxContainer/MarginContainer/create_lobby_step_2.visible = true
#
#func _on_request_lobby_to_join_completed():
	#pass
#
#func _on_join_lobby_join_button_pressed() -> void:
	#is_server = false
	#peer1.poll()
	#$HTTPRequest_get_lobby_to_join.request("%s/get-lobbies?project=%s&name=%s" % [lobbyUrl, projectName.uri_encode(), selectedLobbyName.uri_encode()])
#
#func _on_join_lobby_completed(result, response_code, headers, body):
	#if response_code == 200 || response_code == 201:
		#var data = JSON.parse_string(body.get_string_from_utf8())
		#print(typeof(data))
		#if data && typeof(data) == TYPE_DICTIONARY:
			#print("join lobby data:", data.offer, data.ice)
			#peer1.set_remote_description(data.offer.type, data.offer.sdp)
			#peer1.add_ice_candidate(data.ice.media, data.ice.index, data.ice.name)
			#request_server_browser()
		#else:
			#print("Failed to parse JSON3:", data)
	#else:
		#print("Request failed with code:", response_code)
#
#func _on_create_lobby_start_game_button_pressed() -> void:
	#$HTTPRequest_get_lobby.request("%s/get-lobbies?project=%s&name=%s" % [lobbyUrl, projectName.uri_encode(), selectedLobbyName.uri_encode()])
	#print("%s/get-lobbies?project=%s&name=%s" % [lobbyUrl, projectName, selectedLobbyName])
#
#func _on_request_lobby_completed(result, response_code, headers, body):
	#if response_code == 200 || response_code == 201:
		#var data = JSON.parse_string(body.get_string_from_utf8())
		#print("testdata before parase", body.get_string_from_utf8())
		#print(data)
		#if data && typeof(data) == TYPE_DICTIONARY:
			#for client in data.clients:
				#peer1.set_remote_description(client.offer.type, client.offer.sdp)
				#peer1.add_ice_candidate(client.ice.media, client.ice.index, client.ice.name)	
				#await get_tree().create_timer(1).timeout
				#Utils.better_print(["set_remote_description %s" % data.clients[0].offer.sdp])
				#Utils.better_print(["add_ice_candidate",client.ice.media, client.ice.index, client.ice.name])
				##
				##await get_tree().create_timer(10).timeout
				##
				##ch1.put_packet("Hi from Server".to_utf8_buffer())
		#
			#print("_on_request_lobby_completed:", data)
		#else:
			#print("Failed to parse JSON 4:", data)
	#else:
		#print("Request failed with code:", response_code, result, body.get_string_from_utf8())	
	#pass
#
#func test():
	#pass

######################################
######################################
######################################
######################################
######################################
######################################
#
#extends Node
## Main scene.
#
#var mutliplayerPeer = WebRTCMultiplayerPeer.new()
#
## Create the two peers.
#var p1 := WebRTCPeerConnection.new()
#var p2 := WebRTCPeerConnection.new()
#
#var ch1
#var ch2
#
#var ice1 = 0
#var ice2 = 0
#
#var ice_and_desc_set = false
#
#func _ready() -> void:
	#p1.initialize({"iceServers" = [{"urls": "stun:stun.l.google.com:19302"}]})
	#p2.initialize({"iceServers" = [{"urls": "stun:stun.l.google.com:19302"}]})
#
	#ch1 = p1.create_data_channel("chat", { "id": 1, "negotiated": true })
	#ch2 = p2.create_data_channel("chat", { "id": 1, "negotiated": true })
	#
	#p2.session_description_created.connect(func(type: String, sdp: String): 
		#print("session_description_created 2")
		#p1.set_remote_description(type, sdp))
		#
	#p2.ice_candidate_created.connect(func(media: String, index: int, name: String): 
		#if ice2 < 1:
			#ice2 = ice2 + 1
			#print("ice_candidate_created 2")
			#p1.add_ice_candidate(media, index, name))
	#
	#
	#p1.session_description_created.connect(func(type: String, sdp: String): 
		##await get_tree().create_timer(0.4).timeout
		#print("session_description_created")
		#p2.set_remote_description(type, sdp)
		#if (ice_and_desc_set):
			#p2.poll()
		#else:
			#ice_and_desc_set = true
		##p3.set_remote_description(type, sdp)
		#)
		#
		#
	#p1.ice_candidate_created.connect(func(media: String, index: int, name: String): 
		#await get_tree().create_timer(0.4).timeout
		#if ice1 < 1:
			#ice1 = ice1 + 1
			#print("ice_candidate_created")
			#p2.add_ice_candidate(media, index, name)
			#if (ice_and_desc_set):
				#p2.poll()
			#else:
				#ice_and_desc_set = true
			##p3.add_ice_candidate(media, index, name)
			#)
#
	#print("poll before")
#
#
	## Let P1 create the offer.
	#p1.create_offer()
	#
	#print("poll after")
	#p1.poll()
	#p2.poll()
#
	##await Utils.sleep(2)
#
	#if ch1:
		## Wait a second and send message from P1.
		#await get_tree().create_timer(1).timeout
		#ch1.put_packet("Hi from P1".to_utf8_buffer())
#
	#if ch2:
		## Wait a second and send message from P2.
		#await get_tree().create_timer(1).timeout
		#ch2.put_packet("Hi from P2".to_utf8_buffer())
#
#
#
#func _process(delta: float) -> void:
	##await get_tree().create_timer(10).timeout
	#if not p1 || not p2 : return
	##p1.poll()
	##p2.poll()
	##p3.poll()
	#if not ch1 || not ch2 : return
	#if ch1.get_ready_state() == ch1.STATE_OPEN and ch1.get_available_packet_count() > 0:
		#print("P1 received: ", ch1.get_packet().get_string_from_utf8())
	#if ch2.get_ready_state() == ch2.STATE_OPEN and ch2.get_available_packet_count() > 0:
		#print("P2 received: ", ch2.get_packet().get_string_from_utf8())


######################################
######################################
######################################
######################################
######################################
######################################


extends Node

@export var mutliplayer_server_node: PackedScene
@export var lobbyUrl:= "https://godot-multiplayer-ggj.vercel.app"
@export var projectName:= "ggj25"

@onready var mainBox:= $HBoxContainer
@onready var loading:= $Loading
@onready var join_lobby_browser:= $HBoxContainer/MarginContainer2/MarginContainer/VBoxContainer2/PanelContainer2/MarginContainer/ScrollContainer/join_lobby_browser
@onready var reload_server_browser_button:= $"HBoxContainer/MarginContainer2/MarginContainer/VBoxContainer2/VBoxContainer2/margin ding/joing_lobby_reload_server_browser"
@onready var chat:=$HBoxContainer/MarginContainer3/MarginContainer/VBoxContainer2/Chat

@onready var create_lobby_name_input:= $HBoxContainer/MarginContainer/create_lobby_step_1/VBoxContainer2/VBoxContainer/create_lobby_name_input
@onready var create_lobby_is_public_button:= $HBoxContainer/MarginContainer/create_lobby_step_1/VBoxContainer2/VBoxContainer/create_lobby_is_public_button
@onready var create_lobby_create_button:= $HBoxContainer/MarginContainer/create_lobby_step_1/VBoxContainer2/VBoxContainer/create_lobby_create_button

@onready var create_lobby_step_1:= $HBoxContainer/MarginContainer/create_lobby_step_1
@onready var create_lobby_step_2:= $HBoxContainer/MarginContainer/create_lobby_step_2

@onready var create_lobby_name_label:= $HBoxContainer/MarginContainer/create_lobby_step_2/VBoxContainer2/VBoxContainer/create_lobby_lobby_name_label
@onready var create_lobby_start_game_button:= $HBoxContainer/MarginContainer/create_lobby_step_2/VBoxContainer2/VBoxContainer/create_lobby_start_game_button

var lobby_uuid = 0

# Import WebRTC objects
var peer := WebRTCPeerConnection.new()
var channel: WebRTCDataChannel 
var signaling_data = {
	"session_description": {},
	"ice_candidates": []
}

# HTTPRequest nodes for different API calls (to be added to the scene as per requirement)
@onready var http_request_create_offer = $HTTPRequest_create_offer
@onready var http_request_get_public_offers = $HTTPRequest_get_public_offers
@onready var http_request_get_offer_details = $HTTPRequest_get_offer_details
@onready var http_request_create_offer_request = $HTTPRequest_create_offer_request
@onready var http_request_get_oldest_offer_request = $HTTPRequest_get_oldest_offer_request
@onready var http_request_set_server_exchange = $HTTPRequest_set_server_exchange
@onready var http_request_set_client_exchange = $HTTPRequest_set_client_exchange

func _ready():
	# Connect HTTPRequest signals for callbacks
	http_request_create_offer.request_completed.connect(_on_create_offer_completed)
	http_request_get_public_offers.request_completed.connect(_on_get_public_offers_completed)
	http_request_get_offer_details.request_completed.connect(_on_get_offer_details_completed)
	http_request_create_offer_request.request_completed.connect(_on_create_offer_request_completed)
	http_request_get_oldest_offer_request.request_completed.connect(_on_get_oldest_offer_request_completed)
	http_request_set_server_exchange.request_completed.connect(_on_set_server_exchange_completed)
	http_request_set_client_exchange.request_completed.connect(_on_set_client_exchange_completed)

	create_lobby_create_button.pressed.connect(_on_pressed_create_lobby_create_button)
	reload_server_browser_button.pressed.connect(_on_pressed_reload_server_browser_button)

	webRTC_init()

	set_lobby_browser()

func _process(delta: float) -> void:
	if not channel : return
	if channel.get_ready_state() == channel.STATE_OPEN and channel.get_available_packet_count() > 0:
		var message = channel.get_packet().get_string_from_utf8()
		print("Received: ", message)
		chat.text = chat.text + "\n%s" % message

func webRTC_init():
	peer.initialize({"iceServers" = [{"urls": "stun:stun.l.google.com:19302"}]})
	channel = peer.create_data_channel("chat", { "id": 1, "negotiated": true })

	peer.session_description_created.connect(func(type: String, sdp: String): 
		signaling_data.session_description = {
			"type": type,
			"sdp": sdp
		}
	)

	peer.ice_candidate_created.connect(func(media: String, index: int, name: String): 
		signaling_data.ice_candidates.append({
			"media": media,
			"index": index,
			"name": name
		})
	)

# UI Events

func _on_pressed_create_lobby_create_button():
	create_lobby({
		"name": create_lobby_name_input.text,
		"is_public": create_lobby_is_public_button.is_pressed()
	})

func _on_pressed_reload_server_browser_button():
	set_lobby_browser()

# Endpoint Functions

# POST /offers - Create a new offer
func create_offer(name: String, is_public: bool):
	var data = {"name": name, "isPublic": is_public}
	http_request_create_offer.request("%s/offers" % lobbyUrl, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(data))

# GET /offers - Get all public offers
func get_public_offers():
	print("get_public_offers", "%s/offers" % lobbyUrl)
	http_request_get_public_offers.request("%s/offers" % lobbyUrl)

# GET /offers/:uuid - Get details of a specific offer by UUID
func get_offer_details(offer_uuid: String):
	http_request_get_offer_details.request("%s/offers/%s" % [lobbyUrl, offer_uuid])

# POST /offers/:uuid/requests - Create a new OfferRequest for an offer
func create_offer_request(offer_uuid: String):
	http_request_create_offer_request.request("%s/offers/%s/requests" % [lobbyUrl, offer_uuid], [], HTTPClient.METHOD_POST)

# GET /offers/:uuid/requests - Get the oldest unresolved OfferRequest for an offer
func get_oldest_offer_request(offer_uuid: String):
	http_request_get_oldest_offer_request.request("%s/offers/%s/requests" % [lobbyUrl, offer_uuid])

# PUT /offers/:offerUuid/requests/:requestUuid/exchange/server - Set Server Exchange Data
func set_server_exchange(offer_uuid: String, request_uuid: String, ice_candidates: Array, session_description: Dictionary):
	var data = {"exchange": {"iceCandidates": ice_candidates, "sessionDescription": session_description}}
	http_request_set_server_exchange.request("%s/offers/requests/%s/exchange/server" % [lobbyUrl, request_uuid], ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify(data))

# PUT /offers/:offerUuid/requests/:requestUuid/exchange/client - Set Client Exchange Data
func set_client_exchange(offer_uuid: String, request_uuid: String, ice_candidates: Array, session_description: Dictionary):
	var data = {"exchange": {"iceCandidates": ice_candidates, "sessionDescription": session_description}}
	http_request_set_client_exchange.request("%s/offers/requests/%s/exchange/client" % [lobbyUrl, request_uuid], ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify(data))

func _on_create_offer_completed(result, response_code, headers, body):
	if response_code == 200 or response_code == 201:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.uuid:
			create_lobby({}, {"uuid": response.uuid}, true)
			print("Offer created:", response.uuid)

func _on_get_public_offers_completed(result, response_code, headers, body):
	if response_code == 200:
		print("_on_get_public_offers_completed", body.get_string_from_utf8())
		var response = JSON.parse_string(body.get_string_from_utf8())
		if typeof(response) == TYPE_ARRAY:
			set_lobby_browser(response, true)
			print("Public offers:", response)

func _on_get_offer_details_completed(result, response_code, headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.uuid:
			print("Offer details:", response.data)

func _on_create_offer_request_completed(result, response_code, headers, body):
	if response_code == 200 or response_code == 201:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.sessionDescription:
			print("OfferRequest created:", response)
			create_lobby_offer_request({}, {
				"ice_candidates": response.iceCandidates,
				"session_description": response.sessionDescription,
				"uuid": response.uuid
			}, true)

func _on_get_oldest_offer_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var bodyString = body.get_string_from_utf8()
		if not bodyString: return
		var response = JSON.parse_string(bodyString)
		if response.uuid:
			check_for_offer_request({}, {"uuid": response.uuid}, true)
			print("Oldest unresolved OfferRequest:", response.uuid)

func _on_set_server_exchange_completed(result, response_code, headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.sessionDescription:
			set_server_signaling_data({
				"ice_candidates": response.iceCandidates,
				"session_description": response.sessionDescription
				}, {}, true)
			print("Server exchange set:", response)

func _on_set_client_exchange_completed(result, response_code, headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.success:
			await Utils.sleep(4)
			peer.poll()
			channel.put_packet("Hi from client".to_utf8_buffer())
			print("Client exchange set:", response)

func _on_cleanup_completed(result, response_code, headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.result == OK:
			print("Cleanup results:", response.data)
#
### MULTIPLAYER LOGIC ###

# offer request -> pending -> returns server offer -> set remote
func create_lobby_offer_request(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return create_offer_request(requestData.uuid)
	print("create_lobby_offer_request", responseData.ice_candidates, responseData.session_description)
	webRTC_set_remote(responseData)


func set_lobby_browser(responseData: Array = [], is_callback: bool = false):
	print("set_lobby_browser1")
	if not is_callback: return get_public_offers()
	for n in join_lobby_browser.get_children():
		n.free()

	for lobby in responseData:
		var mpScene = mutliplayer_server_node.instantiate()
		mpScene.text = lobby["name"]
		mpScene.uuid = lobby["uuid"]
		mpScene.ready.connect(func(): 
			mpScene._on_pressed.connect(func():
				lobby_uuid = lobby["uuid"]
				create_lobby_offer_request({
					"uuid": lobby["uuid"]
				})
			)	
		)
		
		join_lobby_browser.add_child(mpScene)
	
	print("set_lobby_browser2", responseData)
	mainBox.visible = true
	loading.visible = false
	
func check_for_offer_request(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return get_oldest_offer_request(requestData.uuid)
	print("check_for_offer_requests", responseData.uuid)
	webRTC_generate_offer({
		"uuid": responseData.uuid
	})

func set_server_signaling_data(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return set_server_exchange(lobby_uuid, requestData.uuid, signaling_data.ice_candidates, signaling_data.session_description)
	
	peer.set_remote_description(requestData.session_description.type, requestData.session_description.sdp)
	for ice_candidate in requestData.ice_candidates:
		peer.add_ice_candidate(ice_candidate.media, ice_candidate.index, ice_candidate.name)
	
	await Utils.sleep(2)
	peer.poll()
	channel.put_packet("Hi from server".to_utf8_buffer())
	

func webRTC_generate_offer(requestData: Dictionary = {}):
	peer.create_offer()
	peer.poll()
	
	await Utils.sleep(0.1) #Give ice time to generate routes
	set_server_signaling_data({
		"uuid": requestData.uuid
	})

func webRTC_set_remote(requestData: Dictionary = {}):
	peer.set_remote_description(requestData.session_description.type, requestData.session_description.sdp)
	for ice_candidates in requestData.ice_candidates:
		peer.add_ice_candidate(ice_candidates.media, ice_candidates.index, ice_candidates.name)
	
	peer.poll()
	await Utils.sleep(0.1) #Give ice time to generate routes
	set_client_exchange(lobby_uuid, requestData.uuid, signaling_data.ice_candidates, signaling_data.session_description)

func create_lobby(requestData: Dictionary = {}, responseData: Dictionary = {}, is_callback: bool = false):
	if not is_callback: return create_offer(requestData.name, requestData.is_public)
	print("create_lobby", "created lobby", responseData.uuid)
	
	create_lobby_name_label.text = "Lobby ID: %s" % responseData.uuid
	
	create_lobby_step_1.visible = false
	create_lobby_step_2.visible = true
	
	lobby_uuid = responseData.uuid
	
	Utils.set_interval(func(): check_for_offer_request({"uuid": responseData.uuid}), 4)
