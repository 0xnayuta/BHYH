extends Node2D

const CLOUD_API_BASE_URL := "http://43.135.23.26:8000"
const CLOUD_AUTH_COOLDOWN_MSEC := 5000
const CLOUD_SAVE_UID_KEY := "uid"
const CLOUD_UPLOAD_TEMP_DIR := "user://cloud_save_upload"
const CLOUD_IMPORT_TEMP_DIR := "user://cloud_save_import"
const CLOUD_UPLOAD_MAX_BYTES := 3 * 1024 * 1024
const CLOUD_SAVE_DOWNLOAD_URL := "https://pan.xunlei.com/s/VP0hqWiZoC9jJJ1zAoyj5dYEA1"

var initialized_data = {}
@onready var cd_number: LineEdit = $background/cd_number
@onready var all_ar: GridContainer = $ScrollContainer/AllAr
@onready var cloud_popup: Control = $CloudArchivePopup
@onready var cloud_login_page: Control = $CloudArchivePopup/Panel/LoginPage
@onready var cloud_action_page: Control = $CloudArchivePopup/Panel/ActionPage
@onready var cloud_account: LineEdit = $CloudArchivePopup/Panel/LoginPage/Account
@onready var cloud_password: LineEdit = $CloudArchivePopup/Panel/LoginPage/Password
@onready var cloud_register_button: Button = $CloudArchivePopup/Panel/LoginPage/Register
@onready var cloud_login_button: Button = $CloudArchivePopup/Panel/LoginPage/Login
@onready var cloud_status: Label = $CloudArchivePopup/Panel/LoginPage/Status
@onready var cloud_uid_hash: LineEdit = $CloudArchivePopup/Panel/ActionPage/UidHash
@onready var cloud_upload_button: Button = $CloudArchivePopup/Panel/ActionPage/Upload
@onready var cloud_upload_confirm: Control = $CloudArchivePopup/UploadConfirm
@onready var cloud_import_confirm: Control = $CloudArchivePopup/ImportConfirm
@onready var cloud_import_help: Control = $CloudArchivePopup/ImportHelp
@onready var cloud_import_file_dialog: FileDialog = $CloudImportFileDialog
@onready var cloud_request: HTTPRequest = $CloudRequest
@onready var cloud_auth_cooldown: Timer = $CloudAuthCooldown

var cloud_request_action := ""
var cloud_user_id := ""
var cloud_access_token := ""
var cloud_uid_md5 := ""
var cloud_account_name := ""
var cloud_upload_zip_path := ""
var cloud_upload_temp_files := PackedStringArray()


func _ready() -> void:
	MemoryClass.main_dq()
	add_ar()
	_restore_cloud_session()
	_update_cloud_auth_buttons()


func _exit_tree() -> void:
	if is_instance_valid(cloud_request):
		cloud_request.cancel_request()
	_cleanup_cloud_upload_files()


func _restore_cloud_session() -> void:
	cloud_user_id = Global.cloud_save_user_id
	cloud_access_token = Global.cloud_save_access_token
	cloud_uid_md5 = Global.cloud_save_uid_md5
	cloud_account_name = Global.cloud_save_account
	cloud_uid_hash.text = _cloud_folder_name() if not cloud_uid_md5.is_empty() else ""


func get_need_box():
	return int(MainSet.set_data["CdNum"])


func remove_ar():
	for i in all_ar.get_children():
		all_ar.remove_child(i)
		i.queue_free()


func add_ar():
	remove_ar()
	for i in range(get_need_box()):
		Global.add_basic_ar_button(all_ar, i + 1)


func _on_close_pressed() -> void:
	queue_free()


func _on_cloud_archive_pressed() -> void:
	cloud_popup.show()
	if cloud_access_token.is_empty():
		cloud_login_page.show()
		cloud_action_page.hide()
		cloud_status.text = "请输入账号和密码"
		cloud_account.grab_focus()
	else:
		cloud_login_page.hide()
		cloud_action_page.show()


