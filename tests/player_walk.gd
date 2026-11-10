extends Node
## Neuer Martin (Player) in Echtzeit: Laufen in alle Richtungen, Zielwechsel unterwegs (Drehen im Laufen),
## stop() mitten im Weg, Drehen im Stand zu allen Blickrichtungen. Prüft, dass er ankommt und nichts hängt.
## godot --headless --path . res://tests/player_walk.tscn [-- raum [figurensatz]]

var failed := false


func _ready() -> void:
	get_tree().create_timer(400.0).timeout.connect(func():
		print("!! FEHLER: hängt")
		get_tree().quit(1))
	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main.ui.hide_menu()
	var args := OS.get_cmdline_user_args()
	main._load_room(args[0] if args.size() > 0 else "lobby", "")
	if args.size() > 1:
		Player.use_set(args[1], false)
	var old: Node2D = main.player
	var p := Player.new()
	p.room = main.room
	p.position = old.position
	main.room.remove_child(old)
	old.queue_free()
	main.player = p
	main.room.add_child(p)
	p.face("right", true)
	p.update_scale()
	var start := p.position
	var h: float = main.room.height_at(start.y)
	print("Start ", start, " Körperhöhe ", h)
	# Wege: rechts, links, nach hinten rechts, hinten, nach vorn links
	for v in [Vector2(1.2, 0), Vector2(-1.2, 0), Vector2(0.8, -0.5), Vector2(0, -0.6), Vector2(-0.6, 0.9)]:
		var goal: Vector2 = main.room.clamp_to_floor(p.position + v * h)
		var t0 := Time.get_ticks_msec()
		var ok: bool = await p.walk_to(goal)
		check(ok and p.position.distance_to(goal) < 1.0, "Weg %s angekommen (%s statt %s)" % [v, p.position, goal])
		print("Weg %s: %s, Richtung %s, %.1f s" % [v, "ok" if ok else "abgebrochen", p.facing, (Time.get_ticks_msec() - t0) / 1000.0])
	# in die Tiefe: zum hintersten Punkt des Bodens (schräg und gerade nach hinten), dann zurück nach vorn
	var poly: PackedVector2Array = main.room.floor_poly
	if not poly.is_empty():
		var top := poly[0]
		var bottom := poly[0]
		for q in poly:
			top = q if q.y < top.y else top
			bottom = q if q.y > bottom.y else bottom
		for goal in [Vector2(p.position.x, top.y + 5), Vector2(p.position.x + 0.8 * h, (top.y + bottom.y) / 2), Vector2(p.position.x - 0.6 * h, bottom.y - 5)]:
			goal = main.room.clamp_to_floor(goal)
			var t1 := Time.get_ticks_msec()
			var okd: bool = await p.walk_to(goal)
			check(okd and p.position.distance_to(goal) < 1.0, "Tiefe %s angekommen" % goal)
			print("Tiefe nach %s: Richtung %s, %.1f s" % [goal, p.facing, (Time.get_ticks_msec() - t1) / 1000.0])
	# Zielwechsel unterwegs: erst nach rechts, nach 1,5 s nach hinten links
	var g1: Vector2 = main.room.clamp_to_floor(p.position + Vector2(1.5, 0) * h)
	var g2: Vector2 = main.room.clamp_to_floor(p.position + Vector2(-0.8, -0.6) * h)
	var first: bool = false
	var done1 := func() -> void: first = await p.walk_to(g1)
	done1.call()
	await get_tree().create_timer(1.5).timeout
	var facing_before := p.facing
	var ok2: bool = await p.walk_to(g2)
	check(not first, "erster Weg gilt als abgelöst")
	check(ok2 and p.position.distance_to(g2) < 1.0, "zweites Ziel erreicht")
	print("Zielwechsel: vorher %s, jetzt %s, ok %s" % [facing_before, p.facing, ok2])
	# stop() mitten im Weg, danach neuer Weg
	var g3: Vector2 = main.room.clamp_to_floor(p.position + Vector2(1.5, 0.3) * h)
	p.walk_to(g3)
	await get_tree().create_timer(1.2).timeout
	p.stop()
	await get_tree().create_timer(0.5).timeout
	var ok3: bool = await p.walk_to(g3)
	check(ok3 and p.position.distance_to(g3) < 1.0, "nach stop() erneut gelaufen")
	# Drehen im Stand
	for d in ["back", "left", "right", "back", "right", "left"]:
		await p.face(d)
		check(p.facing == {"left": "fl", "right": "fr", "back": "b"}[d], "Blick %s" % d)
	# Sprechen: vorn Sprech-Schleife, hinten weiter Atmen
	for d in ["right", "left", "back"]:
		await p.face(d)
		p.talking = true
		await get_tree().create_timer(0.6).timeout
		var tex: String = p._sprite.texture.resource_path.get_file()
		p.talking = false
		await get_tree().create_timer(0.2).timeout
		var after: String = p._sprite.texture.resource_path.get_file()
		check(tex.begins_with("talk_") == (d != "back"), "Sprechen Blick %s: %s" % [d, tex])
		check(after.begins_with("idle_"), "nach dem Sprechen Atmen (%s)" % after)
		print("Sprechen Blick %s: %s, danach %s" % [d, tex, after])
	# Gesten in drei Höhen, vorn links (gespiegelt) und hinten
	for d in ["left", "back"]:
		await p.face(d)
		for kind in ["high", "hip", "low"]:
			var seen := {}
			var watch := func() -> void:
				while p._busy:
					seen[p._sprite.texture.resource_path.get_file().left(-7)] = p._sprite.flip_h
					await get_tree().process_frame
			p.gesture(kind)
			await get_tree().process_frame
			await watch.call()
			var want := "use_%s_%s" % [kind, "b" if d == "back" else "fr"]
			check(seen.has(want), "Geste %s Blick %s: %s" % [kind, d, seen.keys()])
			check(not seen.has(want) or seen[want] == (d == "left"), "Geste %s gespiegelt" % kind)
			print("Geste %s, Blick %s: %s" % [kind, d, seen.keys()])
	# Kälteanzug: Laufen ohne Anlaufen/Anhalten, Drehen sofort, Gesten oben hinten und unten vorn
	p.set_suit(true)
	for v in [Vector2(1.0, 0), Vector2(-1.0, 0.3), Vector2(0.3, -0.5)]:
		var goal: Vector2 = main.room.clamp_to_floor(p.position + v * h)
		var names := {}
		var track := func() -> void:
			while p._moving:
				names[_tag(p._sprite.texture.resource_path)] = true
				await get_tree().process_frame
		var res := {}
		var walk := func() -> void: res["ok"] = await p.walk_to(goal)
		walk.call()
		await get_tree().process_frame
		await track.call()
		while not res.has("ok"):
			await get_tree().process_frame
		var okw: bool = res["ok"]
		var bad := names.keys().filter(func(n): return not n.begins_with("suit_walk_"))
		check(okw and p.position.distance_to(goal) < 1.0 and bad.is_empty(), "Anzug Weg %s: %s" % [v, names.keys()])
		print("Anzug Weg %s: %s, Richtung %s" % [v, names.keys(), p.facing])
	for spec in [["back", "high", "suit_use_high_b"], ["right", "low", "suit_use_low_fr"]]:
		await p.face(spec[0])
		var seen := {}
		var watch := func() -> void:
			while p._busy:
				seen[_tag(p._sprite.texture.resource_path)] = true
				await get_tree().process_frame
		p.gesture(spec[1])
		await get_tree().process_frame
		await watch.call()
		check(seen.has(spec[2]), "Anzug Geste %s: %s" % [spec[1], seen.keys()])
		print("Anzug Geste %s: %s" % [spec[1], seen.keys()])
	p.set_suit(false)
	print("\nERGEBNIS: ", "FEHLER" if failed else "OK")
	get_tree().quit(1 if failed else 0)


## Animationsname eines Bildes; Bilder aus einem Anzug-Satz (Verzeichnis *_suit) mit Vorsatz "suit_"
func _tag(path: String) -> String:
	return ("suit_" if path.get_base_dir().ends_with("_suit") else "") + path.get_file().left(-7)


func check(cond: bool, what: String) -> void:
	if not cond:
		failed = true
		print("!! FEHLER: ", what)
