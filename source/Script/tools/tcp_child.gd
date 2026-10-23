extends Control

@onready var img: TextureRect = $img

var tcp_child: StreamPeerTCP

var get_time: float = 0
var key_map: Dictionary = {
	"87": "Exit1",
	"65": "move_left1",
	"83": "down1",
	"68": "move_right1",
	"74": "normalhit1",
	"75": "jump1",
	"32": "无双1",
	"72": "MagicWeapon1",
	"89": "slz1",
	"85": "lys1",
	"73": "lyfb1",
	"79": "hmz1",
	"76": "hytj1"
}


func _ready() -> void:
	pass
	tcp_child = StreamPeerTCP.new()
	tcp_child.big_endian = true
	if tcp_child.connect_to_host("127.0.0.1", 8889) != OK:
		get_tree().quit()


func _physics_process(delta) -> void:
	if tcp_child == null:
		return
	get_time += delta
	if get_time >= 0.01:
		get_time = 0
		tcp_child.poll()
		if tcp_child.get_status() != StreamPeerTCP.STATUS_NONE && tcp_child.get_available_bytes() >= 16:
			var data_list: PackedByteArray = tcp_child.get_data(8)[1]
			var data_len: int = data_list.decode_u32(0)
			var send_len: int = data_list.decode_u32(4)
			if data_len != 0:
				var data: PackedByteArray = tcp_child.get_data(send_len)[1]
				if data != null && data.size() == send_len:
					call_deferred("set_texture", data.decompress(data_len, 3))
			else:
				get_tree().quit()


func set_texture(data: PackedByteArray) -> void:
	var _img: Image = Image.new()
	_img.load_jpg_from_buffer(data)

	var image_texture: ImageTexture = ImageTexture.create_from_image(_img)
	img.texture = image_texture


func _on_tree_exited():
	tcp_child.disconnect_from_host()


func _input(event: InputEvent):
	if event is InputEventKey:
		var key: String = str(event.keycode)
		if key_map.has(key):
			var data: PackedByteArray = []
			data.resize(5)
			if event.pressed:
				data[0] = 1
			else:
				data[0] = 2
			data.append_array((key_map[key] as String).to_utf8_buffer())
			data.encode_u32(1, data.size() - 5)
			tcp_child.put_data(data)