func _on_cloud_popup_close_pressed() -> void:
	cloud_upload_confirm.hide()
	cloud_import_confirm.hide()
	cloud_import_help.hide()
	cloud_popup.hide()
	cloud_password.clear()


func _on_cloud_register_pressed() -> void:
	_send_cloud_auth_request("register")


func _on_cloud_login_pressed() -> void:
	_send_cloud_auth_request("login")


func _send_cloud_auth_request(action: String) -> void:
	var username := cloud_account.text.strip_edges()
	var password := cloud_password.text
	if username.is_empty():
		cloud_status.text = "请输入账号"
		return
	if password.is_empty():
		cloud_status.text = "请输入密码"
		return
	if username.length() < 6 or username.length() > 64:
		cloud_status.text = "账号长度必须为 6 到 64 位"
		return
	var account_pattern := RegEx.new()
	account_pattern.compile("^[A-Za-z0-9_]+$")
	if account_pattern.search(username) == null:
		cloud_status.text = "账号只能使用英文、数字或下划线"
		return
	if password.length() < 6 or password.length() > 128:
		cloud_status.text = "密码长度必须为 6 到 128 位"
		return
	if action == "register" and username.to_lower() == password.to_lower():
		cloud_status.text = "账号和密码不能相同"
		return

	var body := JSON.stringify({"username": username, "password": password})
	var headers := PackedStringArray(["Content-Type: application/json"])
	Global.cloud_auth_cooldown_until_msec = Time.get_ticks_msec() + CLOUD_AUTH_COOLDOWN_MSEC
	cloud_auth_cooldown.start()
	cloud_request_action = action
	_set_cloud_auth_busy(true)
	cloud_status.text = "正在注册，请稍候……" if action == "register" else "正在登录，请稍候……"
	var error := cloud_request.request(CLOUD_API_BASE_URL + "/auth/" + action, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		_set_cloud_auth_busy(false)
		cloud_request_action = ""
		cloud_password.clear()
		cloud_status.text = "请求发送失败，请检查网络后重试"


func _set_cloud_auth_busy(is_busy: bool) -> void:
	cloud_account.editable = not is_busy
	cloud_password.editable = not is_busy
	_update_cloud_auth_buttons()


func _on_cloud_auth_cooldown_timeout() -> void:
	_update_cloud_auth_buttons()


func _update_cloud_auth_buttons() -> void:
	var remaining_msec: int = maxi(Global.cloud_auth_cooldown_until_msec - Time.get_ticks_msec(), 0)
	var request_busy := not cloud_request_action.is_empty()
	var cooling_down := remaining_msec > 0
	cloud_register_button.disabled = request_busy or cooling_down
	cloud_login_button.disabled = request_busy or cooling_down
	if cooling_down:
		var remaining_seconds := ceili(float(remaining_msec) / 1000.0)
		cloud_register_button.text = "注册（%d）" % remaining_seconds
		cloud_login_button.text = "登录（%d）" % remaining_seconds
		if cloud_auth_cooldown.is_stopped():
			cloud_auth_cooldown.start()
	else:
		cloud_register_button.text = "注册"
		cloud_login_button.text = "登录"
		cloud_auth_cooldown.stop()


func _on_cloud_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if not is_inside_tree():
		return
	var action := cloud_request_action
	cloud_request_action = ""
	if action == "upload":
		_handle_cloud_upload_completed(result, response_code, body)
		return
	_set_cloud_auth_busy(false)
	cloud_password.clear()

	if result != HTTPRequest.RESULT_SUCCESS:
		cloud_status.text = "请求失败，请检查网络连接"
		return

	var response_text := body.get_string_from_utf8()
	var response = JSON.parse_string(response_text)
	if not response is Dictionary:
		cloud_status.text = "服务器返回异常，请稍后重试"
		return

	var message := _get_cloud_response_message(response)
	if response_code < 200 or response_code >= 300:
		cloud_status.text = message
		return

	if action == "register":
		cloud_status.text = message + "，请点击登录"
		return

	cloud_user_id = str(response.get("user_id", ""))
	cloud_access_token = str(response.get("access_token", ""))
	if cloud_user_id.is_empty() or cloud_access_token.is_empty():
		cloud_status.text = "登录失败：服务器未返回登录凭证"
		cloud_user_id = ""
		cloud_access_token = ""
		return

	cloud_login_page.hide()
	cloud_action_page.show()
	cloud_uid_md5 = cloud_user_id.md5_text()
	cloud_account_name = cloud_account.text.strip_edges()
	cloud_uid_hash.text = _cloud_folder_name()
	Global.cloud_save_user_id = cloud_user_id
	Global.cloud_save_access_token = cloud_access_token
	Global.cloud_save_uid_md5 = cloud_uid_md5
	Global.cloud_save_account = cloud_account_name


func _get_cloud_response_message(response: Dictionary) -> String:
	var detail = response.get("detail", "")
	if detail is String and not detail.is_empty():
		return detail
	if detail is Array and not detail.is_empty():
		var first_error = detail[0]
		if first_error is Dictionary:
			return "请求失败：" + str(first_error.get("msg", "输入内容不符合要求"))
	var message = response.get("message", "")
	if message is String and not message.is_empty():
		return message
	return "请求失败，请稍后重试"


func _on_cloud_upload_pressed() -> void:
	if cloud_access_token.is_empty() or cloud_user_id.is_empty():
		Global.add_message_show(self, "登录状态无效，请退出后重新登录", 1.5, Vector2(470, 300))
		return
	cloud_upload_confirm.show()


func _on_cloud_upload_cancel_pressed() -> void:
	cloud_upload_confirm.hide()


func _confirm_cloud_upload() -> void:
	cloud_upload_confirm.hide()
	if not cloud_request_action.is_empty():
		Global.add_message_show(self, "已有请求正在处理中，请稍候", 1.5, Vector2(470, 300))
		return
	var prepare_result := _prepare_cloud_upload_zip()
	if not bool(prepare_result.get("ok", false)):
		Global.add_message_show(self, str(prepare_result.get("message", "存档打包失败")), 2.0, Vector2(470, 300))
		_cleanup_cloud_upload_files()
		return
	var send_error := _send_cloud_upload_request()
	if send_error != OK:
		cloud_request_action = ""
		cloud_upload_button.disabled = false
		cloud_upload_button.text = "上传存档"
		_cleanup_cloud_upload_files()
		Global.add_message_show(self, "上传请求发送失败，请检查网络", 2.0, Vector2(470, 300))


func _prepare_cloud_upload_zip() -> Dictionary:
	if cloud_account_name.is_empty():
		return {"ok": false, "message": "缺少登录账号，请退出后重新登录"}
	var archives := _collect_local_cloud_archives()
	if archives.is_empty():
		return {"ok": false, "message": "没有找到可上传的本地存档"}

	for archive in archives:
		var archive_data: Dictionary = archive["data"]
		var bound_uid := str(archive_data.get(CLOUD_SAVE_UID_KEY, "")).strip_edges()
		if not bound_uid.is_empty() and bound_uid != cloud_user_id:
			return {
				"ok": false,
				"message": "存档%d已绑定其他账号，不能上传" % int(archive["number"]),
			}

	for archive in archives:
		var archive_data: Dictionary = archive["data"]
		if str(archive_data.get(CLOUD_SAVE_UID_KEY, "")).strip_edges().is_empty():
			archive_data[CLOUD_SAVE_UID_KEY] = cloud_user_id
			if not MemoryClass.safe_write_archive(str(archive["path"]), archive_data):
				return {
					"ok": false,
					"message": "存档%d绑定账号失败，请重试" % int(archive["number"]),
				}

	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CLOUD_UPLOAD_TEMP_DIR))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return {"ok": false, "message": "无法创建存档打包目录"}

	_cleanup_cloud_upload_files()
	cloud_upload_zip_path = CLOUD_UPLOAD_TEMP_DIR.path_join(_cloud_zip_filename())
	var packer := ZIPPacker.new()
	var open_error := packer.open(cloud_upload_zip_path)
	if open_error != OK:
		return {"ok": false, "message": "无法创建存档压缩包"}

	var encryption_key := _cloud_archive_encryption_key()
	for archive in archives:
		var archive_name := str(archive["name"])
		var encrypted_path := CLOUD_UPLOAD_TEMP_DIR.path_join(archive_name + ".encrypted")
		if not _write_cloud_encrypted_archive(encrypted_path, archive["data"], encryption_key):
			packer.close()
			return {"ok": false, "message": "存档%d加密失败" % int(archive["number"])}
		cloud_upload_temp_files.append(encrypted_path)
		var encrypted_file := FileAccess.open(encrypted_path, FileAccess.READ)
		if encrypted_file == null:
			packer.close()
			return {"ok": false, "message": "无法读取加密后的存档"}
		var encrypted_bytes := encrypted_file.get_buffer(encrypted_file.get_length())
		encrypted_file.close()
		if packer.start_file(archive_name) != OK:
			packer.close()
			return {"ok": false, "message": "无法写入存档压缩包"}
		packer.write_file(encrypted_bytes)
		packer.close_file()
	packer.close()

	var zip_file := FileAccess.open(cloud_upload_zip_path, FileAccess.READ)
	if zip_file == null:
		return {"ok": false, "message": "无法读取存档压缩包"}
	var zip_size := zip_file.get_length()
	zip_file.close()
	if zip_size <= 0:
		return {"ok": false, "message": "生成的存档压缩包为空"}
	if zip_size > CLOUD_UPLOAD_MAX_BYTES:
		return {"ok": false, "message": "全部存档压缩后不能超过3 MB"}
	return {"ok": true, "archive_count": archives.size(), "size": zip_size}


