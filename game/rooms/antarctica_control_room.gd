extends Room
## Antarktis: Kontrollraum (Teil 2). Pjotr neben seinem Kaffeeautomaten, in dem die Sicherung F7 steckt;
## der Sicherungskasten mit dem leeren Platz F7 (Torheizung der Schleuse); die Schalttafel der Leiterheizung
## der Antenne (6 Ebenen, je Aus/Low/High). Die richtige Einstellung zeigen die Windfahnen im Fernrohr:
## kein Wind = Aus, normaler Wind = Low, Sturm = High. Die Sicherung trägt genau die Last der richtigen
## Einstellung (Low = 1, High = 2); mehr, und sie fliegt raus und alle Schalter springen auf Aus.

const LEVELS := 6
const STATES := ["Aus", "Low", "High"]

var pjotr: Npc


func _init() -> void:
	asset_dir = "antarctica_control_room"


## Windstufen der Ebenen 1-6 (0 kein Wind, 1 normal, 2 Sturm); einmal je Spiel festgelegt.
static func wind() -> Array:
	if not Game.flags.has("wind_levels"):
		var w := []
		while true:
			w = []
			for i in LEVELS:
				w.append(randi() % 3)
			if 0 in w and 1 in w and 2 in w:
				break
		Game.set_flag("wind_levels", w)
	return Game.value("wind_levels")


static func heating() -> Array:
	return Game.value("heating", [0, 0, 0, 0, 0, 0])


static func budget() -> int:
	var b := 0
	for w in wind():
		b += int(w)
	return b


## Unterste Ebene (1-6), deren Heizung nicht zum Wind passt, sonst 0.
static func first_frozen() -> int:
	var w := wind()
	var h := heating()
	for i in LEVELS:
		if int(h[i]) != int(w[i]):
			return i + 1
	return 0


func build() -> void:
	tint = Color(0.85, 0.9, 0.9)
	pjotr = add_npc("pjotr")
	pjotr.modulate = Color(0.92, 0.95, 0.95)

	hotspot("monitors", "Bildschirme")
	hotspot("coffee", "Kaffeeautomat")
	hotspot("pjotr", "Pjotr", "none")
	hotspot("heating_panel", "Schalttafel Leiterheizung")
	hotspot("fuse_box", "Sicherungskasten")
	hotspot("door", "Tür zum Bahnsteig", "none")
	set_verbs({"pjotr": "talk", "door": "go"})


func pj(text: String, voice := "") -> void:
	await Game.say("pjotr", text, voice)


func on_enter(_from: String) -> void:
	if not Game.flag("control_room_seen"):
		Game.set_flag("control_room_seen")
		await pj("Besuch! Bei minus achtundsechzig kommt sonst nur der Postsack.")


