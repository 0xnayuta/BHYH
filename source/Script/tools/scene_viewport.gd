extends Node

const MAX_NUM: int = 1
var viewport: Viewport
var tcp_server: TCPServer
var tcp_num: int = 0
var tc_plist: Array[StreamPeerTCP] = []
var send_time: float
var cur_img: Image
var global_img: Image


func _ready() -> void:
	viewport = get_viewport()
	tcp_server = TCPServer.new()
	if tcp_server.listen(8889, "127.0.0.1") != OK:
		if Global.has_method("add_message_show"):
			Global.add_message_show(self, "服务器创建失败！", 1.5, Vector2(470, 300))
	else:
		if Global.has_method("add_message_show"):
			Global.add_message_show(self, "服务器创建成功！", 1.5, Vector2(470, 300))


func loop_server() -> void:
	if tcp_num > 0:
		var _img: Image = viewport.get_texture().get_image()
		send_texture(_img)
	if tcp_num < MAX_NUM && tcp_server.is_listening():
		var tcp: StreamPeerTCP = tcp_server.take_connection()
		if tcp != null:
			tcp_num += 1
			tc_plist.append(tcp)


func get_client_com(i: StreamPeerTCP) -> void:
	if i.get_available_bytes() > 5:
		var com: int = i.get_data(1)[1][0]
		var data_len := i.get_data(4)[1] as PackedByteArray
		var data := i.get_data(data_len.decode_u32(0))[1] as PackedByteArray
		var client_com := data.get_string_from_utf8()
		if com == 1:
			Input.action_press(client_com)
		else:
			Input.action_release(client_com)


func send_texture(sendImg: Image) -> void:
	var send_data: PackedByteArray = get_image_data(sendImg)
	var remove_list: Array[StreamPeerTCP] = []
	for i: StreamPeerTCP in tc_plist:
		i.poll()
		if i.get_status() == StreamPeerTCP.STATUS_NONE:
			remove_list.append(i)
		else:
			get_client_com(i)
			i.put_data(send_data)
	remove_client(remove_list)


func get_image_data(sendImg: Image) -> PackedByteArray:
	var img: PackedByteArray = sendImg.save_jpg_to_buffer(0.5)
	var img_len: int = img.size()
	var b: PackedByteArray = []
	b.resize(8)
	b.encode_u32(0, img_len)
	var data: PackedByteArray = img.compress(3)
	b.encode_u32(4, data.size())
	return b + data


func remove_client(remove_list: Array[StreamPeerTCP]) -> void:
	for i: StreamPeerTCP in remove_list:
		tcp_num -= 1
		tc_plist.erase(i)


func _physics_process(delta):
	if tcp_server != null:
		send_time += delta
		if send_time >= 0.02:
			send_time = 0
			loop_server()


func _on_tree_exited():
	for i: StreamPeerTCP in tc_plist:
		tcp_num -= 1
		if i.get_status() != StreamPeerTCP.STATUS_NONE:
			i.put_u64(0)
			i.put_u64(0)
	tcp_server.stop()