func _collect_local_cloud_archives() -> Array[Dictionary]:
	var archives: Array[Dictionary] = []
	var user_directory := DirAccess.open("user://")
	if user_directory == null:
		return archives
	var archive_pattern := RegEx.new()
	archive_pattern.compile("^MyAr_([1-9][0-9]*)\\.json$")
	for file_name in user_directory.get_files():
		var match_result := archive_pattern.search(file_name)
		if match_result == null:
			continue
		var archive_path := "user://" + file_name
		var archive_data: Dictionary = MemoryClass.peek_archive_data(archive_path)
		var role_id := int(archive_data.get("Myself", 0))
		if role_id < 1 or role_id > 6:
			continue
		(
			archives
			. append(
				{
					"number": int(match_result.get_string(1)),
					"name": file_name,
					"path": archive_path,
					"data": archive_data,
				}
			)
		)
	archives.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["number"]) < int(b["number"]))
	return archives


func _write_cloud_encrypted_archive(path: String, data: Dictionary, encryption_key: String) -> bool:
	var writer := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_key)
	if writer == null:
		return false
	writer.store_line(JSON.stringify(data))
	writer.flush()
	var write_error := writer.get_error()
	writer.close()
	return write_error == OK


func _cloud_zip_filename() -> String:
	return cloud_uid_md5 + ".zip"


