extends Node2D

@onready var item_1: TextureRect = $ShopBg/ShopItemList/MysteryShopItemBox
@onready var item_2: TextureRect = $ShopBg/ShopItemList/MysteryShopItemBox2
@onready var item_3: TextureRect = $ShopBg/ShopItemList/MysteryShopItemBox3
@onready var item_4: TextureRect = $ShopBg/ShopItemList/MysteryShopItemBox4
@onready var item_5: TextureRect = $ShopBg/ShopItemList/MysteryShopItemBox5

@onready var all_times: Label = $ShopBg/AllTimes
@onready var all_lh: Label = $ShopBg/AllLH
var child_list1 = []
var child_list2 = []


func _ready() -> void:
	child_list1 = [item_1, item_2, item_3, item_4, item_5]
	child_list2 = [item_2, item_3, item_4, item_5]
	item_1.my_father = self
	item_2.my_father = self
	item_3.my_father = self
	item_4.my_father = self
	item_5.my_father = self
	item_1.my_num = 1
	item_1.open()
	item_2.my_num = 2
	item_2.close()
	item_3.my_num = 3
	item_3.close()
	item_4.my_num = 4
	item_4.close()
	item_5.my_num = 5
	item_5.close()


func _physics_process(delta: float) -> void:
	all_times.text = "购买次数：" + str(PlayerData.player_data["购买次数"])
	all_lh.text = "剩余灵魂：" + str(PlayerData.get_soul())


func _on_close_pressed() -> void:
	queue_free()


func _on_purchase_purchase_times_pressed() -> void:
	Global.add_cure_times_box(self, Vector2(350, 130))
