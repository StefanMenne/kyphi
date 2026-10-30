class_name Player
extends Node2D
## Martin: ein Laufzyklus in Dreiviertelansicht nach rechts, für links gespiegelt.
## Auch beim Laufen nach vorn und hinten bleibt er so ausgerichtet. Größe nach Tiefe im Raum.
## Beim Seitenwechsel dreht er sich über die Vorderseite (rechts -> links vorwärts, links -> rechts rückwärts).
## Aus dem Stand läuft er mit einem Anlauf los, der nahtlos in den Laufzyklus übergeht; angehalten wird bei
## einem Zyklusbild, das dem Stand nahekommt. Im Stand atmet er (Schleife); beim Sprechen bewegt sich der Mund.
## Auf Wegen in die Tiefe dreht er sich je nach Winkel schräg (45°) oder ganz in die Rückansicht (eigene
## Laufzyklen, für links gespiegelt); Drehungen gehen immer eine Stufe weiter (Seite <-> schräg <-> hinten).
## Gesten und Hotspot-Blickrichtungen nutzen immer die Seitenansicht.

## Mitte zwischen den Füßen und Körperhöhe in Pixeln
const ANCHOR := Vector2(135, 637)
const BODY_PX := 635.0
const FRAMES := 33
## Anlauf aus dem Stand; danach folgt Zyklusbild 0
const START_FRAMES := 33
## Zyklusbilder, die dem Stand am nächsten kommen (Füße beieinander)
const STOP_FRAMES := [8, 27]
## Ab so vielen Bildern Restweg wird die Bildfolge auf ein Haltebild hin angepasst
const STOP_PLAN := 20.0
## Weg des Standfußes pro Bild des Laufzyklus, in Körperhöhen (aus dem Video gemessen)
const STRIDE := 0.0137
## Körperhöhen pro Sekunde
const SPEED := 0.45
const TURN_FRAMES := 23
const TURN_FPS := 30.0
## Fußpunkt x in den Drehbildern: vom Standbild nach rechts bis zum gespiegelten Standbild
const TURN_ANCHOR_RIGHT := 149.7
const TURN_ANCHOR_LEFT := 135.7
## Atem-Schleife im Stand; Bild 0 entspricht dem Standbild
const IDLE_FRAMES := 48
const IDLE_FPS := 12.0
## Gesten (gleicher Fußpunkt wie das Standbild, Bild 0 und letztes Bild nahe am Standbild)
const GESTURES := {"use": 35, "pickup": 54}
const GESTURE_FPS := 30.0
## Ansichten in die Tiefe (1 = schräg von hinten, 2 = von hinten): Anker im eigenen Zuschnitt, Zyklus, Bild des
## Zyklus, das dem Standbild entspricht (dort beginnt der Lauf), Haltebilder relativ dazu, Weg pro Bild auf dem
## Bildschirm (kürzer als seitlich, weil die Tiefe verkürzt wirkt)
const VIEWS := {
	1: {"name": "diag", "anchor": Vector2(119, 653), "frames": 32, "idle": 2, "stops": [0, 23], "stride": 0.0115},
	2: {"name": "back", "anchor": Vector2(133, 649), "frames": 26, "idle": 12, "stops": [0], "stride": 0.0096},
}
## Drehungen Seite -> schräg und schräg -> hinten (rückwärts für die Gegenrichtung), Anker von/nach
const VIEW_TURNS := {
	1: {"name": "turn_diag", "frames": 12, "from": Vector2(135, 644), "to": Vector2(119, 653)},
	2: {"name": "turn_diag_back", "frames": 12, "from": Vector2(119, 653), "to": Vector2(133, 649)},
}
## Grenzwinkel des Weges nach hinten (Grad über der Waagerechten): Seite | schräg | hinten; Hysterese
const VIEW_ANGLES := [20.0, 55.0]
const VIEW_HYST := 6.0
## kürzere Wege bleiben in der Seitenansicht (Körperhöhen)
const VIEW_MIN_LEN := 0.12
## Tempo beim Auslaufen vor einer Drehung (relativ zum Gehen)
const SETTLE_RATE := 1.3
## Weicher Schatten unter den Füßen (Ellipse), Größe in Sprite-Pixeln
const SHADOW_SIZE := Vector2(402, 70)

