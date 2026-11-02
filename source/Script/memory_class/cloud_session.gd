class_name CloudSession
extends RefCounted

## 云存档登录会话：只保存在进程内，不写入本地档案。
## 由 MemoryClass 持有，档案界面通过 get_cloud_session() 读取/更新；不新增 Autoload。

var user_id: String = ""
var access_token: String = ""
var uid_md5: String = ""
var account_name: String = ""
var auth_cooldown_until_msec: int = 0


func set_credentials(p_user_id: String, p_access_token: String, p_uid_md5: String, p_account_name: String) -> void:
	user_id = p_user_id
	access_token = p_access_token
	uid_md5 = p_uid_md5
	account_name = p_account_name


func clear_auth() -> void:
	user_id = ""
	access_token = ""
	uid_md5 = ""
	account_name = ""


func has_credentials() -> bool:
	return not user_id.is_empty() and not access_token.is_empty()


func begin_auth_cooldown(duration_msec: int) -> void:
	auth_cooldown_until_msec = Time.get_ticks_msec() + maxi(duration_msec, 0)


func remaining_auth_cooldown_msec() -> int:
	return maxi(auth_cooldown_until_msec - Time.get_ticks_msec(), 0)
