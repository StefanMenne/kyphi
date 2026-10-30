class_name GameUI
extends CanvasLayer
## Oberfläche: Untertitel, Hover-Text, Inventarleiste, Antwortauswahl, Notizen, Blenden, Menüs.

signal advanced(seq: int)
signal chosen(index: int)

const W := 1344.0
const H := 864.0
const VIEW_H := 768.0
const PER_PAGE := 12
const SLOT := 80.0

var main: Node
var hover: Label
var line: Label
var hint: Label
var bar: Panel
var slots: Control
var page := 0
var choice_panel: PanelContainer
var choice_box: VBoxContainer
var note_panel: PanelContainer
var note_label: Label
var blocker: Control
var fade: ColorRect
var flash_rect: ColorRect
var big: Label
var cursor_icon: TextureRect
var menu_panel: PanelContainer
var menu_box: VBoxContainer
var title_layer: Control
var hover_item := ""
var _seq := 0


func _init(owner_main: Node) -> void:
	main = owner_main
	layer = 10


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	bar = Panel.new()
	bar.position = Vector2(0, VIEW_H)
	bar.size = Vector2(W, H - VIEW_H)
	bar.add_theme_stylebox_override("panel", _box(Color(0.1, 0.09, 0.08, 0.97), Color(0.35, 0.3, 0.25)))
	root.add_child(bar)
	slots = Control.new()
	slots.size = bar.size
	bar.add_child(slots)
	Game.inventory_changed.connect(_fill_inventory)

	hint = _label(18, Color(0.95, 0.92, 0.85))
	hint.position = Vector2(0, VIEW_H - 40)
	hint.size = Vector2(W, 30)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hint)

	hover = _label(20, Color(1, 1, 1))
	root.add_child(hover)

	line = _label(26, Color.WHITE)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	line.size = Vector2(760, 220)
	line.visible = false
	root.add_child(line)

	choice_panel = PanelContainer.new()
	choice_panel.add_theme_stylebox_override("panel", _box(Color(0.08, 0.07, 0.06, 0.95), Color(0.35, 0.3, 0.25)))
	choice_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	choice_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	choice_panel.visible = false
	choice_box = VBoxContainer.new()
	choice_panel.add_child(choice_box)
	root.add_child(choice_panel)

	blocker = Control.new()
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.visible = false
	blocker.gui_input.connect(_on_blocker_input)
	root.add_child(blocker)

	note_panel = PanelContainer.new()
	note_panel.add_theme_stylebox_override("panel", _box(Color(0.93, 0.89, 0.8), Color(0.3, 0.25, 0.2), 28))
	note_panel.position = Vector2(W / 2 - 330, 150)
	note_panel.custom_minimum_size = Vector2(660, 0)
	note_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	note_panel.visible = false
	note_label = _label(26, Color(0.15, 0.12, 0.1), 0)
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note_panel.add_child(note_label)
	root.add_child(note_panel)

	flash_rect = ColorRect.new()
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1, 0, 0, 0)
	root.add_child(flash_rect)

	fade = ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.color = Color(0, 0, 0, 1)
	root.add_child(fade)

	big = _label(44, Color(0.95, 0.92, 0.85))
	big.set_anchors_preset(Control.PRESET_FULL_RECT)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	big.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	big.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(big)

	title_layer = Control.new()
	title_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_layer.visible = false
	root.add_child(title_layer)
	var bg := TextureRect.new()
	bg.texture = load("res://assets/scenes/altarraum/background.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.45, 0.42, 0.4)
	title_layer.add_child(bg)
	var t := _label(96, Color(0.96, 0.88, 0.7), 10)
	t.text = "Kyphi"
	t.position = Vector2(0, 150)
	t.size = Vector2(W, 120)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_layer.add_child(t)
	var st := _label(34, Color(0.9, 0.85, 0.75), 6)
	st.text = "Teil 1: Der Zugang"
	st.position = Vector2(0, 270)
	st.size = Vector2(W, 50)
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_layer.add_child(st)

	menu_panel = PanelContainer.new()
	menu_panel.add_theme_stylebox_override("panel", _box(Color(0.08, 0.07, 0.06, 0.92), Color(0.45, 0.38, 0.3), 24))
	menu_panel.custom_minimum_size = Vector2(360, 0)
	menu_panel.visible = false
	menu_box = VBoxContainer.new()
	menu_box.add_theme_constant_override("separation", 10)
	menu_panel.add_child(menu_box)
	root.add_child(menu_panel)

	cursor_icon = TextureRect.new()
	cursor_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cursor_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cursor_icon.size = Vector2(56, 56)
	cursor_icon.visible = false
	root.add_child(cursor_icon)


func _process(_dt: float) -> void:
	var m := get_viewport().get_mouse_position()
	cursor_icon.position = m - Vector2(28, 28)
	if hover.text != "":
		var w := hover.get_minimum_size().x
		hover.position = Vector2(clampf(m.x - w / 2, 8, W - w - 8), clampf(m.y - 52, 8, H - 40))


func _label(size: int, color: Color, outline := 7) -> Label:
	var l := Label.new()
	var s := LabelSettings.new()
	s.font_size = size
	s.font_color = color
	s.outline_size = outline
	s.outline_color = Color(0, 0, 0, 0.9)
	l.label_settings = s
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _box(bg: Color, border: Color, margin := 12) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = bg
	b.border_color = border
	b.set_border_width_all(2)
	b.set_corner_radius_all(6)
	b.set_content_margin_all(margin)
	return b


func set_hover(text: String) -> void:
	hover.text = text


func show_hint(text: String) -> void:
	hint.text = text


func set_cursor_item(item: String) -> void:
	cursor_icon.visible = item != ""
	if item != "":
		cursor_icon.texture = Game.item_icon(item)


# Inventar

func _fill_inventory() -> void:
	for c in slots.get_children():
		c.queue_free()
	var pages := maxi(1, ceili(Game.inventory.size() / float(PER_PAGE)))
	page = clampi(page, 0, pages - 1)
	var x0 := 60.0
	for i in PER_PAGE:
		var n := page * PER_PAGE + i
		if n >= Game.inventory.size():
			break
		var item: String = Game.inventory[n]
		var tr := TextureRect.new()
		tr.texture = Game.item_icon(item)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.position = Vector2(x0 + i * (SLOT + 22), 8)
		tr.size = Vector2(SLOT, SLOT)
		tr.gui_input.connect(_on_slot_input.bind(item))
		tr.mouse_entered.connect(func(): hover_item = item)
		tr.mouse_exited.connect(func(): if hover_item == item: hover_item = "")
		slots.add_child(tr)
	if pages > 1:
		_page_button("◀", Vector2(8, 26), -1, page > 0)
		_page_button("▶", Vector2(W - 48, 26), 1, page < pages - 1)


func _page_button(text: String, pos: Vector2, delta: int, enabled: bool) -> void:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.disabled = not enabled
	b.position = pos
	b.size = Vector2(40, 44)
	b.pressed.connect(func(): page += delta; _fill_inventory())
	slots.add_child(b)


func _on_slot_input(event: InputEvent, item: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		main.on_item_clicked(item, event.button_index)


# Untertitel und Warten

func show_line(text: String, color: Color, anchor) -> void:
	line.text = text
	line.label_settings.font_color = color
	if anchor == null:
		line.position = Vector2(W / 2 - line.size.x / 2, 20)
		line.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	else:
		line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		line.position = Vector2(
			clampf(anchor.x - line.size.x / 2, 10, W - line.size.x - 10),
			clampf(anchor.y - line.size.y, -150, VIEW_H - line.size.y - 20))
	line.visible = true


func hide_line() -> void:
	line.visible = false


## Wartet die Zeit ab oder bis zum nächsten Klick.
func wait_or_skip(seconds: float) -> void:
	_seq += 1
	var my := _seq
	blocker.visible = true
	get_tree().create_timer(seconds).timeout.connect(func(): advanced.emit(my))
	while true:
		var s: int = await advanced
		if s == my:
			break
	blocker.visible = false


func _on_blocker_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		advanced.emit(_seq)


func show_note(text: String) -> void:
	note_label.text = text
	note_panel.visible = true
	await wait_or_skip(600.0)
	note_panel.visible = false


func choose(options: Array) -> int:
	for c in choice_box.get_children():
		c.queue_free()
	for i in options.size():
		var b := Button.new()
		b.text = options[i]
		b.flat = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 24)
		b.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7))
		b.add_theme_color_override("font_hover_color", Color(1, 0.85, 0.45))
		b.pressed.connect(func(): chosen.emit(i))
		choice_box.add_child(b)
	choice_panel.visible = true
	bar.visible = false
	var i: int = await chosen
	choice_panel.visible = false
	bar.visible = true
	return i


