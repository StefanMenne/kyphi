class_name Player
extends Node2D
## Martin: ein Laufzyklus in Dreiviertelansicht nach rechts, für links gespiegelt.
## Auch beim Laufen nach vorn und hinten bleibt er so ausgerichtet. Größe nach Tiefe im Raum.

## Mitte zwischen den Füßen und Körperhöhe in Pixeln
const ANCHOR := Vector2(135, 641)
const BODY_PX := 635.0
const FRAMES := 31
## Weg des Standfußes pro Bild des Laufzyklus, in Körperhöhen (aus dem Video gemessen)
const STRIDE := 0.0126
## Körperhöhen pro Sekunde
const SPEED := 0.45

var room: Room
## "right" oder "left"
var dir := "right"
var _idle: Texture2D
var _walk := []
var _sprite := Sprite2D.new()
var _token := 0
var _anim := 0.0


func _init() -> void:
	_idle = load("res://assets/characters/martin/right_idle.png")
	for i in FRAMES:
		_walk.append(load("res://assets/characters/martin/right_walk_%02d.png" % i))
	_sprite.centered = false
	add_child(_sprite)
	face("right")


func _set_texture(tex: Texture2D) -> void:
	_sprite.texture = tex
	_sprite.flip_h = dir == "left"
	_sprite.offset = -Vector2(tex.get_width() - ANCHOR.x if _sprite.flip_h else ANCHOR.x, ANCHOR.y)


## "front" und "back" behalten die bisherige Seite.
func face(d: String) -> void:
	if d in ["left", "right"]:
		dir = d
	_set_texture(_idle)


func update_scale() -> void:
	var k := room.height_at(position.y) / BODY_PX
	scale = Vector2(k, k)


## Bildschirmpunkt über dem Kopf, für Untertitel.
func head_screen_pos() -> Vector2:
	return get_global_transform_with_canvas() * Vector2(0, -BODY_PX - 20)


func stop() -> void:
	_token += 1
	face(dir)


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
		if absf(d.x) > 0.2 * absf(d.y):
			dir = "right" if d.x > 0 else "left"
		position = target if d.length() <= step else position + d.normalized() * step
		update_scale()
		# Bildfolge nach zurückgelegtem Weg, damit die Füße nicht rutschen
		_anim += minf(step, d.length()) / h / STRIDE
		_set_texture(_walk[int(_anim) % FRAMES])
	face(dir)
	return true
