extends Room
## Keller mit Depot: Lichttaster, Regal D, Hollmanns Kiste mit doppeltem Boden.
## Das Licht brennt nur, solange der Taster gedrückt ist: Geht Martin weg, ist es dunkel. Kreppband hält ihn fest.

const DARK := Color(0.22, 0.22, 0.27)
const LIT := Color(1, 1, 1)
## so weit darf sich Martin vom Taster entfernen (Raumpixel), bevor er ihn loslässt
const HOLD_DIST := 12.0

var shade := CanvasModulate.new()
## Martin drückt gerade den Taster
var light_on := false
var _hold_pos := Vector2.ZERO


func _init() -> void:
	asset_dir = "depot"


func build() -> void:
	tint = Color(0.62, 0.6, 0.56)
	add_child(shade)

	hotspot("neon", "Neonröhre")
	hotspot("shelf_a", "Regal A", "left")
	hotspot("shelf_b", "Regal B")
	hotspot("shelf_c", "Regal C")
	hotspot("shelf_d", "Regal D")
	hotspot("box", "Hollmanns Kiste", "right")
	hotspot("switch", "Lichttaster")
	hotspot("stairs", "Treppe nach oben", "right", "none")
	set_verbs({"stairs": "go"})


func lit() -> bool:
	return light_on or Game.flag("switch_taped")


func refresh() -> void:
	layers["hollmann_box"].visible = Game.flag("box_found")
	shade.color = LIT if lit() else DARK


func is_active(hid: String) -> bool:
	if hid == "box":
		return Game.flag("box_found")
	return true


func display_name(hs: Dictionary) -> String:
	if hs["id"].begins_with("shelf_") and not lit():
		return "Regal"
	return hs["name"]


func _process(_dt: float) -> void:
	if light_on and Game.main.player.position.distance_to(_hold_pos) > HOLD_DIST:
		light_on = false
		refresh()


func look(hid: String) -> void:
	match hid:
		"neon":
			await say("Eine Neonröhre, die flackert. Typisch Keller.")
		"switch":
			await say("Ein Taster. Licht gibt es nur, solange jemand draufdrückt. Die Verwaltung spart.")
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
				await Game.main.flush_gesture()
				light_on = true
				_hold_pos = Game.main.player.position
				refresh()
				await say("Na also. Licht.")
		"box":
			await box()
		_:
			if hid.begins_with("shelf_"):
				await shelf(hid)
			else:
				await super(hid)


func use_item(hid: String, item: String) -> void:
	if item == "uv_lamp" and (hid.begins_with("shelf_") or hid in ["box", "neon"]):
		await refuse("Als Taschenlampe ist die UV-Lampe zu schwach. Ich brauche richtiges Licht.")
		return
	match [hid, item]:
		["switch", "masking_tape"]:
			await Game.main.flush_gesture()
			Game.set_flag("switch_taped")
			refresh()
			await say("Die Verwaltung kann mich mal.")
		["box", "caliper"]:
			await measure()
		["box", "spatula"], ["box", "spatula_soot"]:
			await open_bottom()
		["box", "masking_tape"]:
			await refuse("Die Kiste geht nicht noch einmal ins Regal. Noch nicht.")
		_:
			await super(hid, item)


## Kapitel 5a: Regal D, Fach 09, Platz 12 – nur bei Licht lesbar.
func shelf(hid: String) -> void:
	if not lit():
		if Game.flag("light_was_on"):
			await say("Wieder dunkel. Kaum lasse ich den Taster los, ist das Licht aus.")
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
		await say("Regal D, Fach 09, Platz 12 … da. D-0912, Hollmann, Nachlass.")


## An der Kiste arbeiten geht nur bei Licht.
func _too_dark() -> bool:
	if lit():
		return false
	await refuse("Zu dunkel. Ich sehe nicht einmal, was in der Kiste liegt.")
	return true


## Kapitel 5b: Der doppelte Boden.
func box() -> void:
	if await _too_dark():
		return
	if not Game.flag("box_opened"):
		Game.set_flag("box_opened")
		await say("Altes Werkzeug.")
		await say("Nichts. … Aber die Kiste ist zu schwer für das bisschen Werkzeug.", "martin/box_too_heavy")
	elif Game.flag("box_emptied"):
		await say("Nur noch altes Werkzeug.")
	elif Game.flag("false_bottom"):
		await say("Den Boden hebe ich mit etwas Flachem an der Kante an.")
	else:
		await say("Zu schwer für das bisschen Werkzeug. Wie tief ist sie eigentlich?")


func measure() -> void:
	if await _too_dark():
		return
	if not Game.flag("box_opened"):
		await box()
		return
	await say("Außen achtzehn Zentimeter. Innen … vierzehn.")
	Game.set_flag("false_bottom")
	await say("Vier Zentimeter fehlen. Da ist ein doppelter Boden.", "martin/false_bottom")


func open_bottom() -> void:
	if await _too_dark():
		return
	if Game.flag("box_emptied"):
		await say("Das Versteck ist leer.")
	elif not Game.flag("false_bottom"):
		await say("Wozu? Da ist nur Werkzeug drin.")
	else:
		Game.set_flag("box_emptied")
		await say("Mal sehen, was du versteckst …")
		for item in ["id_card", "notebook", "incense_cone", "screw_bit"]:
			Game.add_item(item)
			Game.set_flag("took_" + item)
		await say("Eine schwarze Karte mit einer roten 666. Ein Notizbuch. Ein Räucherkegel. Und ein merkwürdiger Bit.")
		await say("Den Schlüssel muss ich Frau Ackermann zurückbringen. Sonst lässt sie mich nicht gehen.")
