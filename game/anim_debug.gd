class_name AnimDebug
extends CanvasLayer
## Animations-Debug (F11, nur in Debug-Builds): Matrix Ausgangszustand × Zielzustand mit den Drehabläufen aus
## game/turns.json. Jedes Feld ist direkt editierbar (Kürzel, Leerzeichen als Trenner) und gilt sofort im Spiel;
## „Speichern“ schreibt die Datei. ▶ bzw. Enter spielt den Ablauf an der Vorschaufigur ab; ein Klick auf eine
## Animation in der Liste hängt ihr Kürzel an das gewählte Feld an. Rot = Sprung oder unbekanntes Kürzel.
## Der Tempo-Regler verlangsamt alles (Engine.time_scale), solange der Dialog offen ist.

const W := 1344.0
const H := 864.0
const CELL_W := 152.0
const HEAD_W := 120.0
const COL_OK := Color(0.9, 0.86, 0.78)
const COL_BAD := Color(1.0, 0.45, 0.4)

var main: Node
var active := false
var _cells := {}
var _sel := ["SR", "DR"]
var _status: Label
var _playing: Label
var _dirty_label: Label
var _preview: Player
var _suit: CheckBox
var _dirty := false
var _speed: HSlider
var _speed_label: Label


func _init(owner_main: Node) -> void:
	main = owner_main
	layer = 30
	visible = false


func _ready() -> void:
	var bg := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.065, 0.06, 0.97)
	sb.border_color = Color(0.45, 0.38, 0.3)
	sb.set_border_width_all(2)
	bg.add_theme_stylebox_override("panel", sb)
	bg.position = Vector2(16, 16)
	bg.size = Vector2(W - 32, H - 32)
	add_child(bg)

	var title := _label("Animations-Debug – Drehungen aus dem Stand (F11 schließt)", 22)
	title.position = Vector2(36, 28)
	add_child(title)

	# Matrix
	var grid := GridContainer.new()
	grid.columns = 6
	grid.position = Vector2(36, 76)
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 8)
	add_child(grid)
	var corner := _label("von ↓  nach →", 14)
	corner.custom_minimum_size = Vector2(HEAD_W, 0)
	grid.add_child(corner)
	for to in Player.STATES:
		var l := _label("%s\n%s" % [to, Player.STATE_NAMES[to]], 13)
		l.custom_minimum_size = Vector2(CELL_W, 40)
		grid.add_child(l)
	for from in Player.STATES:
		var l := _label("%s  %s" % [from, Player.STATE_NAMES[from]], 13)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.custom_minimum_size = Vector2(HEAD_W, 0)
		grid.add_child(l)
		for to in Player.STATES:
			if from == to:
				var dash := _label("—", 14)
				dash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				dash.custom_minimum_size = Vector2(CELL_W, 0)
				grid.add_child(dash)
				continue
			var box := HBoxContainer.new()
			box.custom_minimum_size = Vector2(CELL_W, 0)
			var e := LineEdit.new()
			e.custom_minimum_size = Vector2(CELL_W - 34, 0)
			e.add_theme_font_size_override("font_size", 14)
			e.text_changed.connect(func(_t): _on_edit(from, to))
			e.text_submitted.connect(func(_t): _play(from, to))
			e.focus_entered.connect(func(): _select(from, to))
			box.add_child(e)
			var b := Button.new()
			b.text = "▶"
			b.tooltip_text = "Abspielen"
			b.pressed.connect(func(): _play(from, to))
			box.add_child(b)
			grid.add_child(box)
			_cells[from + ">" + to] = e

	# Status zum gewählten Feld
	_status = _label("", 15)
	_status.position = Vector2(36, 342)
	_status.size = Vector2(900, 50)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_status)

	# Liste der Animationen
	var list_title := _label("Animationen (Klick hängt das Kürzel an das gewählte Feld an)", 15)
	list_title.position = Vector2(36, 412)
	add_child(list_title)
	var list := GridContainer.new()
	list.columns = 2
	list.position = Vector2(36, 440)
	list.add_theme_constant_override("h_separation", 10)
	list.add_theme_constant_override("v_separation", 4)
	add_child(list)
	for code in Player.ANIMS:
		var b := Button.new()
		b.text = "%-5s  %s" % [code, Player.anim_name(code)]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(440, 0)
		b.add_theme_font_size_override("font_size", 14)
		b.pressed.connect(func(): _append(code))
		list.add_child(b)

	# Knöpfe
	var bar := HBoxContainer.new()
	bar.position = Vector2(36, 770)
	bar.add_theme_constant_override("separation", 12)
	add_child(bar)
	for spec in [["Start", func(): _play(_sel[0], _sel[1])], ["Alle abspielen", _play_all],
			["Speichern", _save], ["Neu laden", _reload], ["Schließen", toggle]]:
		var b := Button.new()
		b.text = spec[0]
		b.add_theme_font_size_override("font_size", 16)
		b.pressed.connect(spec[1])
		bar.add_child(b)
	_suit = CheckBox.new()
	_suit.text = "Kälteanzug"
	_suit.toggled.connect(func(on): _preview.set_suit(on))
	bar.add_child(_suit)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(16, 0)
	bar.add_child(gap)
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
	_speed_label.custom_minimum_size = Vector2(56, 0)
	bar.add_child(_speed_label)
	_dirty_label = _label("", 14)
	bar.add_child(_dirty_label)

	# Vorschau
	var stage := ColorRect.new()
	stage.color = Color(0.55, 0.53, 0.5)
	stage.position = Vector2(970, 76)
	stage.size = Vector2(330, 660)
	add_child(stage)
	var floor_line := ColorRect.new()
	floor_line.color = Color(0.4, 0.38, 0.35)
	floor_line.position = Vector2(970, 640)
	floor_line.size = Vector2(330, 96)
	add_child(floor_line)
	_preview = Player.new()
	_preview.position = Vector2(1135, 660)
	_preview.scale = Vector2(0.85, 0.85)
	add_child(_preview)
	_playing = _label("", 18)
	_playing.position = Vector2(980, 700)
	add_child(_playing)


