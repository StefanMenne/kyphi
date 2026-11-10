class_name Walker
extends RefCounted
## Laufen und Drehen im Stand eines Figurensatzes, ohne Abhängigkeit vom Spiel: dieselbe Logik im Spiel (Player)
## und im Animationswerkzeug (work/run.sh anim, Bildschirm „Laufen“; dort über einen Link auf diese Datei).
##
## Ein Weg wird geplant als Anlaufen + n Laufzyklen + Anhalten und alles um denselben Faktor k gestreckt, damit er
## genau ankommt (Bildtempo mit, in Grenzen). Übergänge passen am key-Bild des Zyklus: Anlaufen endet davor,
## Anhalten beginnt dort. Richtungswechsel unterwegs: Abbremsen, Drehen im Stand, Anlaufen. Was der Satz nicht
## hat, entfällt (ohne Anlaufen/Anhalten direkt los und stehen bleiben, ohne Drehvideo sofort gedreht).
##
## Satz (b): {"tex": {anim: [Bilder]}, "rm": rootmotion.json, "key": {Ansicht: Bild}, "walk": params()}.
## Werte für das Laufen stehen in set.json unter "walk" (fehlende aus DEFAULTS):
##   fps          Bilder pro Sekunde beim Laufen und Drehen
##   idle_fps     Bilder pro Sekunde für Atmen, Sprechen, Gesten (nutzt der Player)
##   tempo        [min, max]: Grenzen für das Bildtempo, wenn ein Weg gestreckt wird
##   view_angles  Grenzwinkel des Weges nach hinten (Grad über der Waagerechten): vorn | schräg hinten | hinten
##   hysteresis   Grad, um die eine Grenze zugunsten der aktuellen Richtung verschoben wird
##   min_len      kürzere Wege (Körperhöhen) behalten die Richtung
##
## host (Duck-Typing): var position: Vector2; walk_height(y) -> float (Körperhöhe in Pixeln an der Stelle);
## walk_clamp(p) -> Vector2 (auf den Boden); walk_show(tex, flip); walk_stand(); walk_moved() (nach jeder
## Bewegung); walk_frame() -> float (mit await: ein Bild abwarten, liefert die vergangene Zeit); walk_fast() -> bool
## (ohne Animation, sofort am Ziel); optional walk_log(info: Dictionary) (jede abgespielte Folge, jeder Plan).

const DEFAULTS := {"fps": 8.0, "idle_fps": 12.0, "tempo": [0.75, 1.33], "view_angles": [22.0, 66.0],
	"hysteresis": 6.0, "min_len": 0.15}

var host
var b := {}
## aktuelle Richtung: "fr", "fl", "br", "bl", "b"
var facing := "fr"
## dreht sich oder spielt eine Folge im Stand (Geste)
var busy := false
var moving := false
## jeder neue Befehl erhöht ihn; laufende Folgen brechen ab, wenn er sich ändert (abortable)
var token := 0
## stop(): Laufschleife sofort beenden
var halt := false
var target := Vector2.ZERO


## Laufwerte aus set.json (Abschnitt "walk"), fehlende aus DEFAULTS
static func params(set_json: Dictionary) -> Dictionary:
	var p := DEFAULTS.duplicate(true)
	var w: Dictionary = set_json.get("walk", {})
	for k in w:
		p[k] = w[k]
	return p


func _p(k: String):
	return b["walk"][k]


static func base(d: String) -> String:
	return d.replace("l", "r") if d != "b" else d


static func mirror(d: String) -> String:
	if d == "b":
		return d
	return d.replace("r", "l") if d.ends_with("r") else d.replace("l", "r")


func _log(info: Dictionary) -> void:
	if host.has_method("walk_log"):
		host.walk_log(info)


## Bildfolge einer Drehung im Stand von a nach b aus den vorhandenen Videos turn_<von>_<nach> (vorwärts,
## rückwärts und/oder gespiegelt): [Animation, rückwärts, gespiegelt]; [] ohne passendes Video
func turn_clip(a: String, d: String) -> Array:
	for m in [false, true]:
		var x := mirror(a) if m else a
		var y := mirror(d) if m else d
		if b["tex"].has("turn_%s_%s" % [x, y]):
			return ["turn_%s_%s" % [x, y], false, m]
		if b["tex"].has("turn_%s_%s" % [y, x]):
			return ["turn_%s_%s" % [y, x], true, m]
	return []


