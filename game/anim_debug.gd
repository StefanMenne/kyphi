class_name AnimDebug
extends CanvasLayer
## Animations-Debug (F11, nur in Debug-Builds) für Martin: links alle Bildfolgen (Stand, Atmen, Sprechen, Anlaufen, Laufen, Gesten,
## Anhalten, Drehen im Stand; FL/BL entstehen durch Spiegeln), rechts die Vorschau. Abspielen als Schleife,
## rückwärts, gespiegelt, Bild für Bild (←/→, Leertaste), Standbild einblenden. „Root Motion“ bewegt die Figur
## dabei um den gemessenen Weg je Bild (rootmotion.json); die Werte des aktuellen Bildes stehen im Infotext.
## Unten: Abläufe wie im Spiel (Anlaufen → Laufen → Anhalten, Drehen im Stand) an der Vorschaufigur.
## Der Tempo-Regler verlangsamt alles (Engine.time_scale), solange der Dialog offen ist.

const W := 1344.0
const H := 864.0
const COL := Color(0.9, 0.86, 0.78)
## Vorschau: Fußpunkt und Größe (Körperhöhe in Pixeln) der Figur auf der Bühne
const STAGE := Rect2(640, 76, 660, 600)
const FOOT_Y := 600.0
const BODY := 420.0

var main: Node
var active := false
var _tex := {}
var _rm := {}
var _names := []
var _buttons := []
var _sel := ""
var _frame := 0
var _t := 0.0
var _running := false
var _offset := Vector2.ZERO
var _root := Node2D.new()
var _sprite := Sprite2D.new()
var _ref := Sprite2D.new()
var _preview: Player
var _info: Label
var _play_btn: Button
var _loop: CheckBox
var _mirror: CheckBox
var _reverse: CheckBox
var _show_ref: CheckBox
var _motion: CheckBox
var _speed: HSlider
var _speed_label: Label


func _init(owner_main: Node) -> void:
	main = owner_main
	layer = 30
	visible = false


