class_name Room
extends Node2D
## Basis aller Schauplätze: Hintergrund und Ebenen aus dem Katalog, Hotspots, Laufbereich.
## Alle Koordinaten sind Pixel des Hintergrundbilds.

const LOOK_FAIL := ["Nichts Besonderes.", "Sieht aus wie immer."]
const USE_FAIL := ["Das bringt mir nichts.", "Lieber nicht.", "Nein."]
const ITEM_FAIL := ["Das passt nicht zusammen.", "Damit komme ich nicht weiter.", "Nein."]

var id := ""
## Verzeichnis unter assets/scenes
var asset_dir := ""
var bg_size := Vector2.ZERO
var floor_poly := PackedVector2Array()
## Figurhöhe in Pixeln abhängig von der Fußhöhe: [Vector2(y, Höhe) hinten, Vector2(y, Höhe) vorn]
var depth := [Vector2(400, 300), Vector2(768, 500)]
## Herkunftsraum -> [Position, Blickrichtung, Tür-Ebene oder ""]; "" ist der Start
var entries := {}
## Tönung von Martin, nach dem Licht der Szene
var tint := Color.WHITE
## Deckkraft von Martins Schatten, nach dem Licht der Szene
var shadow_alpha := 0.6
var hotspots: Array = []
var layers := {}


func setup() -> void:
	var info: Dictionary = Game.catalog["scenes"][asset_dir]
	bg_size = Vector2(info["size"][0], info["size"][1])
	add_sprite(load("res://assets/" + info["background"]), Vector2.ZERO)
	for lid in info["layers"]:
		var l: Dictionary = info["layers"][lid]
		var s := add_sprite(load("res://assets/" + l["file"]), Vector2(l["x"], l["y"]))
		s.visible = false
		layers[lid] = s
	build()
	refresh()


func add_sprite(tex: Texture2D, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = pos
	add_child(s)
	return s


## Hotspots, Laufbereich und Eingänge festlegen.
func build() -> void:
	pass


## Ebenen nach dem Spielzustand ein- und ausblenden.
func refresh() -> void:
	pass


func on_enter(_from: String) -> void:
	pass


func hotspot(hid: String, name: String, area, walk: Vector2, face := "back") -> void:
	hotspots.append({"id": hid, "name": name, "area": area, "walk": walk, "face": face})


func layer_rect(lid: String) -> Rect2:
	var s: Sprite2D = layers[lid]
	return Rect2(s.position, s.texture.get_size())


func is_active(_hid: String) -> bool:
	return true


func display_name(hs: Dictionary) -> String:
	return hs["name"]


func find_hotspot(hid: String):
	for hs in hotspots:
		if hs["id"] == hid:
			return hs
	return null


func hotspot_at(p: Vector2):
	for i in range(hotspots.size() - 1, -1, -1):
		var hs: Dictionary = hotspots[i]
		if not is_active(hs["id"]):
			continue
		var a = hs["area"]
		if a is Rect2 and a.has_point(p):
			return hs
		if a is PackedVector2Array and Geometry2D.is_point_in_polygon(p, a):
			return hs
	return null


func height_at(y: float) -> float:
	var t: float = (y - depth[0].x) / (depth[1].x - depth[0].x)
	return lerpf(depth[0].y, depth[1].y, t)


func clamp_to_floor(p: Vector2) -> Vector2:
	if floor_poly.is_empty() or Geometry2D.is_point_in_polygon(p, floor_poly):
		return p
	var best := p
	var best_d := INF
	for i in floor_poly.size():
		var q := Geometry2D.get_closest_point_to_segment(p, floor_poly[i], floor_poly[(i + 1) % floor_poly.size()])
		if q.distance_to(p) < best_d:
			best_d = q.distance_to(p)
			best = q
	return best


## Bildschirmpunkt für Untertitel einer Figur dieses Raums, sonst null.
func speaker_anchor(_speaker: String):
	return null


func set_talking(_speaker: String, _on: bool) -> void:
	pass


# Interaktionen; die Räume überschreiben sie mit match und rufen für den Rest super() auf.

func look(_hid: String) -> void:
	await say(LOOK_FAIL.pick_random())


func use(_hid: String) -> void:
	await say(USE_FAIL.pick_random())


func use_item(_hid: String, _item: String) -> void:
	await say(ITEM_FAIL.pick_random())


func say(text: String, voice := "") -> void:
	await Game.say("martin", text, voice)


func narrate(text: String) -> void:
	await Game.say("", text)


## Gegenstand aus dem Raum aufnehmen; die Ebene blendet refresh() über das Flag aus.
func take(item: String, line := "") -> void:
	Game.add_item(item)
	Game.set_flag("took_" + item)
	refresh()
	if line != "":
		await say(line)


## Raum verlassen, die Tür ist dabei kurz offen.
func go(room_id: String, door_layer := "") -> void:
	if door_layer != "":
		layers[door_layer].visible = true
		await Game.wait(0.35)
	await Game.main.change_room(room_id, id)