var room: Room
## "right" oder "left"
var dir := "right"
var _idle: Texture2D
var _walk := []
var _turn := []
var _start := []
var _idle_loop := []
var _talk := []
## spricht gerade (setzt main.say)
var talking := false
var _talk_t := 0.0
var _idle_t := 0.0
var _turning := false
var _gesturing := false
var _gestures := {}
## 0 = Seite, 1 = schräg von hinten, 2 = von hinten
var _view := 0
## je Ansicht 1, 2: {"idle": Texture2D, "walk": [...], "turn": [...]}
var _vtex := {}
## läuft gerade (ein neues Ziel während des Laufens setzt den Zyklus fort statt neu anzulaufen)
var _moving := false
var _sprite := Sprite2D.new()
var _shadow := Sprite2D.new()
var show_shadow := true
var _token := 0
var _anim := 0.0
## Richtung des letzten Schritts
var _heading := Vector2.RIGHT


func _init() -> void:
	_idle = load("res://assets/characters/martin/right_idle.png")
	for i in FRAMES:
		_walk.append(load("res://assets/characters/martin/right_walk_%02d.png" % i))
	for i in START_FRAMES:
		_start.append(load("res://assets/characters/martin/start_%02d.png" % i))
	for i in TURN_FRAMES:
		_turn.append(load("res://assets/characters/martin/turn_%02d.png" % i))
	for i in IDLE_FRAMES:
		_idle_loop.append(load("res://assets/characters/martin/idle_%02d.png" % i))
	for kind in GESTURES:
		_gestures[kind] = []
		for i in GESTURES[kind]:
			_gestures[kind].append(load("res://assets/characters/martin/%s_%02d.png" % [kind, i]))
	for v in VIEWS:
		var n: String = VIEWS[v]["name"]
		var t := {"idle": load("res://assets/characters/martin/%s_idle.png" % n), "walk": [], "turn": []}
		for i in VIEWS[v]["frames"]:
			t["walk"].append(load("res://assets/characters/martin/%s_walk_%02d.png" % [n, i]))
		for i in VIEW_TURNS[v]["frames"]:
			t["turn"].append(load("res://assets/characters/martin/%s_%02d.png" % [VIEW_TURNS[v]["name"], i]))
		_vtex[v] = t
	for state in ["talk_small", "talk_open"]:
		_talk.append(load("res://assets/characters/martin/%s.png" % state))
	_talk.append(_idle)
	_shadow.texture = load("res://assets/characters/martin/shadow.png")
	_shadow.scale = SHADOW_SIZE / _shadow.texture.get_size()
	_shadow.position = Vector2(0, -24)
	add_child(_shadow)
	_sprite.centered = false
	add_child(_sprite)
	face("right")


## Im Stand: Mund beim Sprechen, sonst Atem-Schleife.
func _process(dt: float) -> void:
	if _moving or _turning or _gesturing:
		_idle_t = 0.0
		return
	if _view > 0:
		_set_texture(_idle_tex())
		return
	if talking:
		_talk_t -= dt
		if _talk_t <= 0.0:
			_talk_t = randf_range(0.08, 0.16)
			_set_texture(_talk.pick_random())
		return
	_idle_t += dt
	_set_texture(_idle_loop[int(_idle_t * IDLE_FPS) % IDLE_FRAMES])


func _set_texture(tex: Texture2D, anchor := Vector2.INF) -> void:
	if anchor == Vector2.INF:
		anchor = VIEWS[_view]["anchor"] if _view > 0 else ANCHOR
	_sprite.texture = tex
	_sprite.flip_h = dir == "left"
	_sprite.offset = -Vector2(tex.get_width() - anchor.x if _sprite.flip_h else anchor.x, anchor.y)


## "front" und "back" behalten die bisherige Ansicht; "left"/"right" drehen ihn zur Seite
## (aus der Rückansicht zuerst zurück) (instant: ohne Drehung).
func face(d: String, instant := false) -> void:
	if instant:
		_view = 0
		if d in ["left", "right"]:
			dir = d
		_set_texture(_idle)
		return
	if d in ["left", "right"] and (_view > 0 or d != dir):
		_face_side(d)
		return
	_set_texture(_idle_tex())


func _idle_tex() -> Texture2D:
	return _vtex[_view]["idle"] if _view > 0 else _idle


func _face_side(d: String) -> void:
	while _view > 0:
		if not await _turn_view(_view - 1):
			return
	if d != dir:
		await _turn_to(d)


