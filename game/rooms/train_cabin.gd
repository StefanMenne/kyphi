extends Room
## Im Zug: Streckenkarte mit allen fünf Zielen. Anfahren lassen sich nur Ziele mit gebautem Bahnhof
## (Museum, Antarktis, Innenerde), und nie der Bahnhof, an dem der Zug gerade steht. Martin ist hier nicht zu sehen.

## Ziel -> [Name, Raum oder "" (noch nicht anfahrbar), Punkt auf der Karte]
const STATIONS := {
	"museum": ["Museum", "museum_station", Vector2(811, 137)],
	"abc": ["ABC GmbH", "", Vector2(1027, 133)],
	"area52": ["Area 52", "", Vector2(1243, 137)],
	# Übergang: hält direkt an der Hydroponik, bis der Bahnhof der Innenerde gebaut ist
	"inner_earth": ["Innenerde", "inner_earth_hydroponics", Vector2(811, 340)],
	"antarctica": ["Antarktis", "antarctica_platform", Vector2(1242, 339)],
}
const DOT_R := 22.0

var overlay := Node2D.new()


func _init() -> void:
	asset_dir = "train_cabin"
	show_player = false


static func current() -> String:
	return Game.value("station", "museum")


func reachable(sid: String) -> bool:
	return STATIONS[sid][1] != "" and sid != current()


func build() -> void:
	tint = Color(0.9, 0.92, 0.95)
	add_child(overlay)
	overlay.draw.connect(_draw_map)
	for sid in STATIONS:
		hotspot("st_" + sid, STATIONS[sid][0], "none")
		var l := Label.new()
		l.text = STATIONS[sid][0]
		var ls := LabelSettings.new()
		ls.font_size = 22
		ls.outline_size = 6
		ls.outline_color = Color(0.02, 0.05, 0.15)
		l.label_settings = ls
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size = Vector2(200, 30)
		l.position = STATIONS[sid][2] + Vector2(-100, DOT_R + 4)
		l.name = "label_" + sid
		add_child(l)
	hotspot("cabin_door", "Tür zum Bahnsteig", "none")
	hotspot("seats", "Sitze")
	var verbs := {"cabin_door": "go"}
	for sid in STATIONS:
		verbs["st_" + sid] = "go"
	set_verbs(verbs)


func refresh() -> void:
	for sid in STATIONS:
		var l: Label = get_node("label_" + sid)
		if sid == current():
			l.text = STATIONS[sid][0] + " (hier)"
			l.modulate = Color(0.75, 1, 0.75)
		elif reachable(sid):
			l.text = STATIONS[sid][0]
			l.modulate = Color(1, 1, 1)
		else:
			l.text = STATIONS[sid][0]
			l.modulate = Color(0.72, 0.76, 0.86)
	overlay.queue_redraw()


func _draw_map() -> void:
	for sid in STATIONS:
		var p: Vector2 = STATIONS[sid][2]
		if sid == current():
			overlay.draw_arc(p, DOT_R + 6, 0, TAU, 32, Color(0.5, 1, 0.5), 4)
		elif reachable(sid):
			overlay.draw_arc(p, DOT_R + 6, 0, TAU, 32, Color(1, 0.85, 0.3), 4)
		else:
			overlay.draw_circle(p, DOT_R + 2, Color(0.04, 0.07, 0.2, 0.75))


func display_name(hs: Dictionary) -> String:
	var hid: String = hs["id"]
	if hid.begins_with("st_") and hid.substr(3) == current():
		return hs["name"] + " (hier)"
	return hs["name"]


func on_enter(_from: String) -> void:
	if not Game.flag("cabin_seen"):
		Game.set_flag("cabin_seen")
		await say("Eine Streckenkarte. Fünf Ziele, aber nur eins leuchtet.")


func look(hid: String) -> void:
	if hid.begins_with("st_"):
		var sid := hid.substr(3)
		if sid == current():
			await say("%s. Da steht der Zug gerade." % STATIONS[sid][0])
		elif reachable(sid):
			await say("%s. Das Ziel leuchtet." % STATIONS[sid][0])
		else:
			await say("%s. Das Ziel ist dunkel." % STATIONS[sid][0])
		return
	match hid:
		"seats":
			await say("Bequemer als jeder Stuhl im Museum.")
		"cabin_door":
			await say("Die Tür zum Bahnsteig.")
		_:
			await super(hid)


func use(hid: String) -> void:
	if hid.begins_with("st_"):
		var sid := hid.substr(3)
		if sid == current():
			await refuse("Da bin ich ja schon.")
		elif not reachable(sid):
			await refuse("Das Ziel ist dunkel. Dahin fährt der Zug nicht.")
		else:
			await travel(sid)
		return
	match hid:
		"cabin_door":
			await go(STATIONS[current()][1])
		"seats":
			await refuse("Sitzen kann ich auch später.")
		_:
			await super(hid)


func travel(sid: String) -> void:
	Game.set_flag("station", sid)
	refresh()
	await narrate("[Die Türen schließen sich. Der Zug beschleunigt lautlos, nach einer Weile bremst er wieder ab.]")
	await go(STATIONS[sid][1])
