class_name Player
extends Node2D
## Martin: fünf Richtungen FR, FL, BR, BL, B (vorn/hinten dreiviertel rechts/links, hinten);
## die linken entstehen durch Spiegeln. Je Richtung Stand, Anlaufen, Laufzyklus und Anhalten; Drehen im Stand
## zwischen allen Richtungen (Videos vorwärts, rückwärts oder gespiegelt). Richtungswechsel unterwegs:
## Abbremsen, Drehen im Stand, Anlaufen.
## Bewegung nach Root Motion (rootmotion.json, je Bild gemessen am Standfuß im Video, in Körperhöhen): Ein Weg
## wird geplant als Anlaufen + n Laufzyklen + Anhalten und alles um denselben Faktor gestreckt, damit er genau
## ankommt (Bildtempo mit, in Grenzen). Übergänge passen am key-Bild des Zyklus (set.json): Anlaufen endet davor,
## Anhalten beginnt dort.
## Im Stand atmet er (Schleife); spricht er (talking) und ist das Gesicht zu sehen, läuft stattdessen die
## Sprech-Schleife. Gesten Nehmen/Benutzen in drei Höhen (gesture). Im Kälteanzug (set_suit) der Anzug-Satz
## des Figurensatzes, falls er einen hat.
## Herkunft: work/characters/<satz>/gen.json; der alte Martin liegt im Git-Tag martin1.
##
## Figurensatz = Verzeichnis assets/characters/<satz>/ und beschreibt sich selbst:
##   set.json: "anchor" Fußpunkt [x, y] und "body" Körperhöhe (Scheitel bis Sohle im Standbild) in Sprite-Pixeln,
##     optional "key" je Ansicht (Bild des Laufzyklus, an dem Anlaufen endet und Anhalten beginnt; sonst 0) und
##     "suit" (Satz für den Kälteanzug);
##   anims.json: Animationen und ihre Bildzahl (<anim>_NN.png); rootmotion.json: Weg je Bild, "dir" je Ansicht.
## Pflicht sind nur stand_<v> und walk_<v> für fr, br, b. Was fehlt, entfällt: ohne Anlaufen/Anhalten läuft er
## direkt los und bleibt stehen, ohne Drehvideo dreht er sich sofort, ohne Atmen/Sprechen/Geste das Standbild.
## Wählbare Sätze: SETS (martin2 vollständig, martin3 Test ohne Atmen, Sprechen, Gesten und Anzug); Umschalten im
## Cheatmenü (F10), gemerkt in user://player_set.

const SETS := ["martin2", "martin3"]
const ROOT := "res://assets/characters/"
const SET_FILE := "user://player_set"
const SHADOW := "res://assets/characters/shadow.png"
## gewählter Satz (normale Kleidung); DIR, ANCHOR, BODY_PX gelten für ihn (Layout-Editor, Animations-Debug)
static var SET := "martin2"
static var DIR: String
static var ANCHOR: Vector2
static var BODY_PX: float
## geladene Sätze: Name -> {name, dir, tex, rm, anchor, body, key, suit}
static var _bundles := {}
const FPS := 8.0
## Atmen im Stand: Schleife idle_<Richtung> (Bild 0 = Standbild), falls vorhanden
const IDLE_FPS := 12.0
## Grenzen für das Bildtempo, wenn ein Weg gestreckt wird
const TEMPO_MIN := 0.75
const TEMPO_MAX := 1.33
## Grenzwinkel des Weges nach hinten (Grad über der Waagerechten): vorn | schräg hinten | hinten; Hysterese
const VIEW_ANGLES := [22.0, 66.0]
const VIEW_HYST := 6.0
## kürzere Wege behalten die Richtung (Körperhöhen)
const MIN_LEN := 0.15
const SHADOW_SIZE := Vector2(204, 36)

var room: Room
var suit := false
var talking := false
var show_shadow := true
## aktuelle Richtung: "fr", "fl", "br", "bl", "b"
var facing := "fr"
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
var _token := 0
var _busy := false
var _moving := false


static func _static_init() -> void:
	var saved := FileAccess.get_file_as_string(SET_FILE).strip_edges() if FileAccess.file_exists(SET_FILE) else ""
	use_set(saved if saved in SETS else "martin2", false)


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
		"suit": s.get("suit", "")}
	_bundles[name] = b
	return b


func _init() -> void:
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


static func _mirror(d: String) -> String:
	if d == "b":
		return d
	return d.replace("r", "l") if d.ends_with("r") else d.replace("l", "r")


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
	_show(loop[int(_idle_t * IDLE_FPS) % loop.size()], facing.ends_with("l"))