func _ready() -> void:
	var meta = JSON.parse_string(FileAccess.get_file_as_string(Player.DIR + "anims.json"))
	_rm = JSON.parse_string(FileAccess.get_file_as_string(Player.DIR + "rootmotion.json"))
	for anim in meta:
		var frames := []
		for i in int(meta[anim]["frames"]):
			frames.append(load(Player.DIR + "%s_%02d.png" % [anim, i]))
		_tex[anim] = frames
	_names = _tex.keys()
	_names.sort_custom(func(a, b): return _order(a) < _order(b))

	var bg := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.065, 0.06, 0.97)
	sb.border_color = Color(0.45, 0.38, 0.3)
	sb.set_border_width_all(2)
	bg.add_theme_stylebox_override("panel", sb)
	bg.position = Vector2(16, 16)
	bg.size = Vector2(W - 32, H - 32)
	add_child(bg)
	var title := _label("Animations-Debug (F11 schließt)", 22)
	title.position = Vector2(36, 28)
	add_child(title)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(36, 76)
	scroll.size = Vector2(330, 600)
	add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 3)
	list.custom_minimum_size = Vector2(310, 0)
	scroll.add_child(list)
	for name in _names:
		var b := Button.new()
		b.text = "%s   (%d)" % [_title(name), _tex[name].size()]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.add_theme_font_size_override("font_size", 14)
		b.pressed.connect(func(): _select(name, true))
		list.add_child(b)
		_buttons.append(b)

	var opts := VBoxContainer.new()
	opts.position = Vector2(390, 76)
	opts.add_theme_constant_override("separation", 8)
	add_child(opts)
	_loop = _check("Schleife", true, opts)
	_reverse = _check("Rückwärts", false, opts)
	_mirror = _check("Gespiegelt (links)", false, opts)
	_show_ref = _check("Standbild einblenden", false, opts)
	_motion = _check("Root Motion", false, opts)
	for c in [_mirror, _show_ref, _motion]:
		c.toggled.connect(func(_on): _offset = Vector2.ZERO; _show_frame())
	_info = _label("", 14)
	_info.position = Vector2(390, 300)
	_info.size = Vector2(240, 380)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_info)

	var stage := ColorRect.new()
	stage.color = Color(0.55, 0.53, 0.5)
	stage.position = STAGE.position
	stage.size = STAGE.size
	add_child(stage)
	var floor_rect := ColorRect.new()
	floor_rect.color = Color(0.4, 0.38, 0.35)
	floor_rect.position = Vector2(STAGE.position.x, STAGE.position.y + FOOT_Y - 30)
	floor_rect.size = Vector2(STAGE.size.x, STAGE.size.y - FOOT_Y + 30)
	add_child(floor_rect)
	var clip := Control.new()
	clip.clip_contents = true
	clip.position = STAGE.position
	clip.size = STAGE.size
	add_child(clip)
	_root.position = Vector2(STAGE.size.x / 2, FOOT_Y)
	_root.scale = Vector2.ONE * BODY / Player.BODY_PX
	clip.add_child(_root)
	for sp in [_ref, _sprite]:
		sp.centered = false
		_root.add_child(sp)
	# hinter dem Bild: sichtbar nur, wo die Pose vom Standbild abweicht
	_ref.modulate = Color(0.55, 0.8, 1.0, 0.55)
	# Figur für die Abläufe (gleicher Code wie im Spiel), auf einem gedachten Boden mit fester Körperhöhe
	_preview = Player.new()
	_preview.room = _Floor.new()
	_preview.show_shadow = false
	_preview.visible = false
	clip.add_child(_preview)
	_preview.position = Vector2(STAGE.size.x / 2, FOOT_Y)
	_preview.update_scale()

	# Abläufe an einer echten Figur (gleicher Code wie im Spiel)
	var flows := HBoxContainer.new()
	flows.position = Vector2(36, 700)
	flows.add_theme_constant_override("separation", 8)
	add_child(flows)
	flows.add_child(_label("Abläufe:", 15))
	for spec in [["Laufen →", Vector2(1.6, 0)], ["← Laufen", Vector2(-1.6, 0)], ["schräg hinten ↗", Vector2(1.2, -0.7)],
			["hinten ↑", Vector2(0, -0.9)], ["vorn ↙", Vector2(-1.0, 0.6)]]:
		flows.add_child(_button(spec[0], func(): _walk(spec[1])))
	for spec in [["Blick links", "left"], ["Blick rechts", "right"], ["Blick hinten", "back"]]:
		flows.add_child(_button(spec[0], func(): _face(spec[1])))
	for spec in [["Geste oben", "high"], ["Hüfte", "hip"], ["unten", "low"]]:
		flows.add_child(_button(spec[0], func(): _gesture(spec[1])))

	var bar := HBoxContainer.new()
	bar.position = Vector2(36, 770)
	bar.add_theme_constant_override("separation", 12)
	add_child(bar)
	bar.add_child(_button("◀", func(): _step(-1), "Bild zurück (←)"))
	_play_btn = _button("▶ Abspielen", _toggle_run, "Abspielen / Anhalten (Leertaste)")
	_play_btn.custom_minimum_size = Vector2(130, 0)
	bar.add_child(_play_btn)
	bar.add_child(_button("▶", func(): _step(1), "Bild vor (→)"))
	bar.add_child(_button("Schließen", toggle))
	bar.add_child(_label("Tempo", 15))
	_speed = HSlider.new()
	_speed.min_value = 0.05
	_speed.max_value = 1.0
	_speed.step = 0.05
	_speed.value = 1.0
	_speed.custom_minimum_size = Vector2(200, 0)
	_speed.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_speed.value_changed.connect(_on_speed)
	bar.add_child(_speed)
	_speed_label = _label("100 %", 15)
	bar.add_child(_speed_label)
	_select(_names[0], false)


## Sortierung: Stand, Atmen, Sprechen, Anlaufen, Laufen, Anhalten (je FR, BR, B), Gesten, Drehungen
static func _order(name: String) -> String:
	var kinds := ["stand", "idle", "talk", "start", "walk", "stop", "use", "turn"]
	var p := _bare(name).split("_")
	var views := {"fr": 0, "br": 1, "b": 2}
	var heights := {"high": 0, "hip": 1, "low": 2}
	return "%d%d%d%d%s" % [1 if name.begins_with("suit_") else 0, kinds.find(p[0]), views.get(_view_of(name), 9),
		heights.get(p[1], 0), name]


## Name ohne Vorsatz "suit_" (Kälteanzug)
static func _bare(name: String) -> String:
	return name.trim_prefix("suit_")


