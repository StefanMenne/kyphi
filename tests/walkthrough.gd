extends Node
## Spielt Teil 1 ohne Wartezeiten vom Prolog bis zum Ende durch.
## godot --headless --path . res://tests/walkthrough.tscn

var main: Node
var failed := false
var last := ""


func _ready() -> void:
	Game.fast = true
	# Hängt eine Aktion (wartet auf etwas, das nie kommt), bricht der Test ab.
	get_tree().create_timer(60.0).timeout.connect(func():
		print("!! FEHLER: hängt nach '%s' im Raum %s" % [last, Game.room_id])
		get_tree().quit(1))
	main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	await run()
	print("\nERGEBNIS: ", "FEHLER" if failed or not Game.flag("ending") else "OK – Ende von Teil 1 erreicht")
	get_tree().quit(1 if failed or not Game.flag("ending") else 0)


func check(cond: bool, what: String) -> void:
	if not cond:
		failed = true
		push_error("Prüfung fehlgeschlagen: " + what)
		print("!! FEHLER: " + what)


## Hotspot benutzen (item leer), ansehen (mode "look") oder Gegenstand darauf anwenden.
func act(hid: String, item := "", mode := "use") -> void:
	if failed:
		return
	var hs = main.room.find_hotspot(hid)
	check(hs != null and main.room.is_active(hid), "Hotspot %s in %s" % [hid, Game.room_id])
	if failed:
		return
	if item != "":
		check(Game.has(item), "Gegenstand %s im Inventar" % item)
	last = "%s %s%s" % [mode, hid, (" mit " + item) if item != "" else ""]
	print("\n>> " + last)
	main.selected = item
	await main.act(hs, mode)


func combine(a: String, b: String) -> void:
	if failed:
		return
	check(Game.has(a) and Game.has(b), "Kombinieren %s + %s" % [a, b])
	last = "kombiniere %s + %s" % [a, b]
	print("\n>> " + last)
	main.selected = a
	await main.on_item_clicked(b, MOUSE_BUTTON_LEFT)


func look_item(item: String) -> void:
	print("\n>> ansehen %s" % item)
	await main.on_item_clicked(item, MOUSE_BUTTON_RIGHT)


func in_room(r: String) -> void:
	check(Game.room_id == r, "im Raum %s (ist %s)" % [r, Game.room_id])


func run() -> void:
	await main.new_game()
	in_room("apartment")
	# Kapitel 0
	await act("remote")
	await act("dictaphone")
	await combine("batteries", "dictaphone")
	Game.choice_script = ["VOX"]
	await look_item("dictaphone")
	check(Game.flag("vox"), "VOX an")
	await act("door")
	in_room("lobby")
	await act("workshop_door")
	in_room("workshop")
	for t in ["ladder", "tweezers", "evidence_bag", "brush", "spatula", "caliper", "uv_lamp", "saucer", "drill", "masking_tape"]:
		await act(t)
	await act("altar_door")
	in_room("altar_room")
	# Kapitel 1
	await act("detector", "ladder")
	await act("detector")
	await act("detector")
	await act("detector", "tweezers")
	await act("detector")
	check(Game.flag("tape_removed"), "Klebeband ab")
	check(Game.has("ladder"), "Leiter wieder im Inventar")
	# Kapitel 2
	await act("cabinet", "dictaphone")
	check(Game.flag("dictaphone_hidden"), "Diktiergerät versteckt")
	await act("workshop_door")
	await act("lobby_door")
	Game.choice_script = ["gestern Abend", ""]
	await act("ackermann")
	await act("portal")
	in_room("apartment")
	check(Game.flag("night_done"), "Nacht vorbei")
	await act("door")
	await act("workshop_door")
	await act("altar_door")
	await act("cabinet")
	await act("workshop_door")
	await act("lobby_door")
	await act("portal")
	# Kapitel 3
	await act("laptop")
	check(Game.flag("recording_heard"), "Aufnahme gehört")
	await act("door")
	# Kapitel 4
	Game.choice_script = ["Depotschlüssel", ""]
	await act("ackermann")
	check(not Game.has("depot_key"), "kein Schlüssel ohne Nummer")
	await act("archive")
	await act("workshop_door")
	await act("altar_door")
	await act("soot", "spatula")
	await combine("brush", "spatula_soot")
	await combine("brush_soot", "index_card")
	check(Game.has("index_card_revealed"), "D-0912 lesbar")
	await act("workshop_door")
	await act("lobby_door")
	Game.choice_script = ["Depotschlüssel", ""]
	await act("ackermann")
	check(Game.has("depot_key"), "Depotschlüssel")
	await act("stairs_door")
	in_room("depot")
	# Kapitel 5
	await act("shelf_d")
	check(not Game.flag("box_found"), "im Dunkeln nichts gefunden")
	await act("switch")
	await act("shelf_d")
	check(Game.flag("box_found"), "Kiste gefunden")
	await act("box")
	await act("box", "caliper")
	await act("box", "spatula")
	check(Game.has("id_card") and Game.has("screw_bit"), "Versteck geleert")
	await look_item("notebook")
	await act("stairs")
	await act("portal")
	in_room("lobby")
	check(Game.has("depot_key"), "ohne Rückgabe kein Heimweg")
	await act("ackermann", "depot_key")
	# Kapitel 6a
	Game.choice_script = ["Feuer", "Feuer", ""]
	await act("ackermann")
	await act("ackermann", "incense_cone")
	check(Game.has("lighter"), "Feuerzeug")
	await act("workshop_door")
	await act("altar_door")
	await act("ash", "incense_cone")
	# Kapitel 6b
	await combine("lighter", "incense_cone")
	check(int(Game.value("alarms")) == 1 and Game.has("incense_cone"), "Alarm, Kegel zurück")
	await combine("incense_cone", "saucer")
	check(int(Game.value("alarms")) == 2, "zweiter Alarm")
	await act("detector", "masking_tape")
	await combine("lighter", "incense_cone")
	check(Game.has("cone_saucer"), "Kegel brennt")
	await act("workshop_door")
	in_room("altar_room")
	# Kapitel 6c und 7
	await act("panel_2", "cone_saucer")
	await act("panel_4", "cone_saucer")
	check(Game.flag("panel4_found"), "Paneel 4 gefunden")
	await act("panel_4", "spatula")
	await act("panel_4", "uv_lamp")
	await act("panel_4", "spatula")
	await act("panel_4", "drill")
	await combine("drill", "screw_bit")
	await act("panel_4", "drill_bit")
	check(Game.flag("panel_removed"), "Paneel abgenommen")
	# Kapitel 8
	await act("steel_door", "id_card")