## Bildfolge einer Drehung im Stand von a nach b aus den vorhandenen Videos turn_<von>_<nach> (vorwärts,
## rückwärts und/oder gespiegelt): [Animation, rückwärts, gespiegelt]; [] ohne passendes Video
func _turn_clip(a: String, b: String) -> Array:
	for m in [false, true]:
		var x := _mirror(a) if m else a
		var y := _mirror(b) if m else b
		if _tex.has("turn_%s_%s" % [x, y]):
			return ["turn_%s_%s" % [x, y], false, m]
		if _tex.has("turn_%s_%s" % [y, x]):
			return ["turn_%s_%s" % [y, x], true, m]
	return []


## Spielt eine Animation ab und bewegt ihn dabei nach ihrer Root Motion, gleichmäßig über die Dauer jedes Bildes.
## heading: Laufrichtung (Weg je Bild entlang heading, mal k); Vector2.ZERO: die gemessenen 2D-Vektoren
## (Drehen im Stand). order: Bildreihenfolge (Standard: alle der Reihe nach). false bei stop() oder, wenn
## abortable, bei einem neuen Befehl.
func _play(anim: String, flip: bool, reverse := false, heading := Vector2.ZERO, k := 1.0, abortable := true,
		order := []) -> bool:
	var my := _token
	var frames: Array = _tex[anim]
	var rm: Dictionary = _rm.get(anim, {})
	var idx: Array = order if not order.is_empty() else range(frames.size())
	if reverse:
		idx.reverse()
	var dur := 1.0 / (FPS * clampf(k, TEMPO_MIN, TEMPO_MAX))
	for i in idx:
		_show(frames[i], flip)
		var step := Vector2.ZERO
		if not rm.is_empty():
			if heading != Vector2.ZERO:
				step = heading * float(rm["d"][i]) * k
			else:
				var v: Array = rm["v"][i]
				step = Vector2(-v[0] if flip else v[0], v[1]) * (-1.0 if reverse else 1.0)
		var t := 0.0
		while t < dur:
			await get_tree().process_frame
			var dt := minf(get_process_delta_time(), dur - t)
			t += dt
			position += step * room.height_at(position.y) * dt / dur
			update_scale()
		if _halt or (abortable and my != _token):
			return false
	return true


## Dreht ihn im Stand nach d; false, wenn währenddessen ein neuer Befehl kam.
func turn_to(d: String, abortable := true) -> bool:
	if d == facing:
		return true
	var clip := _turn_clip(facing, d)
	if Game.fast or clip.is_empty():
		facing = d
		_show_stand()
		return true
	_busy = true
	var ok: bool = await _play(clip[0], clip[2], clip[1], Vector2.ZERO, 1.0, abortable)
	facing = d
	_busy = false
	_show_stand()
	return ok


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
	_busy = true
	var my := _token
	var flip := facing.ends_with("l")
	for tex in _tex[anim]:
		_show(tex, flip)
		await get_tree().create_timer(1.0 / IDLE_FPS).timeout
		if my != _token:
			break
	_busy = false
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


func stop() -> void:
	_token += 1
	if _moving:
		_halt = true
	_busy = false
	_show_stand()


## Richtung für den Weg v; h = Körperhöhe an der Stelle. Nach unten und flach: vorn, steiler: schräg hinten, hinten.
func _dir_for(v: Vector2, h: float) -> String:
	if v.length() < MIN_LEN * h:
		return facing
	var side := "r" if v.x > 0 else "l"
	if absf(v.x) < 0.2 * absf(v.y) and facing != "b":
		side = facing.substr(1)  # fast senkrecht: Seite behalten
	if v.y >= 0.0:
		return "f" + side
	var a := rad_to_deg(atan2(-v.y, absf(v.x)))
	var cur := 0 if facing.begins_with("f") else (2 if facing == "b" else 1)
	var b1: float = VIEW_ANGLES[0] + (-VIEW_HYST if cur >= 1 else VIEW_HYST)
	var b2: float = VIEW_ANGLES[1] + (-VIEW_HYST if cur == 2 else VIEW_HYST)
	return ("f" + side) if a < b1 else (("b" + side) if a < b2 else "b")