## Richtung, deren Standbild zur Folge gehört (bei Drehungen die Ausgangsrichtung)
static func _view_of(name: String) -> String:
	var p := _bare(name).split("_")
	return p[1] if p[0] == "turn" else p[-1]


## Bildrate einer Folge: Schleifen und Gesten 12, Laufen und Drehen 8 Bilder/s
static func _fps(name: String) -> float:
	return Player.IDLE_FPS if _bare(name).split("_")[0] in ["idle", "talk", "use"] else Player.FPS


static func _title(name: String) -> String:
	return _title_bare(name) + (" (Anzug)" if name.begins_with("suit_") else "")


static func _title_bare(name: String) -> String:
	var p := _bare(name).split("_")
	var kind: String = {"stand": "Stand", "idle": "Atmen", "talk": "Sprechen", "start": "Anlaufen", "walk": "Laufen",
		"stop": "Anhalten", "use": "Geste", "turn": "Drehen"}[p[0]]
	if p[0] == "turn":
		return "%s %s → %s" % [kind, p[1].to_upper(), p[2].to_upper()]
	if p[0] == "use":
		return "%s %s %s" % [kind, {"high": "oben", "hip": "Hüfte", "low": "unten"}[p[1]], p[2].to_upper()]
	return "%s %s" % [kind, p[1].to_upper()]


func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", COL)
	return l


func _button(text: String, cb: Callable, tip := "") -> Button:
	var b := Button.new()
	b.text = text
	b.tooltip_text = tip
	b.add_theme_font_size_override("font_size", 15)
	b.pressed.connect(cb)
	return b


func _check(text: String, on: bool, parent: Control) -> CheckBox:
	var c := CheckBox.new()
	c.text = text
	c.button_pressed = on
	c.add_theme_font_size_override("font_size", 15)
	parent.add_child(c)
	return c


func _select(name: String, run: bool) -> void:
	_stop_preview()
	_sel = name
	for k in _buttons.size():
		_buttons[k].set_pressed_no_signal(_names[k] == name)
	_frame = _tex[name].size() - 1 if _reverse.button_pressed else 0
	_t = 0.0
	_offset = Vector2.ZERO
	_set_running(run)
	_show_frame()


func _set_running(on: bool) -> void:
	_running = on
	_play_btn.text = "⏸ Anhalten" if on else "▶ Abspielen"


func _toggle_run() -> void:
	_stop_preview()
	var n: int = _tex[_sel].size()
	if not _running and not _loop.button_pressed and _frame == (0 if _reverse.button_pressed else n - 1):
		_frame = n - 1 if _reverse.button_pressed else 0
		_offset = Vector2.ZERO
	_t = 0.0
	_set_running(not _running)


func _step(d: int) -> void:
	_stop_preview()
	_set_running(false)
	_frame = posmod(_frame + d, _tex[_sel].size())
	_show_frame()


## Root Motion des Bildes i als Bildschirmvektor (Körperhöhen); Laufen/Anlaufen/Anhalten nach rechts bzw. in
## die gemessene Laufrichtung, Drehungen mit den gemessenen 2D-Vektoren
func _motion_of(i: int) -> Vector2:
	if not _rm.has(_sel):
		return Vector2.ZERO
	var r: Dictionary = _rm[_sel]
	var v := Vector2(r["v"][i][0], r["v"][i][1])
	if not _bare(_sel).split("_")[0] in ["walk", "start", "stop"]:
		v *= -1.0 if _reverse.button_pressed else 1.0
	else:
		var d: Array = _rm["dir"][("suit_" if _sel.begins_with("suit_") else "") + _view_of(_sel)]
		v = Vector2(d[0], d[1]) * float(r["d"][i]) * (-1.0 if _reverse.button_pressed else 1.0)
	return Vector2(-v.x, v.y) if _mirror.button_pressed else v


func _process(dt: float) -> void:
	if not active or not _running:
		return
	var n: int = _tex[_sel].size()
	_t += dt
	var step := 1.0 / _fps(_sel)
	while _t >= step:
		_t -= step
		if _motion.button_pressed:
			_offset += _motion_of(_frame) * BODY
		var nxt: int = _frame + (-1 if _reverse.button_pressed else 1)
		if nxt < 0 or nxt >= n:
			if not _loop.button_pressed:
				_set_running(false)
				break
			nxt = posmod(nxt, n)
		_frame = nxt
	# Figur auf der Bühne halten
	if absf(_offset.x) > STAGE.size.x / 2 - 60 or absf(_offset.y) > 200:
		_offset = Vector2.ZERO
	_show_frame()


