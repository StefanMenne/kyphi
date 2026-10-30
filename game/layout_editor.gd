class_name LayoutEditor
extends Node2D
## Entwicklermodus (F9, nur in Debug-Builds): Lauffläche, Tiefe, Eingänge, Hotspot-Bereiche und Laufpunkte
## und verschiebbare Sprites des aktuellen Raums anzeigen und mit der Maus bearbeiten; Strg+S schreibt
## game/rooms/<id>.json.

const HANDLE := 7.0
const HELP := "Entwicklermodus (F9 beendet)   Strg+S speichern   Strg+R neu laden   A/D oder ←/→ Kamera\n" + \
	"Ecken, Laufpunkte (blau), Eingänge (violett), Tiefe (links) ziehen   Hotspot anklicken: verschieben, " + \
	"Ecken ändern\nSprites (rosa Marke oben links) ziehen   Doppelklick auf Kante: Ecke einfügen   Rechtsklick auf Ecke: löschen   " + \
	"Mausrad an Tiefenmarke: Figurhöhe"

var main: Node
var room: Room
var active := false
var _selected = null
var _drag := {}
var _dirty := false
var _info: Label
var _layer := CanvasLayer.new()
var _ghost: Texture2D


func _init(owner_main: Node) -> void:
	main = owner_main
	z_index = 100
	visible = false


func _ready() -> void:
	_layer.layer = 20
	_layer.visible = false
	add_child(_layer)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.position = Vector2(0, 0)
	bg.size = Vector2(1344, 92)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(bg)
	_info = Label.new()
	_info.position = Vector2(10, 6)
	_info.add_theme_font_size_override("font_size", 15)
	_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_info)
	_ghost = load("res://assets/characters/martin/right_idle.png")


func toggle() -> void:
	active = not active
	visible = active
	_layer.visible = active
	_selected = null
	_drag = {}


func _process(dt: float) -> void:
	if not active:
		return
	room = main.room
	if room == null:
		return
	transform = room.transform
	var scroll := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A):
		scroll -= 1.0
	if Input.is_key_pressed(KEY_D):
		scroll += 1.0
	var cam: Camera2D = main.camera
	var w := get_viewport().get_visible_rect().size.x
	cam.position.x = clampf(cam.position.x + scroll * 900.0 * dt, 0, maxf(0, cam.limit_right - w))
	var m := _mouse()
	var hs: Variant = room.hotspot_at(m)
	_info.text = HELP + "\n%s  x %d  y %d  Figurhöhe %d%s%s" % [room.id, m.x, m.y, room.height_at(m.y),
		("   Hotspot: " + hs["id"]) if hs else "", "   * ungespeichert" if _dirty else ""]
	queue_redraw()


func _mouse() -> Vector2:
	return get_local_mouse_position()


## Greifradius in Raumpixeln (Handles sind auf dem Bildschirm gleich groß)
func _r() -> float:
	return HANDLE * 1.6 / room.scale.x


