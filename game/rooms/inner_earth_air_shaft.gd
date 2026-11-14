extends Room
## Innenerde: Luftschacht als Schnittbild (concept/inner_earth.md, „Luftschacht“). Oben links das Gitter zum
## Bahnhof, im Boden des oberen Laufs die Klappe zur Hydroponik, dann der Steigschacht hinab, im unteren Lauf der
## Haubenrost über dem Herd der Küche und rechts das Endgitter zum Maschinenraum.
##
## Martin kriecht hier; eine Kriech-Animation gibt es noch nicht. Er ist deshalb nicht zu sehen, eine Marke zeigt,
## wo er ist (shaft_pos: "station", "flap", "bottom", "end"), und jede Strecke ist eine Blende mit kurzem Text.
## Über den Haubenrost kommt er nur bei Dunst in der Küche (Wetteralarm), sonst sieht ihn der Koch.
##
## Übergang, solange der Maschinenraum fehlt: Am Endgitter kehrt Martin um.

const STATION := preload("res://game/rooms/inner_earth_station.gd")
## Marke je Stelle (Bildpixel)
const SPOTS := {"station": Vector2(255, 225), "flap": Vector2(420, 225), "bottom": Vector2(602, 585),
	"end": Vector2(1100, 570)}

var marker := Node2D.new()
var _t := 0.0


func _init() -> void:
	asset_dir = "inner_earth_air_shaft"
	show_player = false


static func spot() -> String:
	return Game.value("shaft_pos", "station")


static func haze() -> bool:
	return STATION.weather_alarm()


func build() -> void:
	add_child(marker)
	marker.draw.connect(_draw_marker)
	hotspot("station_grille", "Gitter zum Bahnhof", "none")
	hotspot("upper_duct", "Oberer Kanal", "none")
	hotspot("flap", "Klappe zur Hydroponik", "none")
	hotspot("riser", "Steigschacht", "none")
	hotspot("hood_grating", "Rost über der Küche", "none")
	hotspot("end_grille", "Gitter am Ende", "none")
	set_verbs({"station_grille": "go", "flap": "go", "riser": "go", "end_grille": "go", "upper_duct": "go"})


func refresh() -> void:
	layers["haze"].visible = haze()
	marker.queue_redraw()


func _process(dt: float) -> void:
	_t += dt
	marker.queue_redraw()


func _draw_marker() -> void:
	var p: Vector2 = SPOTS[spot()]
	var a := 0.55 + 0.25 * sin(_t * 3.0)
	marker.draw_circle(p, 26.0, Color(1, 0.85, 0.4, a * 0.35))
	marker.draw_circle(p, 13.0, Color(1, 0.9, 0.55, a))
	marker.draw_arc(p, 13.0, 0, TAU, 24, Color(0.2, 0.1, 0, 0.9), 2.0)


func on_enter(from: String) -> void:
	if from == "inner_earth_station":
		Game.set_flag("shaft_pos", "station")
	elif from == "inner_earth_hydroponics":
		Game.set_flag("shaft_pos", "flap")
	refresh()
	if not Game.flag("air_shaft_seen"):
		Game.set_flag("air_shaft_seen")
		await say("Eng, staubig, und es zieht. Ein echter Bergwerksschacht.")


func look(hid: String) -> void:
	match hid:
		"station_grille":
			await say("Kaltes, weißes Licht. Dahinter die Galerie am Bahnhof.")
		"upper_duct":
			await say("Der obere Kanal. Gerade so hoch, dass ich auf allen vieren durchpasse.")
		"flap":
			await say("Rosaviolettes Licht von unten. Die Klappe zur Hydroponik.")
		"riser":
			await say("Ein Steigschacht mit Sprossen, ein Stockwerk tief.")
		"hood_grating":
			if haze():
				await say("Durch den Rost quillt Dampf. Darin sieht mich keiner.")
			else:
				await say("Ein Gitterrost. Darunter brodelt der Herd. Und am Herd steht der Koch.")
		"end_grille":
			await say("Blaues Flackern. Dahinter brummt etwas Großes.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"station_grille":
			await crawl_to("station")
			await go("inner_earth_station")
		"upper_duct":
			await crawl_to("station" if spot() == "flap" else "flap")
		"flap":
			await crawl_to("flap")
			await narrate("[Durch die Klappe, über die Regalsprossen hinunter.]")
			await go("inner_earth_hydroponics")
		"riser":
			await crawl_to("station" if spot() in ["bottom", "end"] else "bottom")
		"hood_grating":
			await refuse("Durch den Rost? Darunter ist ein heißer Herd.")
		"end_grille":
			if spot() != "end":
				await crawl_to("end")
				if spot() != "end":
					return
			await refuse("Durch das Gitter sehe ich Maschinen und blaue Funken. Da gehe ich später hin.")
		_:
			await super(hid)


## Kriecht zur Stelle to, mit Blende und kurzem Text je Strecke. Über den Haubenrost nur bei Dunst.
func crawl_to(to: String) -> void:
	var path := _path(spot(), to)
	for i in range(1, path.size()):
		var a: String = path[i - 1]
		var b: String = path[i]
		if b == "end" and not haze():
			await refuse("Über den offenen Rost, direkt über dem Herd? Da sieht mich der Koch.")
			return
		await Game.main.ui.fade_out(0.35)
		Game.set_flag("shaft_pos", b)
		refresh()
		await Game.main.ui.fade_in(0.35)
		await narrate(_text(a, b))


## Stellen der Reihe nach: station – flap – bottom – end
func _path(a: String, b: String) -> Array:
	var order := ["station", "flap", "bottom", "end"]
	var i := order.find(a)
	var j := order.find(b)
	var out := []
	var step := 1 if j >= i else -1
	for k in range(i, j + step, step):
		out.append(order[k])
	return out


func _text(a: String, b: String) -> String:
	match [a, b]:
		["station", "flap"], ["flap", "station"]:
			return "[Martin kriecht durch den oberen Kanal.]"
		["flap", "bottom"]:
			return "[Den Steigschacht hinunter, Sprosse für Sprosse.]"
		["bottom", "flap"]:
			return "[Den Steigschacht hinauf.]"
		["bottom", "end"]:
			return "[Martin kriecht durch den Dampf über den Rost. Unten klappert der Koch mit den Töpfen.]"
		["end", "bottom"]:
			return "[Zurück über den Rost, im Schutz des Dampfs.]"
	return "[Martin kriecht weiter.]"
