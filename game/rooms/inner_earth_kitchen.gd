extends Room
## Innenerde: Küche (concept/inner_earth.md, „Küche“ und „Öl hinausschmuggeln“). Links die Tür zum Bahnhof, die
## Liftluke mit den drei Knöpfen und der Anzeige, der Kühlschrank, die Tafel mit dem Gericht des Tages, das Bord mit
## den Ölflaschen (Walnussöl als eigene Ebene), rechts Herd und Haube, davor der Koch.
##
## Regeln: Mit dem Walnussöl lässt der Koch Martin nicht hinaus. Die Liftluke öffnet Martin nur ohne Warnton, also
## wenn irgendwo anders schon eine Luke offen ist; dann tun die Knöpfe nichts, aber in die Kabine kann er etwas
## legen. Sind alle anderen Luken zu, piept es, der Koch dreht sich um, und Martin macht die Luke schnell wieder zu.

const STATION := preload("res://game/rooms/inner_earth_station.gd")
const HERE := "kitchen"
## Gericht des Tages (vorläufig, siehe concept/inner_earth.md „Offen“)
const DISH := "Linseneintopf\nmit Würstchen"

var cook: Npc
var display := Label.new()
var board := Label.new()


func _init() -> void:
	asset_dir = "inner_earth_kitchen"


func build() -> void:
	tint = Color(1.0, 0.98, 0.95)
	cook = add_npc("cook")
	_label(display, Rect2(372, 262, 147, 74), 15, Color(1.0, 0.45, 0.3))
	_label(board, Rect2(812, 275, 268, 180), 30, Color(0.93, 0.95, 0.9))
	board.text = DISH
	hotspot("door", "Tür zum Bahnhof", "none")
	hotspot("cook", "Koch", "none")
	hotspot("hatch", "Liftluke")
	hotspot("cabin", "Kabine")
	hotspot("buttons", "Lift-Knöpfe")
	hotspot("display", "Anzeige")
	hotspot("fridge", "Kühlschrank")
	hotspot("board", "Tafel")
	hotspot("shelf", "Bord mit Ölflaschen")
	hotspot("walnut_oil", "Braune Flasche")
	hotspot("counter", "Arbeitsfläche")
	hotspot("range", "Herd")
	hotspot("pots", "Töpfe")
	hotspot("hood", "Abzugshaube")
	hotspot("duct", "Lüftungskanal")
	set_verbs({"door": "go", "cook": "talk", "walnut_oil": "take"})


func _label(l: Label, r: Rect2, size: int, color: Color) -> void:
	var ls := LabelSettings.new()
	ls.font_size = size
	ls.font_color = color
	l.label_settings = ls
	l.position = r.position
	l.size = r.size
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(l)


func refresh() -> void:
	layers["hatch_open"].visible = Lift.is_open(HERE)
	layers["haze"].visible = STATION.weather_alarm()
	layers["walnut_oil"].visible = not Game.has("walnut_oil") and "walnut_oil" not in Lift.contents() \
		and not Game.flag("walnut_oil_out")
	display.text = "" if Lift.ready() else "Nicht\nbetriebsbereit"


func is_active(hid: String) -> bool:
	match hid:
		"walnut_oil":
			return layers["walnut_oil"].visible
		"cabin":
			return Lift.is_open(HERE)
	return true


func on_enter(_from: String) -> void:
	if not Game.flag("kitchen_seen"):
		Game.set_flag("kitchen_seen")
		await Game.say("cook", "Tür zu! Hier wird gekocht, nicht gelüftet.")
		await say("Ich wollte nur … gucken.")
		await Game.say("cook", "Gucken kostet nix. Anfassen schon.")
	if not Lift.ready() and not Game.flag("cook_lift_rant"):
		Game.set_flag("cook_lift_rant")
		await Game.say("cook", "Und das Ding spinnt schon wieder. Sobald irgendwo eine Klappe offen ist, geht gar nichts mehr.")


func look(hid: String) -> void:
	match hid:
		"door":
			await say("Die Tür zum Bahnhof.")
		"cook":
			await say("Der Koch. Schöpfkelle, Geschirrtuch, schlechte Laune. Er hat nur Augen für seine Töpfe. Und für die Tür.")
		"hatch":
			if Lift.is_open(HERE):
				await say("Die Liftluke steht offen.")
			else:
				await say("Die Liftluke, wie in der Hydroponik. Hinten am anderen Ende der Küche, weit weg vom Herd.")
		"cabin":
			await look_cabin()
		"buttons":
			await say("Dieselben drei Knöpfe wie in der Hydroponik: Besteck, Blatt, Topf.")
		"display":
			if Lift.ready():
				await say("Eine Anzeige. Im Moment dunkel.")
			else:
				await say("„Nicht betriebsbereit“.")
		"fridge":
			await say("Ein Kühlschrank, raumhoch. Ich wette, da drin ist mehr Ordnung als in meinem.")
		"board":
			await say("Heute: %s." % DISH.replace("\n", " "))
			Game.set_flag("dish_known")
		"shelf":
			await say("Speiseöle. Raps, Sonnenblume, Olive. Und eine braune Flasche: Walnussöl.")
		"walnut_oil":
			await say("Walnussöl. Das trocknet, anders als Olivenöl. Damit binden Maler seit Jahrhunderten Pigmente.")
		"counter":
			await say("Edelstahl, blitzblank.")
		"range", "pots":
			await say("Es blubbert und dampft. Riecht gar nicht schlecht.")
		"hood", "duct":
			if STATION.weather_alarm():
				await say("Die Haube zieht nicht mehr. Der Dampf steht unter der Decke.")
			else:
				await say("Die Haube saugt den Dampf in den gelben Kanal. Unten ein offener Gitterrost.")
		_:
			await super(hid)