func _draw() -> void:
	if not active or room == null:
		return
	var k := 1.0 / room.scale.x
	# Lauffläche
	if room.floor_poly.size() >= 3:
		draw_colored_polygon(room.floor_poly, Color(0.2, 1, 0.3, 0.15))
	var closed := room.floor_poly.duplicate()
	closed.append(room.floor_poly[0])
	draw_polyline(closed, Color(0.2, 1, 0.3), 2 * k)
	for p in room.floor_poly:
		_handle(p, Color(0.2, 1, 0.3), k)
	# Tiefe: Marken links (Fußhöhe) mit Balken in Figurhöhe
	for i in 2:
		var p := _depth_handle(i)
		var h: float = room.depth[i].y
		draw_line(p - Vector2(20 * k, 0), p + Vector2(40 * k, 0), Color(1, 0.6, 0.1), 2 * k)
		draw_rect(Rect2(p + Vector2(14 * k, -h), Vector2(10 * k, h)), Color(1, 0.6, 0.1, 0.5))
		_handle(p, Color(1, 0.6, 0.1), k)
	# Hotspots
	for hs in room.hotspots:
		var r: Rect2 = hs["area"]
		var sel: bool = hs == _selected
		var c := Color(1, 0.9, 0.2) if sel else Color(1, 0.9, 0.2, 0.6)
		draw_rect(r, Color(c, 0.12 if sel else 0.05))
		draw_rect(r, c, false, (3 if sel else 1.5) * k)
		_text(r.position + Vector2(4, 16) * k, hs["id"], c, k)
		draw_line(r.get_center(), hs["walk"], Color(0.3, 0.7, 1, 0.5 if sel else 0.2), 1.5 * k)
		draw_circle(hs["walk"], (6 if sel else 4) * k, Color(0.3, 0.7, 1))
		if sel:
			for p in _corners(r):
				_handle(p, c, k)
	# verschiebbare Sprites; ausgeblendete halbtransparent
	for sid in room.movables:
		var sp: Sprite2D = room.movables[sid]
		var r := _sprite_rect(sp)
		if not sp.visible:
			draw_texture(sp.texture, sp.position, Color(1, 1, 1, 0.4))
		draw_rect(r, Color(1, 0.4, 0.7), false, 2 * k)
		_handle(sp.position, Color(1, 0.4, 0.7), k)
		_text(sp.position + Vector2(10, -8) * k, "Sprite " + sid, Color(1, 0.4, 0.7), k)
	# Eingänge
	for key in room.entries:
		var p: Vector2 = room.entries[key][0]
		var s := 8 * k
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s),
			p + Vector2(-s, 0)]), Color(0.85, 0.3, 1))
		_text(p + Vector2(10, 5) * k, key if key != "" else "Start", Color(0.85, 0.3, 1), k)
	# Martin in der Größe an der Mausposition
	var m := _mouse()
	var h := room.height_at(m.y)
	if h < 20.0:
		return
	var sc := h / Player.BODY_PX
	draw_set_transform(m - Player.ANCHOR * sc, 0, Vector2(sc, sc))
	draw_texture(_ghost, Vector2.ZERO, Color(1, 1, 1, 0.35))
	draw_set_transform(Vector2.ZERO)


func _text(p: Vector2, t: String, c: Color, k: float) -> void:
	var font := ThemeDB.fallback_font
	draw_string_outline(font, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, int(15 * k), int(4 * k), Color(0, 0, 0, 0.8))
	draw_string(font, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, int(15 * k), Color(c, 1))


