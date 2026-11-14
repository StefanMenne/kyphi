extends Node
## Spielt Teil 1 ohne Wartezeiten vom Prolog bis zum Ende durch, dann den Anfang von Teil 2: Zug in die Antarktis und zurück ins Museum, dann Innenerde: Bahnhof, Hydroponik mit Lift, Wetterschleuse mit der Leiter.
## godot --headless --path . res://tests/walkthrough.tscn

var main: Node
var failed := false
## Blickrichtungen passen nicht (bricht den Durchlauf nicht ab, das Ergebnis ist trotzdem FEHLER)
var facing_failed := false
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
	check_facing()
	await run()
	print("\nERGEBNIS: ", "FEHLER" if failed or facing_failed or not Game.flag("medal_found") else "OK – Ende von Teil 1 erreicht, in Teil 2 Antarktis bis zur Medaille und zurück, Lift, Wetterschleuse, Kohlestaub, Walnussöl und umgearbeitete Karte der Innenerde")
	get_tree().quit(1 if failed or facing_failed or not Game.flag("medal_found") else 0)


func check(cond: bool, what: String) -> void:
	if not cond:
		failed = true
		push_error("Prüfung fehlgeschlagen: " + what)
		print("!! FEHLER: " + what)


## Blickrichtung jedes Hotspots passt zu seinem Laufpunkt: bei "left"/"right" liegt die Mitte des Bereichs auf
## dieser Seite, bei "back" liegt der Laufpunkt (bis auf 5 % Figurhöhe) unter dem Bereich. Räume ohne Martin
## (Zugabteil) zählen nicht.
func check_facing() -> void:
	var rooms: Dictionary = main.ROOMS
	for rid in rooms:
		var room: Room = rooms[rid].new()
		room.id = rid
		room.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(room)
		room.setup()
		if room.show_player:
			for hs in room.hotspots:
				var r: Rect2 = hs["area"]
				var w: Vector2 = hs["walk"]
				var tol := 0.05 * room.height_at(w.y)
				var ok: bool = {"left": r.get_center().x < w.x, "right": r.get_center().x > w.x,
					"back": w.x > r.position.x - tol and w.x < r.end.x + tol}.get(hs["face"], false)
				if not ok:
					facing_failed = true
					push_error("Blickrichtung falsch")
					print("!! FEHLER: Blickrichtung %s von %s in %s passt nicht zum Laufpunkt %s (Bereich x %d bis %d)" % [
						hs["face"], hs["id"], rid, w, r.position.x, r.end.x])
		room.free()


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
	check(Game.flag("ladder_up") and not Game.has("ladder"), "Leiter steht")
	# Kapitel 2
	await act("cabinet", "dictaphone")
	check(Game.flag("dictaphone_hidden"), "Diktiergerät versteckt")
	await act("workshop_door")
	in_room("altar_room")
	await act("ladder")
	check(Game.has("ladder") and not Game.flag("ladder_up"), "Leiter wieder im Inventar")
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
	check(not Game.has("spatula_soot"), "Ruß nur von der Leiter")
	await act("podium", "ladder")
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
	check(not Game.flag("box_found"), "Licht aus, sobald Martin den Taster loslässt")
	await act("shelf_d", "uv_lamp")
	check(not Game.flag("box_found"), "UV-Lampe reicht nicht")
	await act("switch", "masking_tape")
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
	check(Game.flag("ending"), "Ende von Teil 1")
	# Teil 2: Bahnhof unter dem Museum
	in_room("museum_station")
	check(not Game.has("cone_saucer") and not Game.has("saucer"), "Teller bleibt oben")
	await act("train", "", "look")
	await act("train_door")
	check(Game.flag("departed"), "in den Zug gestiegen")
	in_room("train_cabin")
	await act("st_abc")
	in_room("train_cabin")
	await act("st_antarctica")
	in_room("antarctica_platform")
	await act("control_door")
	in_room("antarctica_control_room")
	Game.choice_script = ["Antenne", "bürgen", "Bis später"]
	await act("pjotr")
	await act("coffee")
	await act("coffee", "caliper")
	check(Game.flag("fuse_measured"), "Sicherung gemessen")
	var room = main.room
	var w: Array = room.wind()
	var too_much := [2, 2, 2, 2, 2, 2]
	check(not room.set_heating(too_much), "Sicherung fliegt bei zu viel Heizung")
	check(room.set_heating(w), "richtige Heizung passt")
	check(room.first_frozen() == 0, "keine Ebene mehr zugefroren")
	Game.add_item("fuse")
	await act("fuse_box", "fuse")
	check(Game.flag("gate_fuse_in"), "Torheizung hat Strom")
	await act("door")
	in_room("antarctica_platform")
	await act("stairs")
	in_room("antarctica_observation")
	await act("telescope")
	check(not Game.flag("telescope_thawed"), "Fernrohr noch eingefroren")
	Game.add_item("thermos")
	await act("telescope", "thermos")
	await act("telescope")
	check(Game.flag("saw_412"), "412 im Fernrohr gesehen")
	await act("stairs")
	in_room("antarctica_platform")
	# Schleuse und Antenne
	await act("airlock_door")
	in_room("antarctica_airlock")
	Game.add_item("salt")
	await act("gate", "salt")
	await act("glycol")
	check(Game.has("glycol_canister"), "Glykol-Kanister")
	await act("suit", "drill" if Game.has("drill") else "drill_bit")
	check(Game.has("drill_battery"), "leerer Akku aus dem Akkuschrauber")
	await act("gate")
	check(main.room.id == "antarctica_airlock", "ohne Heizung nicht raus")
	Game.swap_item("drill_battery", "drill_battery_charged")
	await act("suit", "drill_battery_charged")
	await act("gate")
	in_room("antarctica_antenna")
	check(main.player.suit, "draußen im Kälteanzug")
	await act("tower")
	if not Game.has("ladder"):
		Game.add_item("ladder")
	await act("tower", "ladder")
	await act("tower")
	await act("runner")
	check(Game.has("runner_broken"), "412s Läufer")
	await act("tower")
	check(not Game.has("medal"), "kaputter Läufer reicht nicht")
	Game.swap_item("runner_broken", "runner")
	await act("tower")
	check(not Game.has("medal"), "Anzug flattert")
	await act("station")
	in_room("antarctica_airlock")
	check(not main.player.suit, "drinnen ohne Anzug")
	Game.add_item("duct_tape")
	await act("suit", "duct_tape")
	await act("gate")
	Game.set_flag("heating", [0, 0, 0, 0, 0, 0])
	await act("tower")
	check(not Game.has("medal"), "Leiter zugefroren")
	Game.set_flag("heating", main.room.CR.wind().duplicate())
	await act("tower")
	check(Game.has("medal"), "Medaille geborgen")
	await act("station")
	await act("platform_door")
	in_room("antarctica_platform")
	await act("train_airlock")
	in_room("train_cabin")
	await act("st_museum")
	in_room("museum_station")
	await act("elevator")
	in_room("altar_room")
	await act("steel_door")
	in_room("museum_station")
	check(Game.flag("antarctica_seen"), "in der Antarktis gewesen")
	# Innenerde: Bahnhof, durch das Gitter in die Hydroponik (Übergang ohne Luftschacht), Lift
	await act("train_door")
	in_room("train_cabin")
	await act("st_inner_earth")
	in_room("inner_earth_station")
	await act("hydro_door")
	in_room("inner_earth_station")
	await act("grille")
	check(Game.flag("station_grille_open"), "Gitter offen")
	await act("grille")
	in_room("inner_earth_air_shaft")
	check(main.room.spot() == "station", "im Schacht am Bahnhofsgitter")
	await act("end_grille")
	check(main.room.spot() == "bottom", "ohne Dunst nicht über den Rost")
	await act("flap")
	in_room("inner_earth_hydroponics")
	await act("lift_buttons")
	in_room("inner_earth_lift_hatch")
	await act("btn_hydroponics")
	check(Lift.at() == "hydroponics", "Kabine geholt")
	await act("hatch")
	check(Lift.alarm() == "hydroponics", "Warnton beim Öffnen")
	await act("cabin", "masking_tape")
	check(not Game.has("masking_tape") and is_equal_approx(Lift.weight(), 112.4), "Kreppband gewogen")
	await act("btn_kitchen")
	check(Lift.at() == "hydroponics", "Lift fährt nicht bei offener Luke")
	await act("cabin")
	check(Game.has("masking_tape"), "Kreppband zurück")
	await act("hatch")
	check(Lift.ready() and Lift.alarm() == "", "Luke zu, Lift bereit")
	await act("btn_canteen")
	await act("btn_kitchen")
	check(Lift.at() == "kitchen", "Kabine in der Küche")
	await act("back")
	in_room("inner_earth_hydroponics")
	await act("door")
	in_room("inner_earth_station")
	check(Game.flag("hydroponics_door_unlocked") and main.room.cur_area == "balcony", "durch die Tür auf den Balkon")
	# Wetterschleuse mit der Leiter
	if not Game.has("ladder"):
		Game.add_item("ladder")
	Game.choice_script = ["Tor 2"]
	await act("control_box")
	check(main.room.cur_area == "platform", "über die Treppe zum Steuerkasten")
	check(main.room.gate2_open() and not main.room.weather_alarm(), "normale Schleuse: Tor 2 auf, Tor 1 zu, kein Alarm")
	Game.choice_script = ["Tor 1"]
	await act("control_box")
	check(main.room.gate1() == "closed", "Tor 1 bleibt zu, solange Tor 2 offen ist")
	Game.choice_script = ["Tor 2"]
	await act("control_box")
	check(not main.room.gate2_open(), "Tor 2 wieder zu")
	Game.choice_script = ["Tor 1"]
	await act("control_box")
	check(main.room.gate1() == "open", "Tor 1 offen")
	await act("gate", "ladder")
	check(Game.flag("ladder_in_gate") and not Game.has("ladder"), "Leiter im Tor")
	Game.choice_script = ["Tor 1"]
	await act("control_box")
	check(main.room.gate1() == "on_ladder", "Tor 1 auf der Leiter")
	Game.choice_script = ["Tor 2"]
	await act("control_box")
	check(main.room.weather_alarm(), "Wetteralarm")
	await act("hydro_door")
	in_room("inner_earth_station")
	# im Dunst durch den Schacht über den Rost und zurück
	await act("grille")
	in_room("inner_earth_air_shaft")
	check(main.room.layers["haze"].visible, "Dunst im Schacht")
	await act("end_grille")
	in_room("inner_earth_machine_room")
	# Pigment abschleifen
	await act("emery_roll")
	await act("drawer")
	check(Game.has("emery_cloth") and Game.has("spare_brush"), "Schleifleinen und Ersatzbürste")
	await combine("spare_brush", "spatula")
	await act("door")
	check(Game.flag("machine_door_unlocked"), "Maschinenraumtür entriegelt")
	in_room("inner_earth_machine_room")
	await act("tag", "", "look")
	await act("middle_drive")
	in_room("inner_earth_slip_ring")
	await act("button")
	await act("drum", "emery_cloth")
	await act("holder", "spare_brush")
	await act("button")
	check(Game.flag("dust_lost") and not Game.flag("ring_brush"), "ohne Tütchen: Staub in der Wanne")
	await act("back")
	await act("drawer")
	await act("middle_drive")
	await act("holder", "spare_brush")
	await act("grating", "evidence_bag")
	await act("button")
	await act("grating")
	check(Game.has("evidence_bag_coal") and Game.has("evidence_bag"), "Kohlestaub im Tütchen, leere Tütchen bleiben")
	await act("back")
	in_room("inner_earth_machine_room")
	await act("cover")
	check(Game.flag("cover_closed"), "Gehäuse zu")
	await act("middle_drive")
	check(not Game.flag("cover_closed"), "Gehäuse wieder offen")
	await act("grille")
	in_room("inner_earth_air_shaft")
	await act("station_grille")
	in_room("inner_earth_station")
	check(main.room.cur_area == "gallery", "zurück auf der Galerie")
	Game.choice_script = ["Tor 2"]
	await act("control_box")
	check(not main.room.weather_alarm(), "Tor 2 zu, Alarm vorbei")
	Game.choice_script = ["Tor 1"]
	await act("control_box")
	await act("gate")
	check(Game.has("ladder") and not Game.flag("ladder_in_gate"), "Leiter wieder eingepackt")
	Game.choice_script = ["Tor 1"]
	await act("control_box")
	check(main.room.gate1() == "closed", "Tor 1 zu")
	await act("machine_door")
	in_room("inner_earth_machine_room")
	await act("door")
	in_room("inner_earth_station")
	# Küche: Öl hinausschmuggeln
	await act("kitchen_door")
	in_room("inner_earth_kitchen")
	await act("board", "", "look")
	await act("hatch")
	check(not Lift.is_open("kitchen") and Lift.alarm() == "", "Luke piept, Koch, wieder zu")
	Game.choice_script = ["Lift"]
	await act("cook")
	await act("walnut_oil")
	check(Game.has("walnut_oil"), "Walnussöl genommen")
	await act("door")
	in_room("inner_earth_kitchen")
	check(not Game.has("walnut_oil"), "Koch nimmt das Öl an der Tür ab")
	await act("door")
	in_room("inner_earth_station")
	await act("hydro_door")
	await act("lift_buttons")
	in_room("inner_earth_lift_hatch")
	await act("btn_kitchen")
	check(Lift.at() == "kitchen", "Kabine in der Küche")
	await act("hatch")
	await act("back")
	await act("door")
	await act("kitchen_door")
	in_room("inner_earth_kitchen")
	await act("walnut_oil")
	await act("hatch")
	check(Lift.is_open("kitchen") and Lift.alarm() == "hydroponics", "Küchenluke ohne Piepen offen")
	await act("buttons")
	await act("cabin", "walnut_oil")
	check("walnut_oil" in Lift.contents(), "Öl in der Kabine")
	await act("hatch")
	await act("door")
	in_room("inner_earth_station")
	await act("hydro_door")
	await act("lift_buttons")
	await act("hatch")
	await act("btn_hydroponics")
	await act("hatch")
	await act("cabin")
	check(Game.has("walnut_oil") and Game.flag("walnut_oil_out"), "Walnussöl in der Hydroponik")
	await act("hatch")
	await act("back")
	# Karte umarbeiten: Ruß als falsche Fährte, dann vier Schichten Kohlefarbe, nachwiegen
	in_room("inner_earth_hydroponics")
	await act("table", "id_card")
	check(Game.has("id_card"), "ohne Farbe kein Streichen")
	Game.add_item("spatula_soot")
	await act("table", "spatula_soot")
	await act("table", "id_card")
	check(Game.flag("card_drying") and not Game.has("id_card"), "Karte trocknet")
	await act("table")
	check(Game.flag("card_drying"), "noch feucht")
	await act("door")
	await act("hydro_door")
	await act("table")
	check(Game.has("id_card") and Game.flag("soot_failed"), "Ruß trocknet nicht")
	Game.remove_item("spatula_soot")
	await act("table", "evidence_bag_coal")
	for i in 4:
		await act("table", "id_card" if Game.has("id_card") else "id_card_black")
		await act("door")
		await act("hydro_door")
		await act("table")
	check(Game.has("id_card_black") and int(Game.value("card_layers", 0)) == 4, "vier Schichten")
	await act("lift_buttons")
	await act("hatch")
	await act("cabin", "id_card_black")
	check(is_equal_approx(Lift.weight(), Lift.BLACK_CARD), "Karte wiegt so viel wie die schwarze (%s)" % Lift.weight_text())
	await act("cabin")
	await act("hatch")
	await act("back")
	await act("door")
	in_room("inner_earth_station")
	await act("hydro_door")
	in_room("inner_earth_hydroponics")
	await act("door")
	in_room("inner_earth_station")
	await act("train_door")
	in_room("train_cabin")