func look(hid: String) -> void:
	match hid:
		"monitors":
			await say("Wetterdaten, Polarlicht, Antennenpegel. Alles grün, nur nicht der Pegel.")
		"coffee":
			if Game.flag("fuse_seen"):
				await say("Pjotrs Kaffeeautomat. Unter der Klappe steckt die Sicherung F7.")
			else:
				await say("Ein alter Kaffeeautomat. Der einzige Luxus hier unten. Er brummt verdächtig laut.")
		"pjotr":
			await say("Pjotr, der Techniker. Er hält seinen Kaffeebecher fest, als hinge sein Leben daran.")
		"heating_panel":
			await say("Leiterheizung Antenne, Ebene 1 bis 6. Je ein Schalter: Aus, Low, High.")
		"fuse_box":
			if Game.flag("gate_fuse_in"):
				await say("Der Sicherungskasten. F7, Torheizung Schleuse, ist wieder drin.")
			else:
				await say("Der Sicherungskasten. Ein Platz ist leer: F7, Torheizung Schleuse.")
		"door":
			await say("Die Tür zum Bahnsteig.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"door":
			await go("antarctica_platform")
		"pjotr":
			await talk()
		"coffee":
			await coffee()
		"heating_panel":
			await heating_panel()
		"fuse_box":
			if Game.flag("gate_fuse_in"):
				await refuse("Alles drin. Mehr Sicherungen hat der Kasten nicht.")
			else:
				await refuse("Ohne Ersatzsicherung kann ich da nichts machen.")
		"monitors":
			await refuse("Ich drücke hier besser auf nichts.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["coffee", "caliper"]:
			await measure_fuse()
		["fuse_box", "fuse"]:
			await Game.main.flush_gesture()
			Game.remove_item("fuse")
			Game.set_flag("gate_fuse_in")
			await say("Passt. 10 mal 38. Die Torheizung hat wieder Strom.")
			await pj("Na sieh mal an. Und mein Kaffee läuft auch noch.")
		["coffee", "fuse"]:
			await refuse("Pjotrs Automat hat schon eine. Leider meine.")
		["pjotr", _]:
			await pj("Danke, ich hab alles, was ich brauche. Kaffee.")
		_:
			await super(hid, item)


# Pjotr

func talk() -> void:
	if not Game.flag("pjotr_met"):
		Game.set_flag("pjotr_met")
		await pj("Pjotr. Technik, Heizung, Kaffee. Das Letzte ist das Wichtigste.")
	while true:
		var opts := ["Was ist mit der Antenne?", "Die Torheizung in der Schleuse geht nicht.",
			"Würden Sie für mich bürgen?", "Bis später."]
		var i := await Game.choose(opts)
		await say(opts[i])
		match i:
			0:
				await pj("Seit dem Unfall ist die Leiterheizung aus. Die Leiter ist ein einziger Eiszapfen.")
				await pj("412 liegt noch oben. Bei dem Wetter holt den keiner runter. Erst wenn die Heizung wieder läuft.")
				await say("Und warum läuft sie nicht?")
				await pj("Weil keiner weiß, wie man sie einstellt. Zu viel auf einmal, und die Sicherung fliegt raus.")
				await pj("Wie viel Heizung eine Ebene braucht, hängt vom Wind ab. Den sieht man nur von oben, im Fernrohr.")
			1:
				await pj("Sicherung F7 fehlt. Keine Ahnung, wo die hin ist.")
				await say("Keine Ahnung. Aha.")
			2:
				if Game.flag("pjotr_bail"):
					await pj("Hab ich doch schon gesagt: klar!")
				else:
					Game.set_flag("pjotr_bail")
					await pj("Klar bürge ich! Wofür auch immer.")
			_:
				await pj("Mach die Tür zu, wenn du gehst. Wegen der Wärme.")
				return


# Kaffeeautomat und Sicherung

func refresh() -> void:
	layers["coffee_open"].visible = false


func coffee() -> void:
	layers["coffee_open"].visible = true
	if not Game.flag("fuse_seen"):
		Game.set_flag("fuse_seen")
		await say("Hinter der Wartungsklappe … eine Sicherung. Beschriftet: F7.")
		await say("Das ist die Sicherung der Torheizung!")
	await say("Dann nehme ich die mal.")
	await pj("Finger weg! Ohne die läuft der Automat nicht. Und ohne Kaffee laufe ich nicht.")
	await narrate("[Pjotr steckt die Sicherung zurück und klappt den Automaten zu.]")
	layers["coffee_open"].visible = false


func measure_fuse() -> void:
	await Game.main.flush_gesture()
	layers["coffee_open"].visible = true
	if not Game.flag("fuse_seen"):
		Game.set_flag("fuse_seen")
		await say("Hinter der Wartungsklappe steckt eine Sicherung. F7, die von der Torheizung.")
	Game.set_flag("fuse_measured")
	await pj("Messen darfst du. Mitnehmen nicht.")
	await say("10 Millimeter Durchmesser, 38 lang. Das merke ich mir.")
	layers["coffee_open"].visible = false


# Schalttafel der Leiterheizung

func heating_panel() -> void:
	await Game.main.flush_gesture()
	if Game.fast:
		return
	var panel := HeatingPanel.new()
	add_child(panel)
	await panel.closed
	panel.queue_free()


## Stellt die Heizung ein (vom Schaltfeld und im Test); false, wenn die Sicherung rausfliegt.
func set_heating(h: Array) -> bool:
	var total := 0
	for s in h:
		total += int(s)
	if total > budget():
		Game.set_flag("heating", [0, 0, 0, 0, 0, 0])
		return false
	Game.set_flag("heating", h.duplicate())
	return true


## Nahansicht der Schalttafel: Bild der Tafel, sechs Drehschalter (Aus/Low/High, je Klick eine Stufe weiter),
## Lampe je Ebene; die Beschriftung zeichnet das Spiel.
class HeatingPanel extends CanvasLayer:
	signal closed

	const W := 1344.0
	const H := 768.0
	## Mittelpunkte der Drehschalter auf dem Bild der Tafel (1344 x 768)
	const KNOB_Y := 420.0
	const KNOB_D := 80.0
	const ANGLES := [-45.0, 0.0, 45.0]
	const LAMP := [Color(0.25, 0.25, 0.25), Color(1.0, 0.75, 0.25), Color(1.0, 0.3, 0.2)]

	var _knobs := []
	var _room: Node
	var _deco := Control.new()
	var _h := [0, 0, 0, 0, 0, 0]
	var _locked := false

	static func knob_x(i: int) -> float:
		return 305.0 + 730.0 * (i + 0.5) / 6.0

	func _ready() -> void:
		layer = 5  # unter der Oberfläche (Untertitel bleiben sichtbar)
		_room = get_parent()
		_h = _room.heating().duplicate()
		var bg := TextureRect.new()
		bg.texture = load("res://assets/ui/heating_panel.png")
		bg.size = Vector2(W, H)
		bg.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(bg)
		_deco.size = Vector2(W, H)
		_deco.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_deco.draw.connect(_draw_deco)
		add_child(_deco)
		var tex: Texture2D = load("res://assets/ui/rotary_knob.png")
		for i in 6:
			var k := TextureRect.new()
			k.texture = tex
			k.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			k.size = Vector2(KNOB_D, KNOB_D)
			k.pivot_offset = k.size / 2
			k.position = Vector2(knob_x(i), KNOB_Y) - k.size / 2
			k.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			k.gui_input.connect(_on_knob.bind(i))
			add_child(k)
			_knobs.append(k)
		var back := Button.new()
		back.text = "Zurück"
		back.add_theme_font_size_override("font_size", 26)
		back.position = Vector2(W / 2 - 90, 700)
		back.custom_minimum_size = Vector2(180, 52)
		back.pressed.connect(func(): if not _locked: closed.emit())
		add_child(back)
		_show()

	func _show() -> void:
		for i in 6:
			_knobs[i].rotation_degrees = ANGLES[int(_h[i])]
		_deco.queue_redraw()

	func _draw_deco() -> void:
		var f := ThemeDB.fallback_font
		var dark := Color(0.12, 0.12, 0.13)
		_deco.draw_string(f, Vector2(420, 172), "LEITERHEIZUNG ANTENNE", HORIZONTAL_ALIGNMENT_CENTER, 505, 34, dark)
		for i in 6:
			var c := Vector2(knob_x(i), KNOB_Y)
			for s in 3:
				var a := deg_to_rad(ANGLES[s] - 90.0)
				var p := c + Vector2(cos(a), sin(a)) * (KNOB_D / 2 + 16)
				var on := int(_h[i]) == s
				_deco.draw_string(f, p + Vector2(-25, 6), STATES[s], HORIZONTAL_ALIGNMENT_CENTER, 50, 15,
					Color(0.05, 0.05, 0.05) if on else Color(0.25, 0.25, 0.27))
			var lamp := c + Vector2(0, KNOB_D / 2 + 26)
			_deco.draw_circle(lamp, 11, Color(0.08, 0.08, 0.08))
			_deco.draw_circle(lamp, 8, LAMP[int(_h[i])])
			_deco.draw_string(f, lamp + Vector2(-50, 44), "Ebene %d" % (i + 1), HORIZONTAL_ALIGNMENT_CENTER, 100, 18, dark)

	func _on_knob(event: InputEvent, i: int) -> void:
		if _locked or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			return
		var h: Array = _h.duplicate()
		h[i] = (int(h[i]) + 1) % 3
		if _room.set_heating(h):
			_h = h
			_show()
			return
		_locked = true
		_h = h
		_show()
		await get_tree().create_timer(0.3).timeout
		_h = [0, 0, 0, 0, 0, 0]
		_show()
		await Game.say("martin", "Zack. Zu viel auf einmal, die Sicherung ist rausgeflogen. Alles wieder auf Aus.")
		_locked = false