func _handle(p: Vector2, c: Color, k: float) -> void:
	var s := HANDLE * k
	draw_rect(Rect2(p - Vector2(s, s), Vector2(2 * s, 2 * s)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(p - Vector2(s, s), Vector2(2 * s, 2 * s)), c, false, 2 * k)


func _sprite_rect(sp: Sprite2D) -> Rect2:
	return Rect2(sp.position, sp.texture.get_size() * sp.scale)


func _corners(r: Rect2) -> Array:
	return [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]


## Marke der Tiefe i: am linken Bildschirmrand auf ihrer Fußhöhe
func _depth_handle(i: int) -> Vector2:
	return Vector2((main.camera.position.x + 30.0) / room.scale.x, room.depth[i].x)


func _unhandled_input(event: InputEvent) -> void:
	if not active or room == null:
		return
	if event is InputEventKey and event.pressed and event.ctrl_pressed:
		if event.keycode == KEY_S:
			room.save_layout()
			_dirty = false
			print("Layout gespeichert: ", room.layout_path())
		elif event.keycode == KEY_R:
			room.load_layout()
			_selected = null
			_dirty = false
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton:
		_on_button(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and not _drag.is_empty():
		_on_drag(_mouse())
		get_viewport().set_input_as_handled()


func _on_button(e: InputEventMouseButton) -> void:
	var m := _mouse()
	var r := _r()
	if e.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and e.pressed:
		for i in 2:
			if m.distance_to(_depth_handle(i)) < r * 2:
				var d: Vector2 = room.depth[i]
				d.y += 5.0 if e.button_index == MOUSE_BUTTON_WHEEL_UP else -5.0
				room.depth[i] = d
				_dirty = true
		return
	if e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
		var i := _floor_vertex(m)
		if i >= 0 and room.floor_poly.size() > 3:
			var fp := room.floor_poly
			fp.remove_at(i)
			room.floor_poly = fp
			_dirty = true
		return
	if e.button_index != MOUSE_BUTTON_LEFT:
		return
	if not e.pressed:
		_drag = {}
		return
	if e.double_click:
		_insert_vertex(m)
		return
	_drag = _pick(m)
	if _drag.has("hs"):
		_selected = _drag["hs"]
	elif _drag.is_empty():
		_selected = null


## Was unter der Maus liegt, in dieser Reihenfolge: Ecken des gewählten Hotspots, Sprite-Marken, Laufpunkte,
## Eingänge, Tiefenmarken, Ecken der Lauffläche, Hotspot-Bereiche (oberster zuerst).
func _pick(m: Vector2) -> Dictionary:
	var r := _r()
	if _selected:
		var cs := _corners(_selected["area"])
		for i in 4:
			if m.distance_to(cs[i]) < r:
				return {"kind": "corner", "hs": _selected, "fixed": cs[(i + 2) % 4]}
	for sid in room.movables:
		var sp: Sprite2D = room.movables[sid]
		if m.distance_to(sp.position) < r:
			return {"kind": "sprite", "sid": sid, "offset": sp.position - m}
	for hs in room.hotspots:
		if m.distance_to(hs["walk"]) < r:
			return {"kind": "walk", "hs": hs}
	for key in room.entries:
		if m.distance_to(room.entries[key][0]) < r:
			return {"kind": "entry", "key": key}
	for i in 2:
		if m.distance_to(_depth_handle(i)) < r:
			return {"kind": "depth", "i": i}
	var v := _floor_vertex(m)
	if v >= 0:
		return {"kind": "floor", "i": v}
	var hs: Variant = room.hotspot_at(m)
	if hs:
		return {"kind": "rect", "hs": hs, "offset": (hs["area"] as Rect2).position - m}
	return {}


func _floor_vertex(m: Vector2) -> int:
	for i in room.floor_poly.size():
		if m.distance_to(room.floor_poly[i]) < _r():
			return i
	return -1


func _insert_vertex(m: Vector2) -> void:
	var fp := room.floor_poly
	for i in fp.size():
		var a := fp[i]
		var b := fp[(i + 1) % fp.size()]
		if m.distance_to(Geometry2D.get_closest_point_to_segment(m, a, b)) < _r():
			fp.insert(i + 1, m.round())
			room.floor_poly = fp
			_dirty = true
			return


func _on_drag(m: Vector2) -> void:
	m = m.round()
	match _drag["kind"]:
		"corner":
			_drag["hs"]["area"] = Rect2(_drag["fixed"], Vector2.ZERO).expand(m)
		"rect":
			var a: Rect2 = _drag["hs"]["area"]
			a.position = (m + _drag["offset"]).round()
			_drag["hs"]["area"] = a
		"sprite":
			# ein Hotspot gleicher id zieht mit
			var sp: Sprite2D = room.movables[_drag["sid"]]
			var to: Vector2 = (m + _drag["offset"]).round()
			var hs = room.find_hotspot(_drag["sid"])
			if hs:
				var a: Rect2 = hs["area"]
				a.position += to - sp.position
				hs["area"] = a
			sp.position = to
		"walk":
			_drag["hs"]["walk"] = m
		"entry":
			room.entries[_drag["key"]][0] = m
		"depth":
			var d: Vector2 = room.depth[_drag["i"]]
			d.x = m.y
			room.depth[_drag["i"]] = d
		"floor":
			var fp := room.floor_poly
			fp[_drag["i"]] = m
			room.floor_poly = fp
	_dirty = true