func _cloud_folder_name() -> String:
	return cloud_uid_md5


func _cloud_archive_encryption_key() -> String:
	return (_cloud_zip_filename() + cloud_account_name + cloud_user_id).md5_text()


func _send_cloud_upload_request() -> Error:
	var zip_file := FileAccess.open(cloud_upload_zip_path, FileAccess.READ)
	if zip_file == null:
		return ERR_FILE_CANT_OPEN
	var zip_bytes := zip_file.get_buffer(zip_file.get_length())
	zip_file.close()
	var boundary := "----GodotCloudSave" + str(Time.get_ticks_usec())
	var request_body := PackedByteArray()
	request_body.append_array(
		(
			(
				"--"
				+ boundary
				+ "\r\n"
				+ 'Content-Disposition: form-data; name="file"; filename="'
				+ _cloud_zip_filename()
				+ '"\r\n'
				+ "Content-Type: application/zip\r\n\r\n"
			)
			. to_utf8_buffer()
		)
	)
	request_body.append_array(zip_bytes)
	request_body.append_array(("\r\n--" + boundary + "--\r\n").to_utf8_buffer())
	var headers := PackedStringArray(
		[
			"Authorization: Bearer " + cloud_access_token,
			"Content-Type: multipart/form-data; boundary=" + boundary,
		]
	)
	cloud_request_action = "upload"
	cloud_upload_button.disabled = true
	cloud_upload_button.text = "上传中……"
	return cloud_request.request_raw(
		CLOUD_API_BASE_URL + "/saves/upload", headers, HTTPClient.METHOD_POST, request_body
	)