## Läuft zum Punkt: Drehen im Stand in die Laufrichtung, Anlaufen, n Laufzyklen, Anhalten.
## Ein neues Ziel während des Laufens übernimmt die laufende Schleife: gleiche Richtung wird neu geplant,
## sonst Abbremsen, Drehen, Anlaufen. false, wenn ein neuer Befehl (neues Ziel, stop) diesen Weg ablöst.
func walk_to(target: Vector2) -> bool:
	_token += 1
	var my := _token
	_target = room.clamp_to_floor(target)
	if Game.fast:
		position = _target
		update_scale()
		await get_tree().process_frame
		return true
	if _moving and not _halt:
		# die laufende Schleife folgt dem neuen Ziel; warten, bis sie ankommt
		while _moving and my == _token:
			await get_tree().process_frame
		return my == _token
	# nach stop(): erst die alte Schleife auslaufen lassen
	while (_busy or _moving) and my == _token:
		await get_tree().process_frame
	if my != _token or (_target - position).length() < 1.0:
		return my == _token
	_halt = false
	_moving = true
	await _walk_loop()
	_moving = false
	_halt = false
	_show_stand()
	return my == _token


## Anzahl Laufzyklen n und Streckfaktor k für den Restweg: base + n * cycle = rest / k, k möglichst nahe 1
static func _plan(rest: float, base: float, cycle: float) -> Array:
	# ohne Anlaufen/Anhalten (base 0) mindestens ein Zyklus
	var best := [0, rest / base] if base > 0.0 else [1, rest / cycle]
	for n in [floori((rest - base) / cycle), ceili((rest - base) / cycle)]:
		if n >= (0 if base > 0.0 else 1):
			var k: float = rest / (base + n * cycle)
			if absf(log(k)) < absf(log(best[1])):
				best = [n, k]
	return best


## gesamter Weg einer Animation (Körperhöhen); 0, wenn es sie nicht gibt
func _sum(anim: String) -> float:
	var s := 0.0
	if not _tex.has(anim):
		return s
	for x in _rm[anim]["d"]:
		s += float(x)
	return s


## Restweg in Körperhöhen (an der aktuellen Stelle gemessen)
func _rest() -> float:
	return (_target - position).length() / room.height_at(position.y)


func _walk_loop() -> void:
	while not _halt:
		var want := _dir_for(_target - position, room.height_at(position.y))
		if _rest() * room.height_at(position.y) < 1.0:
			break
		if want != facing:
			await turn_to(want, false)
			# während der Drehung kann ein neues Ziel gekommen sein: Richtung neu prüfen
			continue
		var view := _base(facing)
		var flip := facing.ends_with("l")
		var goal := _target
		var heading := (goal - position).normalized()
		# Anlaufen und Anhalten nur, wenn der Satz sie hat
		var has_start := _tex.has("start_" + view)
		var has_stop := _tex.has("stop_" + view)
		var s_len := _sum("start_" + view)
		var c_len := _sum("walk_" + view)
		var p_len := _sum("stop_" + view)
		var rest := _rest()
		var plan := _plan(rest, s_len + p_len, c_len)
		var n: int = plan[0]
		var k: float = plan[1]
		if has_start:
			await _play("start_" + view, flip, false, heading, k, false)
		# Laufzyklen von key bis vor key; an jeder Grenze neu planen
		var key: int = int(_b["key"].get(view, 0))
		var cycle := []
		var n_cycle: int = _tex["walk_" + view].size()
		for f in n_cycle:
			cycle.append((key + f) % n_cycle)
		var turn_needed := false
		while not _halt:
			rest = _rest()
			if _target != goal:
				# neues Ziel: andere Richtung -> abbremsen und neu anlaufen; sonst neu planen
				if _dir_for(_target - position, room.height_at(position.y)) != facing:
					turn_needed = true
					break
				goal = _target
			# Richtung an jeder Zyklusgrenze neu: mit der Tiefe ändert sich die Schrittlänge, sonst liefe er vorbei
			heading = (goal - position).normalized()
			# ohne Anhalten: unter einem Zehntel Zyklus Rest am Ziel
			if not has_stop and rest < 0.1 * c_len:
				break
			plan = _plan(rest, p_len, c_len)
			n = plan[0]
			k = plan[1]
			if n == 0:
				break
			await _play("walk_" + view, flip, false, heading, k, false, cycle)
		if _halt:
			break
		if has_stop:
			if not turn_needed:
				k = _rest() / p_len if p_len > 0.0 else 1.0
			await _play("stop_" + view, flip, false, heading, k, false)
		if not turn_needed and _target == goal:
			position = goal
			update_scale()
			break


var _target := Vector2.ZERO
## stop(): Laufschleife sofort beenden
var _halt := false
## Zeit in der Atem-Schleife (beginnt nach jeder Bewegung wieder beim Standbild)
var _idle_t := 0.0
var _was_talking := false
