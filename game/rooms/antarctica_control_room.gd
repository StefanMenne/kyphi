extends Room
## Antarktis: Kontrollraum (Teil 2). Pjotr neben seinem Kaffeeautomaten, in dem die Sicherung F7 steckt;
## der Sicherungskasten mit dem leeren Platz F7 (Torheizung der Schleuse); die Schalttafel der Leiterheizung
## der Antenne (6 Ebenen, je Aus/Low/High). Die richtige Einstellung zeigen die Windfahnen im Fernrohr:
## kein Wind = Aus, normaler Wind = Low, Sturm = High. Die Sicherung trägt genau die Last der richtigen
## Einstellung (Low = 1, High = 2); mehr, und sie fliegt raus und alle Schalter springen auf Aus.

const PJOTR_SIZE := Vector2(100, 300)
const LEVELS := 6
const STATES := ["Aus", "Low", "High"]

var pjotr: Sprite2D
var _pj_tex := {}
var _talking := false
var _talk_t := 0.0


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
	for state in ["idle", "talk_small", "talk_open"]:
		_pj_tex[state] = load("res://assets/characters/pjotr/%s.png" % state)
	pjotr = add_sprite(_pj_tex["idle"], Vector2.ZERO)
	pjotr.modulate = Color(0.92, 0.95, 0.95)
	movable("pjotr", pjotr)
	move_child(pjotr, 1)

	hotspot("monitors", "Bildschirme")
	hotspot("coffee", "Kaffeeautomat", "left")
	hotspot("pjotr", "Pjotr", "left", "none")
	hotspot("heating_panel", "Schalttafel Leiterheizung")
	hotspot("fuse_box", "Sicherungskasten")
	hotspot("door", "Tür zum Bahnsteig", "right", "none")
	set_verbs({"pjotr": "talk", "door": "go"})


func _process(dt: float) -> void:
	if _talking:
		_talk_t -= dt
		if _talk_t <= 0:
			_talk_t = randf_range(0.08, 0.16)
			pjotr.texture = _pj_tex[["talk_small", "talk_open", "idle"].pick_random()]
	else:
		pjotr.texture = _pj_tex["idle"]


func speaker_anchor(speaker: String):
	if speaker == "pjotr":
		return pjotr.get_global_transform_with_canvas() * Vector2(PJOTR_SIZE.x / 2, -10)
	return null


func set_talking(speaker: String, on: bool) -> void:
	if speaker == "pjotr":
		_talking = on


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

func coffee() -> void:
	if not Game.flag("fuse_seen"):
		Game.set_flag("fuse_seen")
		await say("Hinter der Wartungsklappe … eine Sicherung. Beschriftet: F7.")
		await say("Das ist die Sicherung der Torheizung!")
	await say("Dann nehme ich die mal.")
	await pj("Finger weg! Ohne die läuft der Automat nicht. Und ohne Kaffee laufe ich nicht.")
	await narrate("[Pjotr steckt die Sicherung zurück und klappt den Automaten zu.]")


func measure_fuse() -> void:
	await Game.main.flush_gesture()
	if not Game.flag("fuse_seen"):
		Game.set_flag("fuse_seen")
		await say("Hinter der Wartungsklappe steckt eine Sicherung. F7, die von der Torheizung.")
	Game.set_flag("fuse_measured")
	await pj("Messen darfst du. Mitnehmen nicht.")
	await say("10 Millimeter Durchmesser, 38 lang. Das merke ich mir.")


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


class HeatingPanel extends CanvasLayer:
	signal closed

	var _buttons := []
	var _room: Node

	func _ready() -> void:
		layer = 5  # unter der Oberfläche (Untertitel bleiben sichtbar)
		_room = get_parent()
		var dim := ColorRect.new()
		dim.color = Color(0, 0, 0, 0.6)
		dim.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(dim)
		var box := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.32, 0.35, 0.36)
		sb.border_color = Color(0.12, 0.13, 0.14)
		sb.set_border_width_all(6)
		sb.set_corner_radius_all(6)
		sb.set_content_margin_all(28)
		box.add_theme_stylebox_override("panel", sb)
		box.position = Vector2(222, 200)
		box.custom_minimum_size = Vector2(900, 0)
		add_child(box)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 22)
		box.add_child(v)
		var title := Label.new()
		title.text = "LEITERHEIZUNG ANTENNE"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 30)
		title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
		v.add_child(title)
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 18)
		v.add_child(row)
		var h: Array = _room.heating()
		for i in 6:
			var col := VBoxContainer.new()
			var l := Label.new()
			l.text = "Ebene %d" % (i + 1)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.add_theme_font_size_override("font_size", 22)
			col.add_child(l)
			var b := Button.new()
			b.custom_minimum_size = Vector2(120, 90)
			b.add_theme_font_size_override("font_size", 26)
			b.pressed.connect(_toggle.bind(i))
			col.add_child(b)
			_buttons.append(b)
			row.add_child(col)
		var done := Button.new()
		done.text = "Fertig"
		done.add_theme_font_size_override("font_size", 26)
		done.pressed.connect(func(): closed.emit())
		v.add_child(done)
		_show(h)

	func _show(h: Array) -> void:
		var colors := [Color(0.6, 0.6, 0.6), Color(0.95, 0.75, 0.3), Color(1.0, 0.4, 0.3)]
		for i in 6:
			_buttons[i].text = STATES[int(h[i])]
			_buttons[i].add_theme_color_override("font_color", colors[int(h[i])])

	func _toggle(i: int) -> void:
		var h: Array = _room.heating().duplicate()
		h[i] = (int(h[i]) + 1) % 3
		if _room.set_heating(h):
			_show(h)
			return
		_show([0, 0, 0, 0, 0, 0])
		for b in _buttons:
			b.disabled = true
		await Game.say("martin", "Zack. Zu viel auf einmal, die Sicherung ist rausgeflogen. Alles wieder auf Aus.")
		for b in _buttons:
			b.disabled = false
