extends Node
## Spielzustand (Flags, Inventar, Raum) und Kurzbefehle für die Raumskripte.

signal inventory_changed

const SAVE_PATH := "user://save.json"

var catalog: Dictionary = {}
var flags: Dictionary = {}
var inventory: Array = []
var room_id := ""
var main: Node = null
## Testmodus: statt Wartezeiten nur ein Frame, kein Ton, Texte nur in die Konsole.
var fast := false
## Testmodus: Teiltexte der Antworten, die choose() der Reihe nach wählt.
var choice_script: Array = []


func _ready() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string("res://assets/catalog.json"))


func reset() -> void:
	flags = {}
	inventory = []
	inventory_changed.emit()


func flag(name: String) -> bool:
	return flags.get(name, false)


func value(name: String, default = 0):
	return flags.get(name, default)


func set_flag(name: String, v = true) -> void:
	flags[name] = v


func has(item: String) -> bool:
	return item in inventory


func add_item(item: String) -> void:
	if not has(item):
		inventory.append(item)
		inventory_changed.emit()


func remove_item(item: String) -> void:
	inventory.erase(item)
	inventory_changed.emit()


## Ersetzt einen Gegenstand an derselben Stelle im Inventar.
func swap_item(old: String, new: String) -> void:
	var i := inventory.find(old)
	if i < 0:
		add_item(new)
	else:
		inventory[i] = new
		inventory_changed.emit()


func item_name(id: String) -> String:
	return catalog["items"][id]["name"]


func item_icon(id: String) -> Texture2D:
	return load("res://assets/" + catalog["items"][id]["icon_small"])


func say(speaker: String, text: String, voice := "") -> void:
	await main.say(speaker, text, voice)


func choose(options: Array) -> int:
	await main.flush_gesture()
	if fast:
		var want: String = choice_script.pop_front() if not choice_script.is_empty() else ""
		for i in options.size():
			if want != "" and want in options[i]:
				print("  > " + options[i])
				return i
		print("  > " + options[-1])
		return options.size() - 1
	return await main.ui.choose(options)


func note(text: String) -> void:
	await main.flush_gesture()
	if fast:
		print("[Notiz] " + text.replace("\n", " / "))
		await get_tree().process_frame
		return
	await main.ui.show_note(text)


func wait(seconds: float) -> void:
	if fast:
		await get_tree().process_frame
		return
	await get_tree().create_timer(seconds).timeout


func save_game() -> void:
	if fast:
		return
	var data := {
		"room": room_id,
		"x": main.player.position.x,
		"y": main.player.position.y,
		"flags": flags,
		"inventory": inventory,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, " "))


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func load_save() -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	flags = data["flags"]
	inventory = data["inventory"]
	inventory_changed.emit()
	return data


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
