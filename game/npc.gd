class_name Npc
extends Sprite2D
## Einfache Figur, die an ihrem Platz steht (Frau Ackermann, Pjotr): Einzelbilder aus
## res://assets/characters/<name>/, schon in der Größe für ihren Raum (keine Skalierung, kein Fußpunkt).
## Beim Sprechen (talking) wechselt der Mund zufällig zwischen talk_small, talk_open und idle; sonst zeigt sie
## das Ruhebild rest. Mit einem anderen Ruhebild als idle (z. B. etwas in der Hand) bleibt der Mund zu, weil
## die Sprechbilder aus idle entstanden sind. Anlegen mit Room.add_npc().

const TALK := ["talk_small", "talk_open", "idle"]

var talking := false
## Ruhebild: idle oder eines der Bilder aus extra
var rest := "idle"
var _tex := {}
var _talk_t := 0.0


## id: Verzeichnis unter assets/characters/; extra: weitere Bilder neben idle, talk_small, talk_open
func _init(id: String, extra: Array = []) -> void:
	name = id
	centered = false
	for state in TALK + extra:
		_tex[state] = load("res://assets/characters/%s/%s.png" % [id, state])
	texture = _tex["idle"]


func _process(dt: float) -> void:
	if talking and rest == "idle":
		_talk_t -= dt
		if _talk_t <= 0:
			_talk_t = randf_range(0.08, 0.16)
			texture = _tex[TALK.pick_random()]
	else:
		texture = _tex[rest]


## Bildschirmpunkt für Untertitel: über der Mitte der Oberkante
func speech_anchor() -> Vector2:
	return get_global_transform_with_canvas() * Vector2(texture.get_width() / 2.0, -10)
