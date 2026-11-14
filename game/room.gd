class_name Room
extends Node2D
## Basis aller Schauplätze: Hintergrund und Ebenen aus dem Katalog, Hotspots, Laufbereich.
## Alle Koordinaten sind Pixel des Hintergrundbilds. Die Geometrie (Laufflächen, Tiefe, Verbindungsstrecken,
## Eingänge, Bereiche und Laufpunkte der Hotspots, Position verschiebbarer Sprites) steht in game/rooms/<id>.json und
## lässt sich im Entwicklermodus (F9) bearbeiten.
##
## Laufflächen: Meist eine („floor“ und „depth“ in der JSON-Datei, hier die Fläche „main“). Räume mit mehreren
## Ebenen (Bahnhof der Innenerde, Luftschacht) haben „areas“: je Fläche ein Polygon und eine eigene Tiefe, und
## „links“: Verbindungsstrecken (Treppenläufe, Schächte) als Linienzug von Fläche a nach Fläche b, mit einer
## Figurhöhe je Punkt. Martin sucht den kürzesten Weg über Flächen und Strecken (route); seine Größe folgt der
## Fläche oder Strecke, auf der er gerade ist (cur_area, cur_link).

const LOOK_FAIL := ["Nichts Besonderes.", "Sieht aus wie immer."]
const USE_FAIL := ["Das bringt mir nichts.", "Lieber nicht.", "Nein."]
const ITEM_FAIL := ["Das passt nicht zusammen.", "Damit komme ich nicht weiter.", "Nein."]

var id := ""
## Verzeichnis unter assets/scenes
var asset_dir := ""
var bg_size := Vector2.ZERO
## Laufflächen: id -> {"poly": PackedVector2Array, "depth": [Vector2(y, Höhe) hinten, Vector2(y, Höhe) vorn]}
var areas := {"main": {"poly": PackedVector2Array(), "depth": [Vector2(400, 300), Vector2(768, 500)]}}
## Verbindungsstrecken: [{"a": Fläche, "b": Fläche, "points": PackedVector2Array (von a nach b), "heights": Array}]
var links: Array = []
## Wo Martin gerade ist (für seine Größe): Fläche, oder Strecke (Index in links, sonst -1)
var cur_area := "main"
var cur_link := -1
## Fläche, die der Layout-Editor gerade bearbeitet (floor_poly, depth)
var edit_area := "main"
## Polygon und Tiefe der bearbeiteten Fläche (bei einer Fläche: die Lauffläche des Raums)
var floor_poly: PackedVector2Array:
	get:
		return areas[edit_area]["poly"]
	set(v):
		areas[edit_area]["poly"] = v
## Figurhöhe in Pixeln abhängig von der Fußhöhe: [Vector2(y, Höhe) hinten, Vector2(y, Höhe) vorn]
var depth: Array:
	get:
		return areas[edit_area]["depth"]
	set(v):
		areas[edit_area]["depth"] = v
## Herkunftsraum -> [Position, Blickrichtung, Tür-Ebene oder ""]; "" ist der Start
var entries := {}
## Tönung von Martin, nach dem Licht der Szene
var tint := Color.WHITE
## Martin ist in diesem Raum zu sehen (im Zugabteil nicht)
var show_player := true
## Martin trägt hier den Kälteanzug (draußen in der Antarktis)
var suit := false
## Deckkraft von Martins Schatten, nach dem Licht der Szene
var shadow_alpha := 0.6
var hotspots: Array = []
var layers := {}
## verschiebbare Sprites: id -> Sprite2D (Position aus dem Layout; ein Hotspot gleicher id zieht im Editor mit)
var movables := {}
## einfache Figuren dieses Raums (add_npc): Name -> Npc
var npcs := {}


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
	load_layout()
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


func movable(sid: String, s: Sprite2D) -> void:
	movables[sid] = s


## Einfache Figur npc_id (Npc) hinter alle Ebenen außer dem Hintergrund legen, im Layout-Editor verschiebbar;
## Untertitel-Punkt und Sprechen übernimmt der Raum (speaker_anchor, set_talking).
func add_npc(npc_id: String, extra: Array = []) -> Npc:
	var n := Npc.new(npc_id, extra)
	add_child(n)
	movable(npc_id, n)
	move_child(n, 1)
	npcs[npc_id] = n
	return n


