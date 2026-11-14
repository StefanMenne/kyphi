extends Node
## Mehrere Laufflächen mit Verbindungsstrecken (Room.areas, Room.links, Room.route): Bahnsteig, Balkon und Galerie
## wie im Bahnhof der Innenerde, verbunden durch zwei Treppen mit Podest. Prüft die Wegsuche, die Figurhöhe auf
## Flächen und Strecken, Laufen in Echtzeit über beide Treppen und einen Zielwechsel mitten auf der Treppe.
## godot --headless --path . res://tests/walk_areas.tscn

const LAYOUT := {
	"areas": {
		"platform": {"floor": [[0, 610], [2688, 610], [2688, 768], [0, 768]], "depth": [[610, 150], [768, 190]]},
		"balcony": {"floor": [[1180, 400], [1700, 400], [1700, 420], [1180, 420]], "depth": [[400, 150], [420, 150]]},
		"gallery": {"floor": [[1150, 200], [2000, 200], [2000, 220], [1150, 220]], "depth": [[200, 150], [220, 150]]},
	},
	"links": [
		{"a": "platform", "b": "balcony", "points": [[1200, 612], [1330, 510], [1200, 412]]},
		{"a": "balcony", "b": "gallery", "points": [[1200, 408], [1330, 310], [1200, 212]],
			"heights": [150, 150, 150]},
	],
	"entries": {"": {"pos": [500, 700], "face": "right", "door": ""}},
	"hotspots": {},
}

var failed := false


class TestRoom extends Room:
	func _init() -> void:
		asset_dir = "inner_earth_station"

	func load_layout() -> void:
		apply_layout(LAYOUT)


func check(cond: bool, what: String) -> void:
	if not cond:
		failed = true
		push_error("Prüfung fehlgeschlagen: " + what)
		print("!! FEHLER: " + what)


func _ready() -> void:
	get_tree().create_timer(300.0).timeout.connect(func():
		print("!! FEHLER: hängt")
		get_tree().quit(1))
	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main.ui.hide_menu()
	var room := TestRoom.new()
	room.id = "walk_areas_test"
	main.world.add_child(room)
	room.setup()
	var p: Node2D = main.player
	if p.get_parent():
		p.get_parent().remove_child(p)
	room.add_child(p)
	p.room = room
	p.visible = true
	p.position = Vector2(500, 700)
	room.set_location(p.position)
	p.update_scale()

	# Wegsuche
	check(room.area_of(Vector2(1500, 210)) == "gallery", "Punkt auf der Galerie")
	check(room.area_of(Vector2(1500, 300)) in ["balcony", "gallery"], "Punkt neben den Flächen: nächste Fläche")
	var legs: Array = room.route(p.position, Vector2(1600, 210))
	var kinds := legs.map(func(l): return l["area"] if l["link"] < 0 else "link%d" % l["link"])
	print("Weg Bahnsteig -> Galerie: ", kinds)
	check(kinds == ["platform", "link0", "balcony", "link1", "gallery"], "Weg über beide Treppen: %s" % [kinds])
	check(room.route(p.position, Vector2(2000, 740)).size() == 1, "auf derselben Fläche gerade")

	# Höhen
	check(is_equal_approx(room.area_height("platform", 768), 190.0), "Bahnsteig vorn 190")
	room.cur_link = 0
	check(is_equal_approx(room.link_height(0, Vector2(1330, 510)), 150.0) or room.link_height(0, Vector2(1330, 510)) < 151.0, "Podest 150")
	room.set_location(p.position)

	# sofort (Game.fast): Ziel auf der Galerie
	Game.fast = true
	var ok: bool = await p.walk_to(Vector2(1600, 210))
	check(ok and p.position.distance_to(Vector2(1600, 210)) < 1.0 and room.cur_area == "gallery", "sofort auf der Galerie")
	ok = await p.walk_to(Vector2(500, 700))
	check(ok and room.cur_area == "platform", "sofort zurück auf dem Bahnsteig")
	Game.fast = false

	# Vergleich: gerade Strecke auf dem Bahnsteig, gleich lang wie der Weg hinauf (etwa 2160 px)
	var t_flat := Time.get_ticks_msec()
	await p.walk_to(Vector2(2660, 700))
	await p.walk_to(Vector2(500, 700))
	print("gerade 2 x 2160 px: %.1f s" % ((Time.get_ticks_msec() - t_flat) / 1000.0))
	# Echtzeit: hinauf auf die Galerie, Höhe beobachten
	var hs := {"min": INF, "max": 0.0, "links": {}}
	var watching := [true]
	var watch := func() -> void:
		while watching[0]:
			var h: float = room.height_for(p.position)
			hs["min"] = minf(hs["min"], h)
			hs["max"] = maxf(hs["max"], h)
			if room.cur_link >= 0:
				hs["links"][room.cur_link] = true
			await get_tree().process_frame
	watch.call()
	var t0 := Time.get_ticks_msec()
	ok = await p.walk_to(Vector2(1600, 210))
	watching[0] = false
	print("hinauf: %s, %.1f s, Höhe %d bis %d, Strecken %s" % [ok, (Time.get_ticks_msec() - t0) / 1000.0,
		hs["min"], hs["max"], hs["links"].keys()])
	check(ok and p.position.distance_to(Vector2(1600, 210)) < 1.0, "auf der Galerie angekommen (%s)" % p.position)
	check(room.cur_area == "gallery" and room.cur_link == -1, "Fläche Galerie")
	check(hs["links"].has(0) and hs["links"].has(1), "über beide Treppen")
	check(absf(p.scale.y * 1.0 - room.height_for(p.position) / p._body) < 0.01, "Größe passt zur Galerie")

	# Zielwechsel auf der Treppe: hinunter laufen, unterwegs (auf einer Strecke) zurück zum Balkon
	var res := {}
	var go := func() -> void: res["ok"] = await p.walk_to(Vector2(400, 740))
	go.call()
	while room.cur_link < 0 and not res.has("ok"):
		await get_tree().process_frame
	check(room.cur_link >= 0, "unterwegs auf einer Treppe")
	var link_then := room.cur_link
	ok = await p.walk_to(Vector2(1600, 410))
	while not res.has("ok"):
		await get_tree().process_frame
	print("Zielwechsel auf Strecke %d: alter Weg %s, neuer Weg %s, Fläche %s" % [link_then, res["ok"], ok, room.cur_area])
	check(res["ok"] == false, "alter Weg abgelöst")
	check(ok and p.position.distance_to(Vector2(1600, 410)) < 1.0 and room.cur_area == "balcony", "auf dem Balkon angekommen")

	# stop() mitten auf der Treppe, dann weiter zum Bahnsteig
	go = func() -> void: res["ok2"] = await p.walk_to(Vector2(400, 740))
	go.call()
	while room.cur_link < 0:
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	p.stop()
	while not res.has("ok2"):
		await get_tree().process_frame
	check(res["ok2"] == false and room.cur_link >= 0, "angehalten auf der Treppe")
	ok = await p.walk_to(Vector2(400, 740))
	check(ok and room.cur_area == "platform" and p.position.distance_to(Vector2(400, 740)) < 1.0, "vom Halt auf der Treppe zum Bahnsteig")

	print("\nERGEBNIS: ", "FEHLER" if failed else "OK")
	get_tree().quit(1 if failed else 0)