## Spielt eine Animation ab und bewegt die Figur dabei nach ihrer Root Motion, gleichmäßig über die Dauer jedes
## Bildes. heading: Laufrichtung (Weg je Bild entlang heading, mal k); Vector2.ZERO: die gemessenen 2D-Vektoren
## (Drehen im Stand). order: Bildreihenfolge (Standard: alle der Reihe nach). false bei stop() oder, wenn
## abortable, bei einem neuen Befehl.
func play(anim: String, flip: bool, reverse := false, heading := Vector2.ZERO, k := 1.0, abortable := true,
		order := []) -> bool:
	var my := token
	var frames: Array = b["tex"][anim]
	var rm: Dictionary = b["rm"].get(anim, {})
	var idx: Array = order.duplicate() if not order.is_empty() else range(frames.size())
	if reverse:
		idx.reverse()
	var tempo := clampf(k, _p("tempo")[0], _p("tempo")[1])
	_log({"anim": anim, "flip": flip, "reverse": reverse, "k": k, "tempo": tempo, "frames": idx.size(),
		"walking": heading != Vector2.ZERO})
	var dur := 1.0 / (float(_p("fps")) * tempo)
	for i in idx:
		host.walk_show(frames[i], flip)
		var step := Vector2.ZERO
		if not rm.is_empty():
			if heading != Vector2.ZERO:
				step = heading * float(rm["d"][i]) * k
			else:
				var v: Array = rm["v"][i]
				step = Vector2(-v[0] if flip else v[0], v[1]) * (-1.0 if reverse else 1.0)
		var t := 0.0
		while t < dur:
			var dt: float = minf(await host.walk_frame(), dur - t)
			t += dt
			host.position += step * host.walk_height(host.position.y) * dt / dur
			host.walk_moved()
		if halt or (abortable and my != token):
			return false
	return true


## Dreht im Stand nach d; false, wenn währenddessen ein neuer Befehl kam.
func turn_to(d: String, abortable := true) -> bool:
	if d == facing:
		return true
	var clip := turn_clip(facing, d)
	if host.walk_fast() or clip.is_empty():
		_log({"turn": "%s→%s" % [facing, d], "instant": true})
		facing = d
		host.walk_stand()
		return true
	busy = true
	var ok: bool = await play(clip[0], clip[2], clip[1], Vector2.ZERO, 1.0, abortable)
	facing = d
	busy = false
	host.walk_stand()
	return ok


func stop() -> void:
	token += 1
	if moving:
		halt = true
	busy = false
	host.walk_stand()


## Richtung für den Weg v; h = Körperhöhe an der Stelle. Nach unten und flach: vorn, steiler: schräg hinten, hinten.
func dir_for(v: Vector2, h: float) -> String:
	if v.length() < float(_p("min_len")) * h:
		return facing
	var side := "r" if v.x > 0 else "l"
	if absf(v.x) < 0.2 * absf(v.y) and facing != "b":
		side = facing.substr(1)  # fast senkrecht: Seite behalten
	if v.y >= 0.0:
		return "f" + side
	var a := rad_to_deg(atan2(-v.y, absf(v.x)))
	var cur := 0 if facing.begins_with("f") else (2 if facing == "b" else 1)
	var hy := float(_p("hysteresis"))
	var b1: float = float(_p("view_angles")[0]) + (-hy if cur >= 1 else hy)
	var b2: float = float(_p("view_angles")[1]) + (-hy if cur == 2 else hy)
	return ("f" + side) if a < b1 else (("b" + side) if a < b2 else "b")