func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", COL_OK)
	return l


func toggle() -> void:
	active = not active
	visible = active
	if active:
		_suit.set_pressed_no_signal(main.player.suit)
		_preview.set_suit(main.player.suit)
		_fill()
		_select(_sel[0], _sel[1])
		Engine.time_scale = _speed.value
	else:
		_preview.stop()
		Engine.time_scale = 1.0


func _on_speed(v: float) -> void:
	_speed_label.text = "%d %%" % roundi(v * 100)
	if active:
		Engine.time_scale = v


func _fill() -> void:
	for key in _cells:
		var p: PackedStringArray = key.split(">")
		_cells[key].text = str(Player.turns.get(p[0], {}).get(p[1], ""))
		_color(p[0], p[1])


func _codes(from: String, to: String) -> Array:
	return Array(_cells[from + ">" + to].text.strip_edges().split(" ", false))


func _color(from: String, to: String) -> void:
	var bad := not Player.check_sequence(from, to, _codes(from, to)).is_empty()
	_cells[from + ">" + to].add_theme_color_override("font_color", COL_BAD if bad else COL_OK)


func _on_edit(from: String, to: String) -> void:
	if not Player.turns.has(from):
		Player.turns[from] = {}
	Player.turns[from][to] = " ".join(_codes(from, to))
	_dirty = true
	_dirty_label.text = "ungespeichert"
	_color(from, to)
	_select(from, to)


func _select(from: String, to: String) -> void:
	_cells[_sel[0] + ">" + _sel[1]].remove_theme_stylebox_override("normal")
	_sel = [from, to]
	var hi := StyleBoxFlat.new()
	hi.bg_color = Color(0.16, 0.14, 0.11)
	hi.border_color = Color(0.95, 0.75, 0.35)
	hi.set_border_width_all(2)
	hi.content_margin_left = 6
	_cells[from + ">" + to].add_theme_stylebox_override("normal", hi)
	var codes := _codes(from, to)
	var notes := Player.check_sequence(from, to, codes)
	var names := []
	for c in codes:
		names.append(Player.anim_name(c) if Player.ANIMS.has(c) else c + "?")
	_status.text = "%s → %s:  %s%s" % [Player.STATE_NAMES[from], Player.STATE_NAMES[to],
		"  |  ".join(names) if names else "(keine Animation)",
		("\n" + ", ".join(notes)) if notes else ""]
	_status.add_theme_color_override("font_color", COL_BAD if notes else COL_OK)


func _append(code: String) -> void:
	var e: LineEdit = _cells[_sel[0] + ">" + _sel[1]]
	e.text = (e.text.strip_edges() + " " + code).strip_edges()
	_on_edit(_sel[0], _sel[1])
	e.grab_focus()
	e.caret_column = e.text.length()


func _play(from: String, to: String) -> void:
	_select(from, to)
	_preview.preview(from, _codes(from, to), to, func(c): _playing.text = c)


func _play_all() -> void:
	for from in Player.STATES:
		for to in Player.STATES:
			if from == to:
				continue
			if not active:
				return
			_select(from, to)
			var t := _preview._token
			await _preview.preview(from, _codes(from, to), to, func(c): _playing.text = c)
			if _preview._token != t + 1:
				return   # abgebrochen (anderer Start)


func _save() -> void:
	Player.save_turns()
	_dirty = false
	_dirty_label.text = "gespeichert"


func _reload() -> void:
	Player.load_turns()
	_dirty = false
	_dirty_label.text = ""
	_fill()
	_select(_sel[0], _sel[1])