## Blickrichtung beim Benutzen ("left", "right", "back") steht mit dem Laufpunkt in game/rooms/<id>.json.
## gesture: "auto" (nach der Höhe der Hotspot-Mitte über den Füßen: "low" am Boden, "hip" bis Brusthöhe,
## "high" darüber), fest "low"/"hip"/"high" oder "none" (ohne Gegenstand keine Geste, z. B. Personen und
## offene Durchgänge)
func hotspot(hid: String, name: String, gesture := "auto") -> void:
	hotspots.append({"id": hid, "name": name, "area": Rect2(), "walk": Vector2.ZERO, "face": "back",
		"gesture": gesture, "verb": "use"})


## Verb im Aktionsmenü statt "use": hid -> "talk" oder "take" (nur Icon und Text, die Aktion bleibt use());
## "go" (Türen, Durchgänge) öffnet kein Menü, ein Klick geht direkt.
func set_verbs(verbs: Dictionary) -> void:
	for hid in verbs:
		find_hotspot(hid)["verb"] = verbs[hid]


## Geste beim Benutzen des Hotspots ("" = keine).
## Grenzen für die Höhe der Geste (Körperhöhen über den Füßen): darunter "low", darüber "high", dazwischen "hip"
const GESTURE_LOW := 0.25
const GESTURE_HIGH := 0.7


func gesture_for(hs: Dictionary, with_item: bool, feet: Vector2) -> String:
	if hs["gesture"] == "none" and not with_item:
		return ""
	if hs["gesture"] in ["low", "hip", "high"]:
		return hs["gesture"]
	# Höhe der Hotspot-Mitte über den Füßen in Körperhöhen
	var up := (feet.y - (hs["area"] as Rect2).get_center().y) / height_at(feet.y)
	return "low" if up < GESTURE_LOW else ("hip" if up < GESTURE_HIGH else "high")


func layout_path() -> String:
	return "res://game/rooms/%s.json" % id


func load_layout() -> void:
	apply_layout(JSON.parse_string(FileAccess.get_file_as_string(layout_path())))


static func _vec(p: Array) -> Vector2:
	return Vector2(p[0], p[1])


static func _poly(ps: Array) -> PackedVector2Array:
	var poly := PackedVector2Array()
	for p in ps:
		poly.append(_vec(p))
	return poly


## Geometrie aus einem Dictionary im Format von game/rooms/<id>.json übernehmen.
func apply_layout(d: Dictionary) -> void:
	areas = {}
	var src: Dictionary = d["areas"] if d.has("areas") else {"main": {"floor": d["floor"], "depth": d["depth"]}}
	for aid in src:
		var a: Dictionary = src[aid]
		areas[aid] = {"poly": _poly(a["floor"]), "depth": [_vec(a["depth"][0]), _vec(a["depth"][1])]}
	if not areas.has(edit_area):
		edit_area = areas.keys()[0]
	links = []
	for l in d.get("links", []):
		var pts := _poly(l["points"])
		var hs: Array = l.get("heights", [])
		# fehlende Höhen: an den Enden aus der Tiefe der Fläche, dazwischen linear
		if hs.size() != pts.size():
			hs = []
			var h0 := area_height(l["a"], pts[0].y)
			var h1 := area_height(l["b"], pts[-1].y)
			for i in pts.size():
				hs.append(lerpf(h0, h1, float(i) / maxf(1, pts.size() - 1)))
		links.append({"a": l["a"], "b": l["b"], "points": pts, "heights": hs.map(func(h): return float(h))})
	cur_area = areas.keys()[0]
	cur_link = -1
	entries = {}
	for k in d["entries"]:
		var e: Dictionary = d["entries"][k]
		entries[k] = [Vector2(e["pos"][0], e["pos"][1]), e["face"], e["door"]]
	var sprites: Dictionary = d.get("sprites", {})
	for sid in movables:
		if sid in sprites:
			movables[sid].position = Vector2(sprites[sid][0], sprites[sid][1])
		else:
			push_warning("Sprite %s fehlt in %s" % [sid, layout_path()])
	for hs in hotspots:
		var g = d["hotspots"].get(hs["id"])
		if g == null:
			# neu im Code: in der Bildmitte, im Entwicklermodus zu platzieren
			push_warning("Hotspot %s fehlt in %s" % [hs["id"], layout_path()])
			hs["area"] = Rect2(bg_size / 2 - Vector2(50, 50), Vector2(100, 100))
			hs["walk"] = bg_size / 2
			continue
		hs["area"] = Rect2(g["area"][0], g["area"][1], g["area"][2], g["area"][3])
		hs["walk"] = Vector2(g["walk"][0], g["walk"][1])
		hs["face"] = g.get("face", "back")