## Läuft zum Punkt: Drehen im Stand in die Laufrichtung, Anlaufen, n Laufzyklen, Anhalten.
## Ein neues Ziel während des Laufens übernimmt die laufende Schleife: gleiche Richtung wird neu geplant,
## sonst Abbremsen, Drehen, Anlaufen. false, wenn ein neuer Befehl (neues Ziel, stop) diesen Weg ablöst.
func walk_to(goal: Vector2) -> bool:
	token += 1
	var my := token
	target = host.walk_clamp(goal)
	if host.walk_fast():
		host.position = target
		host.walk_moved()
		await host.walk_frame()
		return true
	if moving and not halt:
		# die laufende Schleife folgt dem neuen Ziel; warten, bis sie ankommt
		while moving and my == token:
			await host.walk_frame()
		return my == token
	# nach stop(): erst die alte Schleife auslaufen lassen
	while (busy or moving) and my == token:
		await host.walk_frame()
	if my != token or (target - host.position).length() < 1.0:
		return my == token
	halt = false
	moving = true
	await _walk_loop()
	moving = false
	halt = false
	host.walk_stand()
	return my == token


## Anzahl Laufzyklen n und Streckfaktor k für den Restweg: base + n * cycle = rest / k, k möglichst nahe 1
static func plan(rest: float, base_len: float, cycle: float) -> Array:
	# ohne Anlaufen/Anhalten (base 0) mindestens ein Zyklus
	var best := [0, rest / base_len] if base_len > 0.0 else [1, rest / cycle]
	for n in [floori((rest - base_len) / cycle), ceili((rest - base_len) / cycle)]:
		if n >= (0 if base_len > 0.0 else 1):
			var k: float = rest / (base_len + n * cycle)
			if absf(log(k)) < absf(log(best[1])):
				best = [n, k]
	return best


## gesamter Weg einer Animation (Körperhöhen); 0, wenn es sie nicht gibt
func path_len(anim: String) -> float:
	var s := 0.0
	if not b["tex"].has(anim):
		return s
	for x in b["rm"][anim]["d"]:
		s += float(x)
	return s


## Restweg in Körperhöhen (an der aktuellen Stelle gemessen)
func rest() -> float:
	return (target - host.position).length() / host.walk_height(host.position.y)


func _walk_loop() -> void:
	while not halt:
		var want := dir_for(target - host.position, host.walk_height(host.position.y))
		if rest() * host.walk_height(host.position.y) < 1.0:
			break
		if want != facing:
			await turn_to(want, false)
			# während der Drehung kann ein neues Ziel gekommen sein: Richtung neu prüfen
			continue
		var view := base(facing)
		var flip := facing.ends_with("l")
		var goal := target
		var heading: Vector2 = (goal - host.position).normalized()
		# Anlaufen und Anhalten nur, wenn der Satz sie hat
		var has_start: bool = b["tex"].has("start_" + view)
		var has_stop: bool = b["tex"].has("stop_" + view)
		var s_len := path_len("start_" + view)
		var c_len := path_len("walk_" + view)
		var p_len := path_len("stop_" + view)
		var r := rest()
		var pl := plan(r, s_len + p_len, c_len)
		var k: float = pl[1]
		_log({"plan": facing, "rest": r, "cycles": pl[0], "k": k, "start": s_len, "cycle": c_len, "stop": p_len})
		if has_start:
			await play("start_" + view, flip, false, heading, k, false)
		# Laufzyklen von key bis vor key; an jeder Grenze neu planen
		var key: int = int(b["key"].get(view, 0))
		var cycle := []
		var n_cycle: int = b["tex"]["walk_" + view].size()
		for f in n_cycle:
			cycle.append((key + f) % n_cycle)
		var turn_needed := false
		while not halt:
			r = rest()
			if target != goal:
				# neues Ziel: andere Richtung -> abbremsen und neu anlaufen; sonst neu planen
				if dir_for(target - host.position, host.walk_height(host.position.y)) != facing:
					turn_needed = true
					break
				goal = target
			# Richtung an jeder Zyklusgrenze neu: mit der Tiefe ändert sich die Schrittlänge, sonst liefe er vorbei
			heading = (goal - host.position).normalized()
			# ohne Anhalten: unter einem Zehntel Zyklus Rest am Ziel
			if not has_stop and r < 0.1 * c_len:
				break
			pl = plan(r, p_len, c_len)
			k = pl[1]
			if pl[0] == 0:
				break
			await play("walk_" + view, flip, false, heading, k, false, cycle)
		if halt:
			break
		if has_stop:
			if not turn_needed:
				k = rest() / p_len if p_len > 0.0 else 1.0
			await play("stop_" + view, flip, false, heading, k, false)
		if not turn_needed and target == goal:
			host.position = goal
			host.walk_moved()
			break
