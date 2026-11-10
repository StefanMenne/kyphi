class_name Player
extends Node2D
## Martin: fünf Richtungen FR, FL, BR, BL, B (vorn/hinten dreiviertel rechts/links, hinten);
## die linken entstehen durch Spiegeln. Je Richtung Stand, Anlaufen, Laufzyklus und Anhalten; Drehen im Stand
## zwischen allen Richtungen (Videos vorwärts, rückwärts oder gespiegelt). Laufen und Drehen nach Root Motion
## (rootmotion.json, in Körperhöhen) steuert Walker (game/walker.gd, dieselbe Logik wie im Animationswerkzeug);
## der Player ist dessen host: Anzeige, Raum (Tiefe, Boden), Zeit.
## Im Stand atmet er (Schleife); spricht er (talking) und ist das Gesicht zu sehen, läuft stattdessen die
## Sprech-Schleife. Gesten Nehmen/Benutzen in drei Höhen (gesture). Im Kälteanzug (set_suit) der Anzug-Satz
## des Figurensatzes, falls er einen hat.
## Herkunft: work/characters/<satz>/gen.json; der alte Martin liegt im Git-Tag martin1.
##
## Figurensatz = Verzeichnis assets/characters/<satz>/ und beschreibt sich selbst:
##   set.json: "anchor" Fußpunkt [x, y] und "body" Körperhöhe (Scheitel bis Sohle im Standbild) in Sprite-Pixeln,
##     optional "key" je Ansicht (Bild des Laufzyklus, an dem Anlaufen endet und Anhalten beginnt; sonst 0) und
##     "suit" (Satz für den Kälteanzug), "walk" (Werte für das Laufen, siehe Walker);
##   anims.json: Animationen und ihre Bildzahl (<anim>_NN.png); rootmotion.json: Weg je Bild, "dir" je Ansicht.
## Pflicht sind nur stand_<v> und walk_<v> für fr, br, b. Was fehlt, entfällt: ohne Anlaufen/Anhalten läuft er
## direkt los und bleibt stehen, ohne Drehvideo dreht er sich sofort, ohne Atmen/Sprechen/Geste das Standbild.
## Wählbare Sätze: SETS (martin; Anzug martin_suit; Atmen nur FR, Anzug nur Laufen); bei mehreren Umschalten im
## Cheatmenü (F10), gemerkt in user://player_set. Frühere Sätze martin2, martin3: Git-Tag martin2-3.

const SETS := ["martin"]
const ROOT := "res://assets/characters/"
const SET_FILE := "user://player_set"
const SHADOW := "res://assets/characters/shadow.png"
## gewählter Satz (normale Kleidung); DIR, ANCHOR, BODY_PX gelten für ihn (Layout-Editor)
static var SET := "martin"
static var DIR: String
static var ANCHOR: Vector2
static var BODY_PX: float
## geladene Sätze: Name -> {name, dir, tex, rm, anchor, body, key, suit, walk}
static var _bundles := {}
const SHADOW_SIZE := Vector2(204, 36)

var room: Room
var suit := false
var talking := false
var show_shadow := true
var walker := Walker.new()
## aktuelle Richtung: "fr", "fl", "br", "bl", "b"
var facing: String:
	get:
		return walker.facing
	set(v):
		walker.facing = v
## "right" oder "left" (Seite der Richtung; für main.gd)
var dir: String:
	get:
		return "left" if facing.ends_with("l") else "right"

## aktueller Satz (normal oder Anzug) und seine Teile
var _b := {}
var _tex := {}
## Root Motion je Animation: {"d": [Weg je Bild], "v": [[x, y] je Bild]} in Körperhöhen
var _rm := {}
var _anchor := Vector2.ZERO
var _body := 1.0
var _sprite := Sprite2D.new()
var _shadow := Sprite2D.new()
var _busy: bool:
	get:
		return walker.busy
var _moving: bool:
	get:
		return walker.moving


static func _static_init() -> void:
	var saved := FileAccess.get_file_as_string(SET_FILE).strip_edges() if FileAccess.file_exists(SET_FILE) else ""
	use_set(saved if saved in SETS else SETS[0], false)


## Figurensatz wählen (wirkt für neue Player; ein bestehender lädt mit reload() neu); save: merken
static func use_set(name: String, save := true) -> void:
	SET = name
	DIR = ROOT + name + "/"
	var s: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "set.json"))
	ANCHOR = Vector2(s["anchor"][0], s["anchor"][1])
	BODY_PX = float(s["body"])
	if save:
		var f := FileAccess.open(SET_FILE, FileAccess.WRITE)
		if f:
			f.store_string(name)


## Satz name laden (einmal je Spiel): Bilder, Root Motion und set.json
static func bundle(name: String) -> Dictionary:
	if _bundles.has(name):
		return _bundles[name]
	var dir := ROOT + name + "/"
	var s: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(dir + "set.json"))
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(dir + "anims.json"))
	var tex := {}
	for anim in meta:
		var frames := []
		for i in int(meta[anim]["frames"]):
			frames.append(load(dir + "%s_%02d.png" % [anim, i]))
		tex[anim] = frames
	var b := {"name": name, "dir": dir, "tex": tex,
		"rm": JSON.parse_string(FileAccess.get_file_as_string(dir + "rootmotion.json")),
		"anchor": Vector2(s["anchor"][0], s["anchor"][1]), "body": float(s["body"]), "key": s.get("key", {}),
		"suit": s.get("suit", ""), "walk": Walker.params(s)}
	_bundles[name] = b
	return b