## Schreibt die aktuelle Geometrie zurück (ganzzahlig, ein Eintrag pro Zeile).
func save_layout() -> void:
	var v := func(p: Vector2) -> String: return "[%d, %d]" % [roundi(p.x), roundi(p.y)]
	var lines := ["{"]
	if areas.size() == 1 and areas.has("main") and links.is_empty():
		lines.append(' "floor": [%s],' % ", ".join(Array(areas["main"]["poly"]).map(v)))
		lines.append(' "depth": [%s],' % ", ".join(areas["main"]["depth"].map(v)))
	else:
		lines.append(' "areas": {')
		var al := []
		for aid in areas:
			al.append('  %s: {"floor": [%s], "depth": [%s]}' % [JSON.stringify(aid),
				", ".join(Array(areas[aid]["poly"]).map(v)), ", ".join(areas[aid]["depth"].map(v))])
		lines.append(",\n".join(al))
		lines.append(" },")
		lines.append(' "links": [')
		var ll := []
		for l in links:
			ll.append('  {"a": %s, "b": %s, "points": [%s], "heights": [%s]}' % [JSON.stringify(l["a"]),
				JSON.stringify(l["b"]), ", ".join(Array(l["points"]).map(v)),
				", ".join(l["heights"].map(func(h): return str(roundi(h))))])
		lines.append(",\n".join(ll))
		lines.append(" ],")
	lines.append(' "entries": {')
	var es := []
	for k in entries:
		var e: Array = entries[k]
		es.append('  %s: {"pos": %s, "face": %s, "door": %s}' % [
			JSON.stringify(k), v.call(e[0]), JSON.stringify(e[1]), JSON.stringify(e[2])])
	lines.append(",\n".join(es))
	lines.append(" },")
	if not movables.is_empty():
		var ss := []
		for sid in movables:
			ss.append("%s: %s" % [JSON.stringify(sid), v.call(movables[sid].position)])
		lines.append(' "sprites": {%s},' % ", ".join(ss))
	lines.append(' "hotspots": {')
	var hs_lines := []
	for hs in hotspots:
		var r: Rect2 = hs["area"]
		hs_lines.append('  %s: {"area": [%d, %d, %d, %d], "walk": %s, "face": %s}' % [JSON.stringify(hs["id"]),
			roundi(r.position.x), roundi(r.position.y), roundi(r.size.x), roundi(r.size.y), v.call(hs["walk"]),
			JSON.stringify(hs["face"])])
	lines.append(",\n".join(hs_lines))
	lines.append(" }")
	lines.append("}")
	var f := FileAccess.open(ProjectSettings.globalize_path(layout_path()), FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")


func layer_rect(lid: String) -> Rect2:
	var s: Sprite2D = layers[lid]
	return Rect2(s.position, s.texture.get_size())


func is_active(_hid: String) -> bool:
	return true


func display_name(hs: Dictionary) -> String:
	return hs["name"]


func find_hotspot(hid: String) -> Variant:
	for hs in hotspots:
		if hs["id"] == hid:
			return hs
	return null


func hotspot_at(p: Vector2) -> Variant:
	for i in range(hotspots.size() - 1, -1, -1):
		var hs: Dictionary = hotspots[i]
		if not is_active(hs["id"]):
			continue
		if (hs["area"] as Rect2).has_point(p):
			return hs
	return null


## Figurhöhe an der Fußhöhe y auf der Fläche, auf der Martin gerade ist.
func height_at(y: float) -> float:
	return area_height(cur_area, y)


func area_height(aid: String, y: float) -> float:
	var dp: Array = areas[aid]["depth"]
	if is_equal_approx(dp[0].x, dp[1].x):
		return dp[0].y
	return lerpf(dp[0].y, dp[1].y, (y - dp[0].x) / (dp[1].x - dp[0].x))


## Figurhöhe an der Stelle p: auf einer Strecke nach dem nächsten Punkt des Linienzugs, sonst nach der Fläche.
func height_for(p: Vector2) -> float:
	if cur_link >= 0:
		return link_height(cur_link, p)
	return area_height(cur_area, p.y)


func link_height(li: int, p: Vector2) -> float:
	var l: Dictionary = links[li]
	var pts: PackedVector2Array = l["points"]
	var best := INF
	var h: float = l["heights"][0]
	for i in pts.size() - 1:
		var q := Geometry2D.get_closest_point_to_segment(p, pts[i], pts[i + 1])
		if q.distance_to(p) < best:
			best = q.distance_to(p)
			var seg := pts[i].distance_to(pts[i + 1])
			var t := pts[i].distance_to(q) / seg if seg > 0.0 else 0.0
			h = lerpf(l["heights"][i], l["heights"][i + 1], t)
	return h


static func _clamp_poly(p: Vector2, poly: PackedVector2Array) -> Vector2:
	if poly.is_empty() or Geometry2D.is_point_in_polygon(p, poly):
		return p
	var best := p
	var best_d := INF
	for i in poly.size():
		var q := Geometry2D.get_closest_point_to_segment(p, poly[i], poly[(i + 1) % poly.size()])
		if q.distance_to(p) < best_d:
			best_d = q.distance_to(p)
			best = q
	return best


## Fläche, in der p liegt, sonst die nächste.
func area_of(p: Vector2) -> String:
	var best := ""
	var best_d := INF
	for aid in areas:
		var d := _clamp_poly(p, areas[aid]["poly"]).distance_to(p)
		if d < best_d:
			best_d = d
			best = aid
	return best


## Auf die nächste Lauffläche.
func clamp_to_floor(p: Vector2) -> Vector2:
	return _clamp_poly(p, areas[area_of(p)]["poly"])


## Martin steht an p (nach Raumwechsel, Doppelklick auf Türen): Fläche neu bestimmen.
func set_location(p: Vector2) -> void:
	cur_area = area_of(p)
	cur_link = -1


static func _path_len(pts: Array) -> float:
	var s := 0.0
	for i in pts.size() - 1:
		s += (pts[i] as Vector2).distance_to(pts[i + 1])
	return s


## Teil des Linienzugs einer Strecke von p (auf der Strecke) bis zum Ende a (to_b false) oder b (to_b true).
func _link_part(li: int, p: Vector2, to_b: bool) -> Array:
	var pts: PackedVector2Array = links[li]["points"]
	var best := INF
	var seg := 0
	for i in pts.size() - 1:
		var d := Geometry2D.get_closest_point_to_segment(p, pts[i], pts[i + 1]).distance_to(p)
		if d < best:
			best = d
			seg = i
	var out := [p]
	if to_b:
		for i in range(seg + 1, pts.size()):
			out.append(pts[i])
	else:
		for i in range(seg, -1, -1):
			out.append(pts[i])
	return out


## Weg von Martins Standort (cur_area/cur_link, Position from) zum Ziel goal (wird auf eine Fläche gesetzt):
## Abschnitte [{"points": [Vector2 ...], "area": Fläche oder "", "link": Index oder -1}], kürzester Weg über die
## Enden der Strecken (Dijkstra). Ohne Strecken ein Abschnitt in gerader Linie.
func route(from: Vector2, goal: Vector2) -> Array:
	var gaid := area_of(goal)
	goal = _clamp_poly(goal, areas[gaid]["poly"])
	if links.is_empty() or (cur_link < 0 and cur_area == gaid):
		return [{"points": [goal], "area": gaid, "link": -1}]
	# Knoten: 0 Start, 1 Ziel, dann je Strecke ihr Anfang (a) und Ende (b)
	var pos := [from, goal]
	var area := [cur_area if cur_link < 0 else "", gaid]
	for l in links:
		pos.append(l["points"][0])
		area.append(l["a"])
		pos.append(l["points"][-1])
		area.append(l["b"])
	var n := pos.size()
	# Kanten: [nach, Länge, Abschnitt]
	var edges := []
	for i in n:
		edges.append([])
	var add := func(i: int, j: int, w: float, leg: Dictionary) -> void:
		edges[i].append([j, w, leg])
	for i in n:
		for j in n:
			if i != j and j != 0 and area[i] != "" and area[i] == area[j]:
				add.call(i, j, (pos[i] as Vector2).distance_to(pos[j]), {"points": [pos[j]], "area": area[i], "link": -1})
	for li in links.size():
		var pts := Array(links[li]["points"])
		var a := 2 + li * 2
		var r := pts.duplicate()
		r.reverse()
		add.call(a, a + 1, _path_len(pts), {"points": pts.slice(1), "area": "", "link": li})
		add.call(a + 1, a, _path_len(pts), {"points": r.slice(1), "area": "", "link": li})
	if cur_link >= 0:
		var a := 2 + cur_link * 2
		for to_b in [false, true]:
			var part := _link_part(cur_link, from, to_b)
			add.call(0, a + (1 if to_b else 0), _path_len(part), {"points": part.slice(1), "area": "", "link": cur_link})
	# Dijkstra
	var dist := []
	var prev := []
	for i in n:
		dist.append(INF)
		prev.append(null)
	dist[0] = 0.0
	var open := range(n)
	while not open.is_empty():
		var u: int = open[0]
		for i in open:
			if dist[i] < dist[u]:
				u = i
		open.erase(u)
		if u == 1 or dist[u] == INF:
			break
		for e in edges[u]:
			var alt: float = dist[u] + e[1]
			if alt < dist[e[0]]:
				dist[e[0]] = alt
				prev[e[0]] = [u, e[2]]
	if prev[1] == null:
		return [{"points": [goal], "area": gaid, "link": -1}]
	var legs := []
	var v := 1
	while v != 0:
		legs.push_front(prev[v][1])
		v = prev[v][0]
	return legs


## Bildschirmpunkt für Untertitel einer Figur dieses Raums, sonst null.
func speaker_anchor(speaker: String):
	return npcs[speaker].speech_anchor() if npcs.has(speaker) else null


func set_talking(speaker: String, on: bool) -> void:
	if npcs.has(speaker):
		npcs[speaker].talking = on


# Interaktionen; die Räume überschreiben sie mit match und rufen für den Rest super() auf.

func look(_hid: String) -> void:
	await say(LOOK_FAIL.pick_random())


func use(_hid: String) -> void:
	await refuse(USE_FAIL.pick_random())


func use_item(_hid: String, _item: String) -> void:
	await refuse(ITEM_FAIL.pick_random())


func say(text: String, voice := "") -> void:
	await Game.say("martin", text, voice)


## Martin lehnt ab, ohne etwas zu tun: ohne Benutzen-/Nehmen-Geste.
func refuse(text: String, voice := "") -> void:
	Game.main.pending_gesture = ""
	await say(text, voice)


func narrate(text: String) -> void:
	await Game.say("", text)


## Gegenstand aus dem Raum aufnehmen; die Ebene blendet refresh() über das Flag aus.
func take(item: String, line := "") -> void:
	await Game.main.flush_gesture()
	Game.add_item(item)
	Game.set_flag("took_" + item)
	refresh()
	if line != "":
		await say(line)


## Raum verlassen, die Tür ist dabei kurz offen.
func go(room_id: String, door_layer := "") -> void:
	await Game.main.flush_gesture()
	if door_layer != "":
		layers[door_layer].visible = true
		await Game.wait(0.35)
	await Game.main.change_room(room_id, id)
