extends Room
## Innenerde: Bahnhof (concept/inner_earth.md, „Bahnhof“ und „Wetterschleuse“). Drei Laufflächen (Bahnsteig,
## Balkon, Galerie) mit zwei Treppen; Martin ist hier klein. Links der Zug in der Vakuumröhre, in der Mitte der
## Versorgungsblock (Küche, Hydroponik, Kantine übereinander, dazu die verschlossene zweite Galerietür und das
## Gitter zum Luftschacht), rechts Maschinenraumtür, Steuerkasten und die Wetterschleuse.
##
## Wetterschleuse: Tor 1 (vorn, Rolltor) "closed", "open" oder "on_ladder" (sitzt auf der Malerleiter), Tor 2
## (hinten) zu oder offen. Die Steuerung hält Tor 1 auch auf der Leiter für geschlossen (Kraftabschaltung) und
## öffnet dann Tor 2: Wetterkurzschluss, Wetteralarm (alle Türleuchten rot, alle Türen gesperrt).
##

## Türleuchten über den Türen (Bildpixel), im Wetteralarm rot
const DOOR_LAMPS := [Vector2(1930, 238), Vector2(1930, 498), Vector2(1930, 2), Vector2(1480, 2), Vector2(2178, 426)]

var lamps := Node2D.new()


func _init() -> void:
	asset_dir = "inner_earth_station"


static func gate1() -> String:
	return Game.value("gate1", "closed")


static func gate2_open() -> bool:
	return Game.flag("gate2_open")


## Wetterkurzschluss: beide Tore offen (Tor 1 nur scheinbar zu)
static func weather_alarm() -> bool:
	return gate2_open() and gate1() == "on_ladder"


func build() -> void:
	tint = Color(0.86, 0.88, 0.92)
	add_child(lamps)
	lamps.draw.connect(_draw_lamps)
	hotspot("tube", "Vakuumröhre")
	hotspot("train", "Zug")
	hotspot("train_door", "Offene Zugtür", "none")
	hotspot("kitchen_door", "Tür zur Küche", "none")
	hotspot("hydro_door", "Tür zur Hydroponik", "none")
	hotspot("canteen_door", "Tür zur Kantine", "none")
	hotspot("locked_door", "Tür")
	hotspot("grille", "Lüftungsgitter")
	hotspot("machine_door", "Tür mit Hochspannungszeichen", "none")
	hotspot("control_box", "Steuerkasten")
	hotspot("gate", "Rolltor")
	hotspot("beacon", "Rundumleuchte")
	set_verbs({"train_door": "go", "kitchen_door": "go", "hydro_door": "go", "canteen_door": "go",
		"machine_door": "go"})
	# Geländer vor Martin, solange er auf Treppe, Balkon oder Galerie ist (auf dem Bahnsteig steht er davor)
	layers["railings"].z_index = 1


func _process(_dt: float) -> void:
	layers["railings"].visible = cur_link >= 0 or cur_area != "platform"


func refresh() -> void:
	var g := gate1()
	var ladder := Game.flag("ladder_in_gate")
	layers["gate1_open"].visible = g == "open" and not ladder
	layers["gate1_open_ladder"].visible = g == "open" and ladder
	layers["gate1_on_ladder"].visible = g == "on_ladder" and not gate2_open()
	layers["gate2_open"].visible = g == "on_ladder" and gate2_open()
	layers["grille_open"].visible = Game.flag("station_grille_open")
	lamps.queue_redraw()


func _draw_lamps() -> void:
	if not weather_alarm():
		return
	for p in DOOR_LAMPS:
		lamps.draw_circle(p, 22.0, Color(1, 0.1, 0.05, 0.25))
		lamps.draw_circle(p, 11.0, Color(1, 0.15, 0.1, 0.9))


func display_name(hs: Dictionary) -> String:
	if hs["id"] == "gate" and gate1() != "closed":
		return "Wetterschleuse"
	return hs["name"]


func on_enter(from: String) -> void:
	if not Game.flag("inner_earth_seen"):
		Game.set_flag("inner_earth_seen")
		await say("Noch ein Bahnhof. Diesmal mit Kantine, so wie es aussieht.")
	if weather_alarm() and from != "":
		await narrate("[Alle Türleuchten sind rot. Irgendwo heult ein Lüfter.]")