func _place(sp: Sprite2D, tex: Texture2D) -> void:
	var flip := _mirror.button_pressed
	sp.texture = tex
	sp.flip_h = flip
	sp.offset = -Vector2(tex.get_width() - Player.ANCHOR.x if flip else Player.ANCHOR.x, Player.ANCHOR.y)


func _show_frame() -> void:
	if _sel == "" or (_preview and _preview.visible):
		return
	_root.position = Vector2(STAGE.size.x / 2, FOOT_Y) + (_offset if _motion.button_pressed else Vector2.ZERO)
	_place(_sprite, _tex[_sel][_frame])
	_ref.visible = _show_ref.button_pressed
	var view := _view_of(_sel)
	_place(_ref, _tex[("suit_" if _sel.begins_with("suit_") else "") + "stand_" + Player._base(view)][0])
	var rm := ""
	if _rm.has(_sel):
		var r: Dictionary = _rm[_sel]
		var sum := 0.0
		for x in r["d"]:
			sum += float(x)
		rm = "\nRoot Motion dieses Bildes: %.3f KH\n(Vektor %.3f, %.3f)\nSumme der Folge: %.3f KH" % [
			float(r["d"][_frame]), float(r["v"][_frame][0]), float(r["v"][_frame][1]), sum]
	_info.text = "%s\n\nBild %d / %d\n%d Bilder/s (Tempo %d %%)\n%s%s\n\nKH = Körperhöhen" % [_title(_sel),
		_frame + 1, _tex[_sel].size(), int(_fps(_sel)), roundi(_speed.value * 100),
		_tex[_sel][_frame].resource_path.get_file(), rm]


## Vorschau eines Ablaufs mit einer echten Figur auf einem gedachten Boden (Körperhöhe BODY überall gleich)
class _Floor:
	extends Room
	func _init() -> void:
		depth = [Vector2(0, AnimDebug.BODY), Vector2(1000, AnimDebug.BODY)]


func _make_preview() -> void:
	_set_running(false)
	_sprite.visible = false
	_ref.visible = false
	_preview.visible = true


func _stop_preview() -> void:
	if not _preview or not _preview.visible:
		return
	_preview.stop()
	_preview.visible = false
	_sprite.visible = true


func _walk(v: Vector2) -> void:
	_make_preview()
	var p := _preview
	p.stop()
	await get_tree().process_frame
	# vom Rand her starten, damit der Weg auf die Bühne passt
	p.position = Vector2(STAGE.size.x / 2, FOOT_Y) - v * BODY / 2
	p.update_scale()
	p.face("left" if v.x < 0 else "right", true)
	_info.text = "Ablauf: Laufen um %s Körperhöhen" % v
	await p.walk_to(p.position + v * BODY)
	if p == _preview:
		_info.text += "\nangekommen, Blick %s" % p.facing.to_upper()


func _face(d: String) -> void:
	_make_preview()
	_info.text = "Ablauf: Drehen im Stand von %s nach %s" % [_preview.facing.to_upper(), d]
	await _preview.face(d)


func _gesture(kind: String) -> void:
	_make_preview()
	_info.text = "Ablauf: Geste %s, Blick %s" % [kind, _preview.facing.to_upper()]
	await _preview.gesture(kind)


func _input(event: InputEvent) -> void:
	if not active or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_LEFT:
			_step(-1)
		KEY_RIGHT:
			_step(1)
		KEY_SPACE:
			_toggle_run()
		_:
			return
	get_viewport().set_input_as_handled()


func toggle() -> void:
	active = not active
	visible = active
	if active:
		Engine.time_scale = _speed.value
		_show_frame()
	else:
		_stop_preview()
		_set_running(false)
		Engine.time_scale = 1.0


func _on_speed(v: float) -> void:
	_speed_label.text = "%d %%" % roundi(v * 100)
	if active:
		Engine.time_scale = v


func _exit_tree() -> void:
	# der gedachte Boden der Vorschaufigur hängt nicht im Baum
	if _preview and is_instance_valid(_preview.room):
		_preview.room.free()
