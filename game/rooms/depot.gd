extends Room
## Keller mit Depot: Licht mit Zeitschaltuhr, Regal D, Hollmanns Kiste mit doppeltem Boden.

const DARK := Color(0.22, 0.22, 0.27)
const LIT := Color(1, 1, 1)
const UV := Color(0.5, 0.38, 0.85)
const LIGHT_SECONDS := 60.0

var shade := CanvasModulate.new()
var light_on := false
var uv_on := false
var timer := Timer.new()


func _init() -> void:
	asset_dir = "depot"


func build() -> void:
	floor_poly = PackedVector2Array([
		Vector2(270, 562), Vector2(300, 456), Vector2(600, 440), Vector2(870, 484),
		Vector2(1440, 484), Vector2(1600, 518), Vector2(1900, 530), Vector2(1900, 576), Vector2(270, 576)])
	depth = [Vector2(440, 255), Vector2(576, 372)]
	tint = Color(0.62, 0.6, 0.56)
	entries = {
		"": [Vector2(1300, 540), "front", ""],
		"lobby": [Vector2(1660, 545), "left", ""],
	}
	add_child(shade)
	timer.one_shot = true
	timer.timeout.connect(_light_off)
	add_child(timer)

	hotspot("neon", "Neonröhre", Rect2(583, 26, 97, 61), Vector2(700, 470))
	hotspot("shelf_a", "Regal A", Rect2(0, 0, 287, 481), Vector2(320, 540), "left")
	hotspot("shelf_b", "Regal B", Rect2(297, 40, 317, 400), Vector2(450, 470))
	hotspot("shelf_c", "Regal C", Rect2(614, 120, 266, 280), Vector2(740, 470))
	hotspot("shelf_d", "Regal D", Rect2(880, 40, 575, 430), Vector2(1150, 500))
	hotspot("box", "Hollmanns Kiste", layer_rect("hollmann_box"), Vector2(1140, 548), "right")
	hotspot("switch", "Lichtschalter mit Zeitschaltuhr", Rect2(1563, 252, 55, 32), Vector2(1560, 515))
	hotspot("stairs", "Treppe nach oben", Rect2(1623, 143, 343, 390), Vector2(1665, 540), "right")


func lit() -> bool:
	return light_on or uv_on or Game.flag("switch_taped")


func refresh() -> void:
	layers["hollmann_box"].visible = Game.flag("box_found")
	if Game.flag("switch_taped") or light_on:
		shade.color = LIT
	elif uv_on:
		shade.color = UV
	else:
		shade.color = DARK


func is_active(hid: String) -> bool:
	if hid == "box":
		return Game.flag("box_found")
	return true


func display_name(hs: Dictionary) -> String:
	if hs["id"].begins_with("shelf_") and not lit():
		return "Regal"
	return hs["name"]


func _light_off() -> void:
	light_on = false
	refresh()


func look(hid: String) -> void:
	match hid:
		"neon":
			await say("Eine Neonröhre, die flackert. Typisch Keller.")
		"switch":
			await say("Ein Lichtschalter mit Zeitschaltuhr. Nach 60 Sekunden ist wieder Schluss.")
		"stairs":
			await say("Die Treppe hoch in die Lobby.")
		"box":
			await say("Hollmanns Kiste. D-0912.")
		_:
			if hid.begins_with("shelf_"):
				if lit():
					await say("Lange Regalreihen mit Lagerkisten, jede mit Inventarnummer.")
				else:
					await say("Regale voller Kisten. Man sieht kaum etwas.")
			else:
				await super(hid)


func use(hid: String) -> void:
	match hid:
		"stairs":
			await go("lobby")
		"switch":
			if Game.flag("switch_taped"):
				await say("Klebt fest. Das Licht bleibt an.")
			else:
				light_on = true
				timer.start(LIGHT_SECONDS)
				refresh()
				await narrate("[Klick. Die Neonröhre flackert und springt an.]")
		"box":
			await box()
		_:
			if hid.begins_with("shelf_"):
				await shelf(hid)
			else:
				await super(hid)