func look(hid: String) -> void:
	match hid:
		"tube":
			await say("Die Vakuumröhre. Dieselbe Bauart wie unter dem Museum.")
		"train":
			await say("Der Zug wartet in der Schleuse.")
		"train_door":
			await say("Die Zugtür steht offen.")
		"kitchen_door":
			await say("Die Tür zur Küche. Dahinter klappern Töpfe.")
		"hydro_door":
			if Game.flag("hydroponics_door_unlocked"):
				await say("Die Tür zur Hydroponik. Von innen habe ich sie entriegelt.")
			else:
				await say("Die Tür zur Hydroponik. Außen kein Griff, nur ein Schloss.")
		"canteen_door":
			await say("Die Kantine. Es riecht nach Kantine.")
		"locked_door":
			await say("Eine Tür ohne Schild. Abgeschlossen.")
		"grille":
			if Game.flag("station_grille_open"):
				await say("Der offene Luftschacht. Gerade breit genug für mich.")
			else:
				await say("Ein Lüftungsgitter mit gelbem Rahmen. Zwei Flügelmuttern.")
		"machine_door":
			await say("Eine Stahltür mit Hochspannungszeichen. Dahinter brummt etwas Großes.")
		"control_box":
			await say("Zwei Taster, „Tor 1“ und „Tor 2“, und zwei Meldeleuchten „geschlossen“.%s" % lamp_state())
		"gate":
			await look_gate()
		"beacon":
			await say("Eine gelbe Rundumleuchte. Die geht an, wenn sich das Tor bewegt.")
		_:
			await super(hid)


func lamp_state() -> String:
	var t1 := gate1() != "open"
	var t2 := not gate2_open()
	return " Tor 1: %s. Tor 2: %s." % ["leuchtet" if t1 else "aus", "leuchtet" if t2 else "aus"]


func look_gate() -> void:
	match gate1():
		"closed":
			await say("Ein Rolltor, doppelt so hoch wie eine Tür. Eine Wetterschleuse, wie im Bergbau.")
		"open":
			if Game.flag("ladder_in_gate"):
				await say("Meine Leiter steht in der Toröffnung. Dahinter die Kammer und Tor 2.")
			else:
				await say("Eine leere Kammer, so tief wie ein Lastwagen. Hinten ein zweites Rolltor.")
		"on_ladder":
			if gate2_open():
				await say("Beide Tore offen. Der Luftzug reißt einem fast die Jacke weg.")
			else:
				await say("Das Tor sitzt auf meiner Leiter. Die Steuerung meldet: geschlossen.")