func look_cabin() -> void:
	if Lift.at() != HERE:
		await say("Hinter der Luke nur der leere Schacht.")
		return
	var c := Lift.contents()
	if c.is_empty():
		await say("Die Kabine ist leer.")
	else:
		await say("In der Kabine: %s." % ", ".join(c.map(func(i): return Game.item_name(i))))


func use(hid: String) -> void:
	match hid:
		"door":
			await use_door()
		"cook":
			await talk_cook()
		"hatch":
			await toggle_hatch()
		"cabin":
			await take_contents()
		"buttons":
			await press_buttons()
		"walnut_oil":
			await take("walnut_oil", "Die braune Flasche nehme ich mit.")
		"fridge":
			await refuse("Der Koch sieht die Tür vom Herd aus. Und den Kühlschrank auch.")
		"range", "pots", "hood":
			await refuse("Da stehe ich dem Koch direkt auf den Füßen.")
		"display", "board", "counter", "shelf", "duct":
			await refuse("Das bringt mir nichts.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match hid:
		"cabin", "hatch":
			if Lift.is_open(HERE) and Lift.at() == HERE:
				await put_item(item)
			elif hid == "hatch":
				await refuse("Erst muss die Luke auf.")
			else:
				await refuse("Da ist keine Kabine.")
		"cook":
			if item == "walnut_oil":
				await Game.say("cook", "Das ist meins. Stell es zurück.")
			else:
				await Game.say("cook", "Was soll ich damit? Ich koche.")
		_:
			await super(hid, item)


func use_door() -> void:
	if STATION.weather_alarm():
		await refuse("Gesperrt. Die Leuchte über der Tür ist rot.")
		return
	if Game.has("walnut_oil"):
		await Game.main.flush_gesture()
		await Game.say("cook", "Halt! Die Flasche bleibt hier. Das ist Küchenöl, kein Souvenir.")
		Game.remove_item("walnut_oil")
		refresh()
		await say("Schon gut. Zurück aufs Bord.")
		if not Game.flag("oil_blocked"):
			Game.set_flag("oil_blocked")
			await say("Durch die Tür bekomme ich sie nicht. Er sieht die Tür vom Herd aus.")
		return
	await go("inner_earth_station")


func toggle_hatch() -> void:
	await Game.main.flush_gesture()
	if Lift.is_open(HERE):
		Lift.close_hatch(HERE)
		refresh()
		await narrate("[Klack.]")
		var r := Lift.run_order()
		if not r.is_empty():
			refresh()
			await narrate("[Der Lift kommt mit Tablett und Karte. Der Koch wirft einen Blick auf die Karte und auf die Waage, kocht und schickt ihn wieder hinauf.]")
		return
	var warn := Lift.open_hatch(HERE)
	refresh()
	if warn:
		await narrate("[Ein schrilles Piepen.]")
		await Game.say("cook", "Hey! Finger weg vom Lift!")
		Lift.close_hatch(HERE)
		refresh()
		await say("Bin schon weg.")
		if not Game.flag("kitchen_hatch_hint"):
			Game.set_flag("kitchen_hatch_hint")
			await say("Solange der Lift betriebsbereit ist, piept die Luke. Und er hört es.")
	elif not Game.flag("kitchen_hatch_silent"):
		Game.set_flag("kitchen_hatch_silent")
		await say("Kein Piepen. Weil oben schon eine Luke offen ist.")


func press_buttons() -> void:
	await Game.main.flush_gesture()
	if not Lift.ready():
		await refuse("Nichts. „Nicht betriebsbereit“.")
		return
	await Game.say("cook", "Finger weg vom Lift! Den bediene ich.")


func put_item(item: String) -> void:
	if item in Lift.TOO_BIG:
		await refuse("Passt nicht in die Kabine.")
		return
	await Game.main.flush_gesture()
	Game.remove_item(item)
	Lift.put(item)
	refresh()
	if item == "walnut_oil":
		await say("Das Öl reist allein. Ich hole es oben ab.")


func take_contents() -> void:
	if Lift.at() != HERE:
		await refuse("Da ist keine Kabine.")
		return
	var c := Lift.clear()
	if c.is_empty():
		await refuse("Die Kabine ist leer.")
		return
	await Game.main.flush_gesture()
	for item in c:
		Game.add_item(item)
	refresh()


func talk_cook() -> void:
	await say("Was gibt es heute?")
	await Game.say("cook", "Steht an der Tafel. Lesen kann jeder.")
	Game.set_flag("dish_known")
	var c := await Game.choose(["Was ist mit dem Lift?", "Darf ich mir etwas Öl leihen?", "Schon gut."])
	match c:
		0:
			await Game.say("cook", "Der Lift spinnt, sobald irgendwo eine Klappe offen ist. Dann steht alles, und ich darf rennen.")
		1:
			await Game.say("cook", "Nein. Und wenn du's versuchst, merk ich's.")
