class_name Player
extends Node2D
## Martin: ein Laufzyklus in Dreiviertelansicht nach rechts, für links gespiegelt.
## Auch beim Laufen nach vorn und hinten bleibt er so ausgerichtet. Größe nach Tiefe im Raum.
## Beim Seitenwechsel dreht er sich über die Vorderseite (rechts -> links vorwärts, links -> rechts rückwärts).
## Aus dem Stand läuft er mit einem Anlauf los, der nahtlos in den Laufzyklus übergeht; angehalten wird bei
## einem Zyklusbild, das dem Stand nahekommt. Im Stand atmet er (Schleife); beim Sprechen bewegt sich der Mund.

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
## läuft gerade (ein neues Ziel während des Laufens setzt den Zyklus fort statt neu anzulaufen)
var _moving := false
var _sprite := Sprite2D.new()
var _shadow := Sprite2D.new()
var show_shadow := true
var _token := 0
var _anim := 0.0


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
	if talking:
		_talk_t -= dt
		if _talk_t <= 0.0:
			_talk_t = randf_range(0.08, 0.16)
			_set_texture(_talk.pick_random())
		return
	_idle_t += dt
	_set_texture(_idle_loop[int(_idle_t * IDLE_FPS) % IDLE_FRAMES])


func _set_texture(tex: Texture2D) -> void:
	_sprite.texture = tex
	_sprite.flip_h = dir == "left"
	_sprite.offset = -Vector2(tex.get_width() - ANCHOR.x if _sprite.flip_h else ANCHOR.x, ANCHOR.y)


## "front" und "back" behalten die bisherige Seite; ein Seitenwechsel dreht ihn (instant: ohne Drehung).
func face(d: String, instant := false) -> void:
	if d in ["left", "right"] and d != dir:
		if not instant:
			_turn_to(d)
			return
		dir = d
	_set_texture(_idle)


## Dreht ihn auf die andere Seite; false, wenn ein neuer Befehl die Drehung abbricht.
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
		if my != _token:
			# abgebrochen: auf der Seite weiter, der er schon näher ist
			if n * 2 >= TURN_FRAMES:
				dir = d
			_turning = false
			return false
	dir = d
	_turning = false
	_set_texture(_idle)
	return true


## Spielt eine Geste ("use": Hand nach vorn, "pickup": bücken) und endet im Standbild.
func gesture(kind: String) -> void:
	if Game.fast:
		return
	while _turning:
		await get_tree().process_frame
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
	face(dir)


## Bild zur Position in Anlauf + Zyklus
func _walk_frame() -> Texture2D:
	var i := int(_anim)
	return _start[i] if i < START_FRAMES else _walk[(i - START_FRAMES) % FRAMES]


## Faktor für die Bildfolge, damit er bei einem Haltebild ankommt; rest = Restweg in Bildern.
func _stop_rate(rest: float) -> float:
	if _anim < START_FRAMES or rest > STOP_PLAN or rest <= 0.0:
		return 1.0
	var c := fmod(_anim - START_FRAMES, FRAMES)
	var best := INF
	for f in STOP_FRAMES:
		var need := fposmod(f + 0.5 - c, FRAMES)
		for k in 2:
			var r := (need + k * FRAMES) / rest
			if absf(r - 1.0) < absf(best - 1.0):
				best = r
	return clampf(best, 0.6, 1.6)


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
		# fast senkrechte Wege behalten die bisherige Seite, damit er nicht hin- und herspringt
		if absf(d.x) > 0.2 * absf(d.y) and dir != ("right" if d.x > 0 else "left"):
			_moving = false
			if not await _turn_to("right" if d.x > 0 else "left"):
				return false
			_anim = 0.0
			_moving = true
			continue
		if _anim < START_FRAMES:
			# Anlauf: Bilder im Takt des Gehens, Tempo steigt mit dem Anlauf
			_anim += step / h / STRIDE
			step *= clampf(_anim / START_FRAMES, 0.1, 1.0)
		else:
			# Bildfolge nach zurückgelegtem Weg, damit die Füße nicht rutschen
			_anim += minf(step, d.length()) / h / STRIDE * _stop_rate(d.length() / h / STRIDE)
		position = target if d.length() <= step else position + d.normalized() * step
		update_scale()
		_set_texture(_walk_frame())
	_moving = false
	face(dir)
	return true
