extends Room
## Antarktis: Außenbeobachtung unter der Glaskuppel (Teil 2). Das Fernrohr ist eingefroren und wird mit dem Tee
## aus der Thermoskanne aufgetaut. Dann zeigt es die Antenne: Ebene 1-6 mit je einer Windfahne (kein Wind,
## normaler Wind, Sturm; fest je Spiel, siehe Kontrollraum) und die oberste Ebene mit dem erfrorenen 412.

const CR := preload("res://game/rooms/antarctica_control_room.gd")


func _init() -> void:
	asset_dir = "antarctica_observation"


func build() -> void:
	tint = Color(0.8, 0.86, 0.95)
	hotspot("stairs", "Treppe nach unten", "left", "none")
	hotspot("antennas", "Antennenfeld")
	hotspot("telescope", "Fernrohr", "right")
	hotspot("recorder", "Windschreiber", "right")
	set_verbs({"stairs": "go"})


func on_enter(from: String) -> void:
	if not Game.flag("observation_seen"):
		Game.set_flag("observation_seen")
		await say("Eine Glaskuppel mitten im Eis. Und draußen ein ganzer Wald aus Antennen.")


func look(hid: String) -> void:
	match hid:
		"stairs":
			await say("Die Treppe hinunter zum Bahnsteig.")
		"antennas":
			await say("Antennen, so weit man sieht. Die große direkt vor der Kuppel hat oben eine Plattform.")
		"telescope":
			if Game.flag("telescope_thawed"):
				await say("Das Fernrohr. Motorisiert, man kann es an der Antenne hoch- und runterfahren.")
			else:
				await say("Ein großes Fernrohr. Das Okular ist mit einer dicken Eisschicht überzogen.")
		"recorder":
			await say("Ein alter Windschreiber. Die Nadel zittert ununterbrochen. Da oben stürmt es ohne Pause.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"stairs":
			await go("antarctica_platform")
		"telescope":
			if Game.flag("telescope_thawed"):
				await view_telescope()
			else:
				await refuse("Durchs Eis sehe ich nur Milchglas. Das Okular muss erst auftauen.")
		"recorder":
			await refuse("Den lasse ich schreiben. Viel Neues erzählt er nicht: Wind, Wind, Wind.")
		"antennas":
			await refuse("Zu weit weg. Von hier aus geht das nur mit dem Fernrohr.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["telescope", "thermos"]:
			await Game.main.flush_gesture()
			if Game.flag("telescope_thawed"):
				await refuse("Das Okular ist schon frei. Den Rest Tee trinke ich lieber selbst.")
				return
			Game.set_flag("telescope_thawed")
			await say("Ein Schluck heißer Tee aufs Okular …")
			await say("Das Eis schmilzt. Schnell abwischen, bevor es wieder gefriert. Frei!")
		["telescope", "salt"]:
			await refuse("Salz auf eine Linse? Damit wäre sie hinüber.")
		_:
			await super(hid, item)


func view_telescope() -> void:
	await Game.main.flush_gesture()
	if Game.fast:
		Game.set_flag("saw_412")
		return
	var v := TelescopeView.new()
	add_child(v)
	await v.closed
	v.queue_free()


## Fernrohr-Ansicht: Vollbild mit rundem Rand, Hoch/Runter schwenken um eine Ebene, Verlassen.
class TelescopeView extends CanvasLayer:
	signal closed

	const W := 1344.0
	const H := 768.0
	const TOP := 7
	## Wie stark die Fahne im Fernrohr erscheint (Bildpixel des Hintergrunds -> Fahnenhöhe)
	const VANE_H := 190.0

	var level := 1
	var _bg := TextureRect.new()
	var _vane := TextureRect.new()
	var _label := Label.new()
	var _up := Button.new()
	var _down := Button.new()
	var _tex := {}
	var _vane_info := {}
	var _t := 0.0
	var _busy := false

	func _ready() -> void:
		layer = 5
		_tex["level"] = load("res://assets/scenes/antarctica_telescope_level/background.png")
		_tex["top"] = load("res://assets/scenes/antarctica_telescope_top/background.png")
		_vane_info = Game.catalog["scenes"]["antarctica_telescope_level"]["vane"]
		for st in ["calm", "breeze", "storm"]:
			_tex["vane_" + st] = load("res://assets/" + _vane_info["states"][st]["file"])
		var black := ColorRect.new()
		black.color = Color.BLACK
		black.size = Vector2(W, 864)
		add_child(black)
		# Bild auf Fensterhöhe skaliert, waagerecht mittig
		var s := H / 576.0
		_bg.size = Vector2(2048, 576) * s
		_bg.position = Vector2((W - 2048 * s) / 2, 0)
		_bg.stretch_mode = TextureRect.STRETCH_SCALE
		_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		add_child(_bg)
		_vane.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_vane.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(_vane)
		var ring := TextureRect.new()
		ring.texture = load("res://assets/ui/scope_ring.png")
		ring.size = Vector2(W, H)
		add_child(ring)
		_label.add_theme_font_size_override("font_size", 30)
		_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
		_label.add_theme_constant_override("outline_size", 6)
		_label.add_theme_color_override("font_outline_color", Color.BLACK)
		_label.position = Vector2(40, 30)
		add_child(_label)
		var col := VBoxContainer.new()
		col.position = Vector2(W - 210, H / 2 - 130)
		col.add_theme_constant_override("separation", 16)
		add_child(col)
		for b in [_up, _down]:
			b.custom_minimum_size = Vector2(170, 70)
			b.add_theme_font_size_override("font_size", 28)
			col.add_child(b)
		_up.text = "▲ Hoch"
		_down.text = "▼ Runter"
		_up.pressed.connect(_move.bind(1))
		_down.pressed.connect(_move.bind(-1))
		var leave := Button.new()
		leave.text = "Verlassen"
		leave.custom_minimum_size = Vector2(170, 60)
		leave.add_theme_font_size_override("font_size", 24)
		leave.pressed.connect(func(): if not _busy: closed.emit())
		col.add_child(leave)
		_show()

	func _show() -> void:
		var top := level == TOP
		_bg.texture = _tex["top" if top else "level"]
		_label.text = "Spitze" if top else "Ebene %d" % level
		_up.disabled = top
		_down.disabled = level == 1
		_vane.visible = not top
		if not top:
			var st: String = ["calm", "breeze", "storm"][int(CR.wind()[level - 1])]
			var info: Dictionary = _vane_info["states"][st]
			var k := VANE_H / float(info["h"]) * (H / 576.0)
			_vane.texture = _tex["vane_" + st]
			_vane.size = Vector2(info["w"], info["h"]) * k
			_vane.pivot_offset = Vector2(info["anchor"][0], info["anchor"][1]) * k
			var foot: Array = _vane_info["mast_foot"]
			_vane.position = _bg.position + Vector2(foot[0], foot[1]) * (H / 576.0) - _vane.pivot_offset
			_vane.set_meta("state", st)

	func _process(dt: float) -> void:
		_t += dt
		if not _vane.visible:
			return
		match _vane.get_meta("state", "calm"):
			"breeze":
				_vane.scale = Vector2(1.0 + 0.06 * sin(_t * 3.0), 1.0)
				_vane.rotation = 0.02 * sin(_t * 2.1)
			"storm":
				_vane.scale = Vector2(1.0 + 0.08 * sin(_t * 23.0) + 0.04 * sin(_t * 37.0), 1.0)
				_vane.rotation = 0.015 * sin(_t * 29.0)
			_:
				_vane.scale = Vector2.ONE
				_vane.rotation = 0.0

	func _move(d: int) -> void:
		if _busy:
			return
		_busy = true
		var tw := create_tween()
		tw.tween_property(_bg, "modulate", Color(0.2, 0.2, 0.2), 0.18)
		tw.parallel().tween_property(_vane, "modulate", Color(0.2, 0.2, 0.2), 0.18)
		await tw.finished
		level = clampi(level + d, 1, TOP)
		_show()
		tw = create_tween()
		tw.tween_property(_bg, "modulate", Color.WHITE, 0.25)
		tw.parallel().tween_property(_vane, "modulate", Color.WHITE, 0.25)
		await tw.finished
		if level == TOP and not Game.flag("saw_412"):
			Game.set_flag("saw_412")
			await Game.say("martin", "Da oben liegt jemand. Das muss 412 sein.")
			await Game.say("martin", "Seine Medaille hat er bestimmt noch bei sich.")
		_busy = false