## Dreht ihn eine Stufe weiter (Seite <-> schräg <-> hinten, auf der Seite von dir). Läuft immer zu Ende,
## damit nichts springt; false, wenn währenddessen ein neuer Befehl kam.
func _turn_view(to: int) -> bool:
	var my := _token
	if Game.fast or to == _view:
		_view = to
		_set_texture(_idle_tex())
		return true
	var deeper := to > _view
	var turn: Dictionary = VIEW_TURNS[maxi(to, _view)]
	var frames: Array = _vtex[maxi(to, _view)]["turn"]
	var n_frames: int = turn["frames"]
	_turning = true
	for n in n_frames:
		var i := n if deeper else n_frames - 1 - n
		var t := (i + 1) / float(n_frames + 1)
		_set_texture(frames[i], (turn["from"] as Vector2).lerp(turn["to"], t))
		await get_tree().create_timer(1.0 / TURN_FPS).timeout
	_view = to
	_turning = false
	_set_texture(_idle_tex())
	return my == _token


## Dreht ihn auf die andere Seite (immer zu Ende); false, wenn währenddessen ein neuer Befehl kam.
func _turn_to(d: String) -> bool:
	var my := _token
	if Game.fast or d == dir:
		dir = d
		_set_texture(_idle)
		return true
	_turning = true
	for n in TURN_FRAMES:
		var i := n if d == "left" else TURN_FRAMES - 1 - n
		var t := (i + 1) / float(TURN_FRAMES + 1)
		_sprite.texture = _turn[i]
		_sprite.flip_h = false
		_sprite.offset = -Vector2(lerpf(TURN_ANCHOR_RIGHT, TURN_ANCHOR_LEFT, t), ANCHOR.y)
		await get_tree().create_timer(1.0 / TURN_FPS).timeout
	dir = d
	_turning = false
	_set_texture(_idle)
	return my == _token


## Spielt eine Geste ("use": Hand nach vorn, "pickup": bücken) und endet im Standbild.
func gesture(kind: String) -> void:
	if Game.fast:
		return
	while _turning:
		await get_tree().process_frame
	while _view > 0:
		if not await _turn_view(_view - 1):
			return
	var my := _token
	_gesturing = true
	for tex in _gestures[kind]:
		_set_texture(tex)
		await get_tree().create_timer(1.0 / GESTURE_FPS).timeout
		if my != _token:
			break
	_gesturing = false
	_set_texture(_idle)


func update_scale() -> void:
	var k := room.height_at(position.y) / BODY_PX
	scale = Vector2(k, k)
	_shadow.visible = show_shadow
	_shadow.modulate.a = room.shadow_alpha
	_sprite.modulate = room.tint


## Bildschirmpunkt über dem Kopf, für Untertitel.
func head_screen_pos() -> Vector2:
	return get_global_transform_with_canvas() * Vector2(0, -BODY_PX - 20)


func stop() -> void:
	_token += 1
	_moving = false
	if not _turning:
		_set_texture(_idle_tex())


## Bild zur Position in Anlauf + Zyklus; in die Tiefe ohne Anlauf, ab dem Standbild im Zyklus
func _walk_frame() -> Texture2D:
	var i := int(_anim)
	if _view > 0:
		var v: Dictionary = VIEWS[_view]
		return _vtex[_view]["walk"][(v["idle"] + i) % v["frames"]]
	return _start[i] if i < START_FRAMES else _walk[(i - START_FRAMES) % FRAMES]


## Faktor für die Bildfolge, damit er bei einem Haltebild ankommt; rest = Restweg in Bildern.
func _stop_rate(rest: float) -> float:
	if rest > STOP_PLAN or rest <= 0.0 or (_view == 0 and _anim < START_FRAMES):
		return 1.0
	var frames: int = VIEWS[_view]["frames"] if _view > 0 else FRAMES
	var c := fmod(_anim, frames) if _view > 0 else fmod(_anim - START_FRAMES, frames)
	var best := INF
	for f in (VIEWS[_view]["stops"] if _view > 0 else STOP_FRAMES):
		var need := fposmod(f + 0.5 - c, frames)
		for k in 2:
			var r := (need + k * frames) / rest
			if absf(r - 1.0) < absf(best - 1.0):
				best = r
	return clampf(best, 0.6, 1.6)


## Ansicht für den Weg d nach dem Winkel nach hinten; h = Körperhöhe an der Stelle
func _view_for(d: Vector2, h: float) -> int:
	if d.y >= 0.0 or (_view == 0 and d.length() < VIEW_MIN_LEN * h):
		return 0
	var a := rad_to_deg(atan2(-d.y, absf(d.x)))
	# Hysterese: die Grenzen zur aktuellen Ansicht hin verschieben
	var b1: float = VIEW_ANGLES[0] + (-VIEW_HYST if _view >= 1 else VIEW_HYST)
	var b2: float = VIEW_ANGLES[1] + (-VIEW_HYST if _view == 2 else VIEW_HYST)
	return 0 if a < b1 else (1 if a < b2 else 2)