# Blenden und Effekte

func fade_out(seconds := 0.4) -> void:
	if Game.fast:
		fade.color.a = 1.0
		await get_tree().process_frame
		return
	await create_tween().tween_property(fade, "color:a", 1.0, seconds).finished


func fade_in(seconds := 0.4) -> void:
	if Game.fast:
		fade.color.a = 0.0
		await get_tree().process_frame
		return
	await create_tween().tween_property(fade, "color:a", 0.0, seconds).finished


## Großer Text auf schwarzem Grund (Zwischenschnitte).
func big_text(text: String, seconds: float) -> void:
	if Game.fast:
		print("[Zwischentitel] " + text)
		return
	big.text = text
	big.modulate.a = 0.0
	await create_tween().tween_property(big, "modulate:a", 1.0, 0.6).finished
	await wait_or_skip(seconds)
	await create_tween().tween_property(big, "modulate:a", 0.0, 0.6).finished
	big.text = ""


func flash(color: Color, times := 3) -> void:
	if Game.fast:
		return
	var tw := create_tween()
	for i in times:
		tw.tween_property(flash_rect, "color", Color(color, 0.45), 0.12)
		tw.tween_property(flash_rect, "color", Color(color, 0.0), 0.25)
	await tw.finished


# Menüs

## entries: Array von [Text, Callable]
func show_menu(entries: Array, title := false) -> void:
	for c in menu_box.get_children():
		c.queue_free()
	for e in entries:
		var b := Button.new()
		b.text = e[0]
		b.add_theme_font_size_override("font_size", 28)
		b.pressed.connect(e[1])
		menu_box.add_child(b)
	title_layer.visible = title
	bar.visible = not title
	menu_panel.visible = true
	menu_panel.reset_size()
	menu_panel.position = Vector2(W / 2 - 180, 400 if title else 260)


func hide_menu() -> void:
	menu_panel.visible = false
	title_layer.visible = false
	bar.visible = true


func menu_open() -> bool:
	return menu_panel.visible
