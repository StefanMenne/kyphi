extends Room
## Innenerde: Nahansicht der Liftluke in der Hydroponik. Martin ist nicht zu sehen. Luke öffnen und schließen,
## den Lift mit den drei Knöpfen schicken, Dinge in die Kabine legen und auf der Waage wiegen. Die Anzeige unter
## der Kabine (Zehntelgramm) setzt das Spiel als Schrift ins Bild.
##
## Bilder: Hintergrund = leerer Schacht hinter dem Fenster, Ebene „cabin“ = Kabine hinter dem Fenster, dazu die
## ganzen Bilder open_cabin und open_shaft (Luke offen; die Tür schwenkt über fast das ganze Bild).

const HERE := "hydroponics"
## Anzeigeleiste unter der Kabine (Bildpixel), in beiden Ansichten an derselben Stelle
const DISPLAY := Rect2(368, 558, 290, 29)
const BUTTONS := {"btn_canteen": "canteen", "btn_hydroponics": "hydroponics", "btn_kitchen": "kitchen"}

var open_cabin: Sprite2D
var open_shaft: Sprite2D
var display := Label.new()


func _init() -> void:
	asset_dir = "inner_earth_lift_hatch"
	show_player = false


func build() -> void:
	var states: Dictionary = Game.catalog["scenes"][asset_dir]["states"]
	open_cabin = add_sprite(load("res://assets/" + states["open_cabin"]), Vector2.ZERO)
	open_shaft = add_sprite(load("res://assets/" + states["open_shaft"]), Vector2.ZERO)
	var ls := LabelSettings.new()
	ls.font_size = 22
	ls.font_color = Color(0.45, 1.0, 0.55)
	display.label_settings = ls
	display.position = DISPLAY.position
	display.size = DISPLAY.size
	display.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(display)
	hotspot("back", "Zurück zur Hydroponik", "none")
	hotspot("hatch", "Liftluke")
	hotspot("cabin", "Kabine")
	hotspot("lamp", "Kontrolllampe")
	hotspot("btn_canteen", "Knopf mit Besteck")
	hotspot("btn_hydroponics", "Knopf mit Blatt")
	hotspot("btn_kitchen", "Knopf mit Topf")
	set_verbs({"back": "go"})


func cabin_here() -> bool:
	return Lift.at() == HERE


func refresh() -> void:
	var open := Lift.is_open(HERE)
	layers["cabin"].visible = cabin_here() and not open
	open_cabin.visible = open and cabin_here()
	open_shaft.visible = open and not cabin_here()
	display.visible = cabin_here()
	display.text = Lift.weight_text()


func is_active(hid: String) -> bool:
	if hid == "cabin":
		return cabin_here() and Lift.is_open(HERE)
	return true


func display_name(hs: Dictionary) -> String:
	if hs["id"] == "hatch" and Lift.is_open(HERE):
		return "Offene Liftluke"
	return hs["name"]


func look(hid: String) -> void:
	match hid:
		"hatch":
			if Lift.is_open(HERE):
				if cabin_here():
					await say("Die Luke steht offen. Dahinter die Kabine.")
				else:
					await say("Die Luke steht offen. Dahinter nur der Schacht: Führungsschienen, ein Seil, Dunkelheit.")
			elif cabin_here():
				await say("Hinter dem Fenster steht die Kabine. Die Waage zeigt %s." % Lift.weight_text())
			else:
				await say("Hinter dem Fenster der leere Schacht. Die Kabine ist woanders.")
		"cabin":
			await look_cabin()
		"lamp":
			if Lift.alarm() == HERE:
				await say("Die Lampe blinkt. Dazu dieses leise Summen.")
			else:
				await say("Eine kleine Kontrolllampe.")
		"btn_canteen":
			await say("Besteck. Das ist die Kantine, oben.")
		"btn_hydroponics":
			await say("Ein Blatt. Das ist hier.")
		"btn_kitchen":
			await say("Ein Topf. Die Küche, unten.")
		"back":
			await say("Zurück in die Hydroponik.")
		_:
			await super(hid)


func look_cabin() -> void:
	var c := Lift.contents()
	if c.is_empty():
		await say("Eine leere Edelstahlkabine. Der Boden ist eine Waage: %s." % Lift.weight_text())
	else:
		var names := c.map(func(i): return Game.item_name(i))
		await say("In der Kabine: %s. Die Waage zeigt %s." % [", ".join(names), Lift.weight_text()])


func use(hid: String) -> void:
	match hid:
		"back":
			await go("inner_earth_hydroponics")
		"hatch":
			await toggle_hatch()
		"cabin":
			await take_contents()
		"lamp":
			await refuse("Eine Lampe zum Anschauen, nicht zum Drücken.")
		_:
			if hid in BUTTONS:
				await press(BUTTONS[hid])
			else:
				await super(hid)


func use_item(hid: String, item: String) -> void:
	if hid in ["cabin", "hatch"] and Lift.is_open(HERE) and cabin_here():
		await put_item(item)
		return
	match hid:
		"hatch":
			await refuse("Durch das Glas geht nichts. Erst die Luke auf.")
		_:
			await super(hid, item)


func toggle_hatch() -> void:
	await Game.main.flush_gesture()
	if Lift.is_open(HERE):
		Lift.close_hatch(HERE)
		refresh()
		await narrate("[Klack.]")
		return
	var warn := Lift.open_hatch(HERE)
	refresh()
	if warn:
		await narrate("[Ein leiser, anhaltender Warnton. Die Kontrolllampe blinkt.]")
		if not Game.flag("lift_alarm_heard"):
			Game.set_flag("lift_alarm_heard")
			await say("Hier unten hört das keiner. Hoffe ich.")


func press(target: String) -> void:
	await Game.main.flush_gesture()
	match Lift.send(target):
		"locked":
			await refuse("Nichts. Solange irgendwo eine Luke offen ist, fährt er nicht.")
		"here":
			if target == HERE:
				await refuse("Die Kabine ist schon hier.")
			else:
				await refuse("Er steht schon da. Nichts passiert.")
		"passed":
			refresh()
			await narrate("[Surren im Schacht. Die Kabine gleitet am Fenster vorbei.]")
		"moved":
			if target == HERE:
				refresh()
				await narrate("[Surren im Schacht. Die Kabine hält hinter dem Fenster.]")
			else:
				refresh()
				await narrate("[Die Kabine fährt davon.]")


func put_item(item: String) -> void:
	if item in Lift.TOO_BIG:
		await refuse("Passt nicht in die Kabine.")
		return
	await Game.main.flush_gesture()
	Game.remove_item(item)
	Lift.put(item)
	refresh()
	await say("Die Waage zeigt %s." % Lift.weight_text())


func take_contents() -> void:
	var c := Lift.clear()
	if c.is_empty():
		await refuse("Die Kabine ist leer.")
		return
	await Game.main.flush_gesture()
	for item in c:
		Game.add_item(item)
	refresh()