func _handle_cloud_upload_completed(result: int, response_code: int, body: PackedByteArray) -> void:
	cloud_upload_button.disabled = false
	cloud_upload_button.text = "上传存档"
	_cleanup_cloud_upload_files()
	if result != HTTPRequest.RESULT_SUCCESS:
		Global.add_message_show(self, "上传失败，请稍后重试", 2.0, Vector2(470, 300))
		return
	var response = JSON.parse_string(body.get_string_from_utf8())
	if not response is Dictionary:
		Global.add_message_show(self, "上传失败，请稍后重试", 2.0, Vector2(470, 300))
		return
	if response_code < 200 or response_code >= 300:
		Global.add_message_show(self, "上传失败，请稍后重试", 2.0, Vector2(470, 300))
		return
	Global.add_message_show(self, "上传成功", 2.0, Vector2(470, 300))


func _cleanup_cloud_upload_files() -> void:
	for path in cloud_upload_temp_files:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	cloud_upload_temp_files.clear()
	if not cloud_upload_zip_path.is_empty() and FileAccess.file_exists(cloud_upload_zip_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(cloud_upload_zip_path))
	cloud_upload_zip_path = ""


func _on_cloud_import_pressed() -> void:
	if cloud_access_token.is_empty() or cloud_user_id.is_empty():
		Global.add_message_show(self, "登录状态无效，请退出后重新登录", 1.5, Vector2(470, 300))
		return
	cloud_import_confirm.show()


func _on_cloud_import_help_pressed() -> void:
	cloud_import_help.show()


func _on_cloud_import_help_close_pressed() -> void:
	cloud_import_help.hide()


func _on_cloud_download_link_copy_pressed() -> void:
	DisplayServer.clipboard_set(CLOUD_SAVE_DOWNLOAD_URL)
	Global.add_message_show(self, "存档下载链接已复制", 1.5, Vector2(470, 300))


func _on_cloud_import_cancel_pressed() -> void:
	cloud_import_confirm.hide()


func _confirm_cloud_import() -> void:
	cloud_import_confirm.hide()
	if cloud_account_name.is_empty():
		Global.add_message_show(self, "缺少登录账号，请退出后重新登录", 2.0, Vector2(470, 300))
		return
	var downloads_path := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	if OS.get_name() == "Android":
		OS.request_permission("android.permission.READ_EXTERNAL_STORAGE")
		downloads_path = "/storage/emulated/0/Download/"
	if not downloads_path.is_empty():
		cloud_import_file_dialog.current_dir = downloads_path
	cloud_import_file_dialog.popup_centered_ratio(0.85)


func _on_cloud_import_file_selected(path: String) -> void:
	var import_result := _import_cloud_save_zip(path)
	Global.add_message_show(self, str(import_result.get("message", "导入失败")), 2.0, Vector2(470, 300))
	if bool(import_result.get("ok", false)):
		MemoryClass.main_dq()
		add_ar()