func _init() -> void:
	walker.host = self
	_use_bundle()
	_shadow.texture = load(SHADOW)
	_shadow.scale = SHADOW_SIZE / _shadow.texture.get_size()
	_shadow.position = Vector2(0, -12)
	add_child(_shadow)
	_sprite.centered = false
	add_child(_sprite)
	_show_stand()


## aktuellen Satz einstellen: im Kälteanzug der Anzug-Satz des gewählten Satzes, sonst (oder ohne) dieser
func _use_bundle() -> void:
	var b := bundle(SET)
	if suit and b["suit"] != "":
		b = bundle(b["suit"])
	_b = b
	walker.b = b
	_tex = b["tex"]
	_rm = b["rm"]
	_anchor = b["anchor"]
	_body = b["body"]


## nach use_set(): auf den neuen Satz umstellen
func reload() -> void:
	stop()
	_use_bundle()
	if room:
		update_scale()
	_show_stand()


static func _base(d: String) -> String:
	return d.replace("l", "r") if d != "b" else d


func _show(tex: Texture2D, flip: bool) -> void:
	_sprite.texture = tex
	_sprite.flip_h = flip
	_sprite.offset = -Vector2(tex.get_width() - _anchor.x if flip else _anchor.x, _anchor.y)


## Bild i einer Animation der Richtung d (anim = "walk", "start", "stop", "stand"); links gespiegelt
func _frame(anim: String, d: String, i: int) -> void:
	var frames: Array = _tex["%s_%s" % [anim, _base(d)]]
	_show(frames[i], d.ends_with("l"))


func _show_stand() -> void:
	_frame("stand", facing, 0)


func _process(dt: float) -> void:
	if _moving or _busy:
		_idle_t = 0.0
		return
	# beim Sprechen die Sprech-Schleife (nur wo es eine gibt, also mit sichtbarem Gesicht), sonst Atmen;
	# jede Schleife beginnt beim Standbild
	var talk: Array = _tex.get("talk_" + _base(facing), []) if talking else []
	var loop: Array = talk if not talk.is_empty() else _tex.get("idle_" + _base(facing), [])
	var is_talking := not talk.is_empty()
	if is_talking != _was_talking:
		_was_talking = is_talking
		_idle_t = 0.0
	if loop.is_empty():
		_show_stand()
		return
	_idle_t += dt
	_show(loop[int(_idle_t * float(_b["walk"]["idle_fps"])) % loop.size()], facing.ends_with("l"))


## Dreht ihn im Stand nach d; false, wenn währenddessen ein neuer Befehl kam.
func turn_to(d: String, abortable := true) -> bool:
	return await walker.turn_to(d, abortable)


## Läuft zum Punkt (Walker.walk_to); false, wenn ein neuer Befehl (neues Ziel, stop) diesen Weg ablöst.
func walk_to(target: Vector2) -> bool:
	return await walker.walk_to(target)


func stop() -> void:
	walker.stop()


# Walker-host: Anzeige, Raum, Zeit

func walk_show(tex: Texture2D, flip: bool) -> void:
	_show(tex, flip)


func walk_stand() -> void:
	_show_stand()


func walk_moved() -> void:
	update_scale()


func walk_height(y: float) -> float:
	return room.height_at(y)


func walk_clamp(p: Vector2) -> Vector2:
	return room.clamp_to_floor(p)


func walk_frame() -> float:
	await get_tree().process_frame
	return get_process_delta_time()


func walk_fast() -> bool:
	return Game.fast


## "left"/"right" = vorn dreiviertel links/rechts, "back" = von hinten, sonst bleibt die Richtung; instant ohne Drehung.
func face(d: String, instant := false) -> void:
	var want: String = {"left": "fl", "right": "fr", "back": "b"}.get(d, facing)
	if instant or Game.fast:
		facing = want
		_show_stand()
		return
	await turn_to(want)


## Kälteanzug an/aus: wechselt auf den Anzug-Satz (set.json "suit"); ohne einen bleibt er in normaler Kleidung.
func set_suit(on: bool) -> void:
	if on == suit:
		return
	suit = on
	_use_bundle()
	if room:
		update_scale()
	if not _moving and not _busy:
		_show_stand()


## Geste Nehmen/Benutzen in der Höhe kind ("low", "hip", "high"; alt: "pickup" = low, "use" = hip) und endet
## im Standbild. Vorn rechts/links (gespiegelt) oder von hinten; aus Schräg hinten dreht er sich dafür nach hinten.
func gesture(kind: String) -> void:
	kind = {"pickup": "low", "use": "hip"}.get(kind, kind)
	if Game.fast:
		return
	while (_busy or _moving) and is_inside_tree():
		await get_tree().process_frame
	if facing in ["br", "bl"]:
		if not await turn_to("b"):
			return
	var anim := "use_%s_%s" % [kind, "b" if facing == "b" else "fr"]
	if not _tex.has(anim):
		return
	walker.busy = true
	var my := walker.token
	var flip := facing.ends_with("l")
	for tex in _tex[anim]:
		_show(tex, flip)
		await get_tree().create_timer(1.0 / float(_b["walk"]["idle_fps"])).timeout
		if my != walker.token:
			break
	walker.busy = false
	_idle_t = 0.0
	_show_stand()


func update_scale() -> void:
	var k := room.height_at(position.y) / _body
	scale = Vector2(k, k)
	_shadow.visible = show_shadow
	_shadow.modulate.a = room.shadow_alpha
	_sprite.modulate = room.tint


func head_screen_pos() -> Vector2:
	return get_global_transform_with_canvas() * Vector2(0, -_body - 20)


## Zeit in der Atem-Schleife (beginnt nach jeder Bewegung wieder beim Standbild)
var _idle_t := 0.0
var _was_talking := false