## Läuft aus dem Gehen bis zum nächsten Haltebild weiter (Richtung des letzten Schritts), damit eine Drehung
## aus dem Stand beginnt; früh im Anlauf geht er stattdessen auf der Stelle zurück ins Standbild.
func _settle() -> void:
	var start := 0 if _view > 0 else START_FRAMES
	var frames: int = VIEWS[_view]["frames"] if _view > 0 else FRAMES
	var stride: float = VIEWS[_view]["stride"] if _view > 0 else STRIDE
	var rate := SETTLE_RATE * SPEED / stride
	if _view == 0 and _anim < START_FRAMES * 0.5:
		while _anim > 0.0:
			await get_tree().process_frame
			_anim = maxf(0.0, _anim - rate * get_process_delta_time())
			_set_texture(_walk_frame())
		return
	var base := maxf(_anim - start, 0.0)
	var goal := INF
	for f in (VIEWS[_view]["stops"] if _view > 0 else STOP_FRAMES):
		goal = minf(goal, start + f + ceilf((base - f) / frames) * frames)
	var slow := lerpf(1.0, 0.55, absf(_heading.y))
	while _anim < goal:
		await get_tree().process_frame
		var da := minf(rate * get_process_delta_time(), goal - _anim)
		_anim += da
		position = room.clamp_to_floor(position + _heading * da * stride * room.height_at(position.y) * slow)
		update_scale()
		_set_texture(_walk_frame())


## Läuft zum Punkt (auf den Laufbereich begrenzt); false, wenn ein neuer Befehl den Weg abbricht.
func walk_to(target: Vector2) -> bool:
	_token += 1
	var my := _token
	target = room.clamp_to_floor(target)
	if Game.fast:
		position = target
		update_scale()
		await get_tree().process_frame
		return true
	# eine laufende Drehung erst beenden
	while _turning:
		await get_tree().process_frame
	if my != _token:
		return false
	if not _moving:
		_anim = 0.0
	_moving = true
	while true:
		var d := target - position
		if d.length() < 1.0:
			break
		await get_tree().process_frame
		if my != _token:
			return false
		var dt := get_process_delta_time()
		# Bewegung in die Tiefe wirkt verkürzt, deshalb vertikal langsamer
		var slow := lerpf(1.0, 0.55, absf(d.normalized().y))
		var h := room.height_at(position.y)
		var step := SPEED * h * slow * dt
		var side := "right" if d.x > 0 else "left"
		# fast senkrechte Wege behalten die bisherige Seite, damit er nicht hin- und herspringt
		var flip := absf(d.x) > 0.2 * absf(d.y) and dir != side
		var view := _view_for(d, h)
		if flip and _view == 2:
			# von hinten fast symmetrisch: Seite ohne Drehung wechseln
			dir = side
		elif flip or view != _view:
			_turning = true
			if _moving:
				await _settle()
			_moving = false
			var ok: bool
			if flip and _view == 0:
				ok = await _turn_to(side)
			elif flip:
				# schräg auf die andere Seite: über die Rückansicht
				ok = await _turn_view(2)
				dir = side
			else:
				ok = await _turn_view(_view + (1 if view > _view else -1))
			_turning = false
			if not ok or my != _token:
				return false
			_anim = 0.0
			_moving = true
			continue
		if _view > 0:
			var stride: float = VIEWS[_view]["stride"]
			_anim += minf(step, d.length()) / h / stride * _stop_rate(d.length() / h / stride)
		elif _anim < START_FRAMES:
			# Anlauf: Bilder im Takt des Gehens, Tempo steigt mit dem Anlauf
			_anim += step / h / STRIDE
			step *= clampf(_anim / START_FRAMES, 0.1, 1.0)
		else:
			# Bildfolge nach zurückgelegtem Weg, damit die Füße nicht rutschen
			_anim += minf(step, d.length()) / h / STRIDE * _stop_rate(d.length() / h / STRIDE)
		_heading = d.normalized()
		position = target if d.length() <= step else position + d.normalized() * step
		update_scale()
		_set_texture(_walk_frame())
	_moving = false
	_set_texture(_idle_tex())
	return true