func _import_cloud_save_zip(path: String) -> Dictionary:
	var selected_file := FileAccess.open(path, FileAccess.READ)
	if selected_file == null:
		return {"ok": false, "message": "无法读取选择的压缩包"}
	var selected_size := selected_file.get_length()
	selected_file.close()
	if selected_size <= 0:
		return {"ok": false, "message": "选择的压缩包为空"}
	if selected_size > CLOUD_UPLOAD_MAX_BYTES:
		return {"ok": false, "message": "导入的压缩包不能超过3 MB"}

	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CLOUD_IMPORT_TEMP_DIR))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return {"ok": false, "message": "无法创建存档导入目录"}
	_cleanup_cloud_import_files()

	var zip_reader := ZIPReader.new()
	var open_error := zip_reader.open(path)
	if open_error != OK:
		return {"ok": false, "message": "选择的文件不是有效的 ZIP 压缩包"}
	var archive_pattern := RegEx.new()
	archive_pattern.compile("^MyAr_([1-9][0-9]*)\\.json$")
	var imported_archives: Array[Dictionary] = []
	var imported_names := {}
	var encryption_key := _cloud_archive_encryption_key()
	for entry_name in zip_reader.get_files():
		var match_result := archive_pattern.search(entry_name)
		if match_result == null:
			continue
		if imported_names.has(entry_name):
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "压缩包中存在重复存档文件"}
		imported_names[entry_name] = true
		var encrypted_bytes := zip_reader.read_file(entry_name)
		if encrypted_bytes.is_empty():
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "压缩包中的存档文件为空"}
		var encrypted_path := CLOUD_IMPORT_TEMP_DIR.path_join(entry_name + ".encrypted")
		var encrypted_file := FileAccess.open(encrypted_path, FileAccess.WRITE)
		if encrypted_file == null:
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "无法提取压缩包中的存档"}
		encrypted_file.store_buffer(encrypted_bytes)
		encrypted_file.close()
		var decrypted_file := FileAccess.open_encrypted_with_pass(encrypted_path, FileAccess.READ, encryption_key)
		if decrypted_file == null:
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "存档解密失败：账号或文件不匹配"}
		var archive_data_value = JSON.parse_string(decrypted_file.get_as_text())
		decrypted_file.close()
		if not archive_data_value is Dictionary:
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "存档解密失败：内容格式不正确"}
		var archive_data: Dictionary = archive_data_value
		if not _is_valid_cloud_archive_data(archive_data):
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "存档内容不完整，不能导入"}
		if str(archive_data.get(CLOUD_SAVE_UID_KEY, "")) != cloud_user_id:
			zip_reader.close()
			_cleanup_cloud_import_files()
			return {"ok": false, "message": "存档已绑定其他账号，不能导入"}
		(
			imported_archives
			. append(
				{
					"number": int(match_result.get_string(1)),
					"name": entry_name,
					"data": archive_data,
				}
			)
		)
	zip_reader.close()
	_cleanup_cloud_import_files()

	if imported_archives.is_empty():
		return {"ok": false, "message": "压缩包中没有找到有效存档"}
	imported_archives.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool: return int(a["number"]) < int(b["number"])
	)
	var imported_count := 0
	var largest_archive_number := 0
	for archive in imported_archives:
		var target_path := "user://" + str(archive["name"])
		if not MemoryClass.safe_write_archive(target_path, archive["data"]):
			return {"ok": false, "message": "存档%d写入失败，请重试" % int(archive["number"])}
		imported_count += 1
		largest_archive_number = maxi(largest_archive_number, int(archive["number"]))
	if largest_archive_number > int(MainSet.set_data.get("CdNum", 6)):
		MainSet.set_data["CdNum"] = largest_archive_number
		MemoryClass.main_bc()
	return {"ok": true, "message": "成功导入%d个存档" % imported_count}