func use(hid: String) -> void:
	match hid:
		"train_door":
			Game.set_flag("station", "inner_earth")
			await Game.main.flush_gesture()
			await go("train_cabin")
		"train", "tube":
			await refuse("Einsteigen geht nur durch die Tür.")
		"kitchen_door":
			if weather_alarm():
				await refuse("Gesperrt. Die Leuchte ist rot.")
			else:
				await go("inner_earth_kitchen")
		"hydro_door":
			if weather_alarm():
				await refuse("Gesperrt. Die Leuchte ist rot.")
			elif Game.flag("hydroponics_door_unlocked"):
				await go("inner_earth_hydroponics")
			else:
				await refuse("Verschlossen. Von außen komme ich da nicht rein.")
		"canteen_door":
			if weather_alarm():
				await refuse("Gesperrt. Die Leuchte ist rot.")
			else:
				await go("inner_earth_canteen")
		"locked_door":
			await refuse("Abgeschlossen.")
		"machine_door":
			if weather_alarm():
				await refuse("Gesperrt. Die Leuchte ist rot.")
			elif Game.flag("machine_door_unlocked"):
				await go("inner_earth_machine_room")
			else:
				await refuse("Verschlossen. Und Hochspannung.")
		"grille":
			await use_grille()
		"control_box":
			await use_control_box()
		"gate":
			await use_gate()
		"beacon":
			await refuse("Zu hoch.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["gate", "ladder"]:
			await place_ladder()
		["control_box", "masking_tape"]:
			await refuse("Die Taster festkleben? Die Steuerung lässt trotzdem nie beide Tore auf.")
		_:
			await super(hid, item)


func use_grille() -> void:
	await Game.main.flush_gesture()
	if not Game.flag("station_grille_open"):
		Game.set_flag("station_grille_open")
		refresh()
		await say("Zwei Flügelmuttern. Fester angezogen als nötig, aber es geht.")
		return
	await go("inner_earth_air_shaft")


func use_control_box() -> void:
	var c := await Game.choose(["Taster „Tor 1“", "Taster „Tor 2“", "Nichts drücken"])
	await Game.main.flush_gesture()
	match c:
		0:
			await press_gate1()
		1:
			await press_gate2()


func press_gate1() -> void:
	if gate2_open():
		await narrate("[Nichts. Solange Tor 2 offen ist, bewegt sich Tor 1 nicht.]")
		return
	match gate1():
		"closed":
			Game.set_flag("gate1", "open")
			refresh()
			await narrate("[Die Rundumleuchte dreht sich. Das Rolltor rattert nach oben.]")
		"open":
			if Game.flag("ladder_in_gate"):
				Game.set_flag("gate1", "on_ladder")
				refresh()
				await narrate("[Das Rolltor rattert herunter, setzt mit einem Knirschen auf der Leiter auf und bleibt stehen.]")
				await narrate("[Am Steuerkasten geht die Leuchte „Tor 1 geschlossen“ an.]")
				if not Game.flag("ladder_trick_seen"):
					Game.set_flag("ladder_trick_seen")
					await say("Die Leiter hält mehr aus, als die Steuerung denkt.")
			else:
				Game.set_flag("gate1", "closed")
				refresh()
				await narrate("[Das Rolltor rattert herunter.]")
		"on_ladder":
			Game.set_flag("gate1", "open")
			refresh()
			await narrate("[Das Rolltor rattert wieder nach oben. Die Leiter steht noch.]")


func press_gate2() -> void:
	if gate1() == "open":
		await narrate("[Nichts. Die Leuchte „Tor 1 geschlossen“ ist aus.]")
		return
	Game.set_flag("gate2_open", not gate2_open())
	refresh()
	if gate2_open():
		await narrate("[Hinter Tor 1 rattert das zweite Tor nach oben.]")
		if weather_alarm():
			await narrate("[Ein Brausen. Kalter Wind fegt durch die Kammer. Alle Türleuchten springen auf Rot.]")
			if not Game.flag("weather_alarm_seen"):
				Game.set_flag("weather_alarm_seen")
				await say("Wetterkurzschluss. Jetzt zieht die Luft den kurzen Weg.")
	else:
		await narrate("[Tor 2 rattert herunter.]")
		if gate1() == "on_ladder":
			await narrate("[Das Brausen legt sich. Die Türleuchten werden wieder grün.]")


func place_ladder() -> void:
	await Game.main.flush_gesture()
	match gate1():
		"closed":
			await refuse("Erst muss das Tor auf.")
		"on_ladder":
			await refuse("Die Leiter steht schon drin.")
		_:
			if Game.flag("ladder_in_gate"):
				await refuse("Die Leiter steht schon drin.")
				return
			Game.remove_item("ladder")
			Game.set_flag("ladder_in_gate")
			refresh()
			await say("Aufgeklappt, links in die Öffnung. Rechts komme ich noch vorbei.")


func use_gate() -> void:
	match gate1():
		"closed":
			await refuse("Das öffnet nur der Steuerkasten.")
		"open":
			if Game.flag("ladder_in_gate"):
				await Game.main.flush_gesture()
				Game.set_flag("ladder_in_gate", false)
				Game.add_item("ladder")
				refresh()
				await say("Die Leiter nehme ich wieder mit.")
			else:
				await refuse("Hinten ist nur Tor 2. Allein komme ich da nicht weiter.")
		"on_ladder":
			await refuse("Die Leiter steckt unter dem Tor fest. Erst muss das Tor wieder hoch.")