func use_item(hid: String, item: String) -> void:
	if item == "uv_lamp" and (hid.begins_with("shelf_") or hid in ["switch", "neon"]):
		uv_on = true
		refresh()
		await say("Die UV-Lampe als Taschenlampe. Die Etiketten fluoreszieren sogar.")
		return
	match [hid, item]:
		["switch", "masking_tape"]:
			Game.set_flag("switch_taped")
			timer.stop()
			refresh()
			await narrate("[Martin klebt den Schalter fest. Kreppband: „VORSICHT – FRISCH RESTAURIERT“.]")
			await say("Die Zeitschaltuhr kann mich mal.")
		["box", "caliper"]:
			await measure()
		["box", "spatula"], ["box", "spatula_soot"]:
			await open_bottom()
		["box", "masking_tape"]:
			await say("Die Kiste geht nicht noch einmal ins Regal. Noch nicht.")
		_:
			await super(hid, item)


## Kapitel 5a: Regal D, Fach 09, Platz 12 – nur bei Licht lesbar.
func shelf(hid: String) -> void:
	if not lit():
		if Game.flag("light_was_on"):
			await say("Wieder dunkel. Diese Zeitschaltuhr.")
		else:
			await say("Zu dunkel. Die Schilder kann ich so nicht lesen.")
		return
	Game.set_flag("light_was_on")
	if not Game.has("index_card_revealed"):
		await say("Hunderte Kisten. Ohne Inventarnummer suche ich hier bis zur Inventur.")
	elif hid != "shelf_d":
		await say("Hier steht nichts mit D.")
	elif Game.flag("box_found"):
		await say("Hollmanns Platz ist leer. Die Kiste steht vor mir.")
	else:
		Game.set_flag("box_found")
		refresh()
		await narrate("[Regal D, Fach 09, Platz 12. Martin zieht eine schwere Kiste heraus. Etikett: „D-0912 – Hollmann, Nachlass“.]")


## Kapitel 5b: Der doppelte Boden.
func box() -> void:
	if not Game.flag("box_opened"):
		Game.set_flag("box_opened")
		await narrate("[In der Kiste liegt nur altes Werkzeug.]")
		await say("Nichts. … Aber die Kiste ist zu schwer für das bisschen Werkzeug.", "martin/box_too_heavy")
	elif Game.flag("box_emptied"):
		await say("Nur noch altes Werkzeug.")
	elif Game.flag("false_bottom"):
		await say("Den Boden hebe ich mit etwas Flachem an der Kante an.")
	else:
		await say("Zu schwer für das bisschen Werkzeug. Wie tief ist sie eigentlich?")


func measure() -> void:
	if not Game.flag("box_opened"):
		await box()
		return
	await narrate("[Außen: 18 Zentimeter Tiefe. Innen, mit dem Tiefenmaß: 14 Zentimeter.]")
	Game.set_flag("false_bottom")
	await say("Vier Zentimeter fehlen. Da ist ein doppelter Boden.", "martin/false_bottom")


func open_bottom() -> void:
	if Game.flag("box_emptied"):
		await say("Das Versteck ist leer.")
	elif not Game.flag("false_bottom"):
		await say("Wozu? Da ist nur Werkzeug drin.")
	else:
		Game.set_flag("box_emptied")
		await narrate("[Martin hebt den Boden mit dem Spatel an der Kante an. Darunter ein Versteck.]")
		for item in ["id_card", "notebook", "incense_cone", "screw_bit"]:
			Game.add_item(item)
			Game.set_flag("took_" + item)
		await say("Hollmanns Ausweis. Ein Notizbuch. Ein Räucherkegel. Und ein merkwürdiger Bit.")
		await say("Den Schlüssel muss ich Frau Ackermann zurückbringen. Sonst lässt sie mich nicht gehen.")