func _is_valid_cloud_archive_data(data: Dictionary) -> bool:
	var role_id := int(data.get("Myself", 0))
	if role_id < 1 or role_id > 6 or not data.has(DataKeys.PLAYER_LEVEL):
		return false
	for key in ["装备列表", "道具列表", "消耗品列表"]:
		var container_value = data.get(key)
		if not container_value is Dictionary or not container_value.has("页码1"):
			return false
		if not container_value["页码1"] is Array:
			return false
	return true


func _cleanup_cloud_import_files() -> void:
	var import_directory := DirAccess.open(CLOUD_IMPORT_TEMP_DIR)
	if import_directory == null:
		return
	for file_name in import_directory.get_files():
		if file_name.ends_with(".encrypted"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(CLOUD_IMPORT_TEMP_DIR.path_join(file_name)))


func _on_cloud_copy_uid_pressed() -> void:
	if cloud_uid_md5.is_empty():
		return
	DisplayServer.clipboard_set(_cloud_folder_name())
	Global.add_message_show(self, "文件夹名已复制", 1.5, Vector2(470, 300))


func _on_cloud_logout_pressed() -> void:
	cloud_user_id = ""
	cloud_access_token = ""
	cloud_uid_md5 = ""
	cloud_account_name = ""
	cloud_uid_hash.clear()
	Global.cloud_save_user_id = ""
	Global.cloud_save_access_token = ""
	Global.cloud_save_uid_md5 = ""
	Global.cloud_save_account = ""
	cloud_action_page.hide()
	cloud_login_page.show()
	cloud_status.text = "已退出登录"
	cloud_account.grab_focus()


func _on_delete_pressed() -> void:
	if int(cd_number.text) > get_need_box() or int(cd_number.text) <= 0:
		Global.add_message_show(self, "找不到存档" + str(cd_number.text) + "的信息，请确保正确输入了存档号！！", 1.5, Vector2(470, 300))
		return
	if cd_number.text == "":
		Global.add_message_show(self, "找不到存档信息，请确保正确输入了存档号！！", 1.5, Vector2(470, 300))
		return
	else:
		Signals.connect_choose_box_signal(self, "_remove_save_data")
		Global.add_choose_text(self, Vector2(0, 0), "确定要删除存档" + str(cd_number.text) + "吗？\n（删除后无法恢复！）", 0)


func _remove_save_data():
	remove_data()
	var archive_path: String = "user://MyAr_" + cd_number.text + ".json"
	if not MemoryClass.safe_write_archive(archive_path, initialized_data):
		Global.add_message_show(self, "存档重置失败，请重试", 1.5, Vector2(470, 300))
		return
	add_ar()
	Global.add_message_show(self, "存档" + cd_number.text + "已重置为初始状态！！", 1.5, Vector2(470, 300))


func remove_data():
	initialized_data = PlayerData.initialized_data.duplicate(true)
	MemoryClass.remove_main_data(int(cd_number.text))

	MemoryClass.main_bc()


func remove_main_data(Num: int):
	if Num <= 6:
		MainSet.set_data["name" + str(Num)] = ""
		MainSet.set_data["time" + str(Num)] = ""
	else:
		MainSet.set_data["其他存档"][str(Num)]["name"] = ""
		MainSet.set_data["其他存档"][str(Num)]["time"] = ""


func get_time():
	var date = Time.get_date_string_from_system()
	var _time = Time.get_time_string_from_system()
	var last_time = date + " " + _time
	return last_time


func _on_addcd_pressed() -> void:
	MainSet.set_data["CdNum"] += 1
	Global.add_message_show(self, "添加成功，不要添加过多，以防卡顿！！", 1.5, Vector2(470, 300))
	MemoryClass.main_bc()
	add_ar()


func _on_removecd_pressed() -> void:
	if MainSet.set_data["CdNum"] <= 6:
		Global.add_message_show(self, "最少保留6个存档格子！！！", 1.5, Vector2(470, 300))
		return
	MainSet.set_data["CdNum"] -= 1
	MemoryClass.main_bc()
	add_ar()
