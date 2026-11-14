extends Room
## Innenerde: Hydroponik (concept/inner_earth.md). Martins Arbeitsplatz: Liftluke mit den drei Knöpfen (die
## Nahansicht inner_earth_lift_hatch), Pikiertisch mit Lampe (Karte umarbeiten), Pflanzregale, Klappe zum
## Luftschacht. Die Tür zum Bahnhof lässt sich von innen entriegeln.
##

const STATION := preload("res://game/rooms/inner_earth_station.gd")


func _init() -> void:
	asset_dir = "inner_earth_hydroponics"


func build() -> void:
	tint = Color(1.0, 0.92, 0.98)
	hotspot("door", "Tür zum Bahnhof", "none")
	hotspot("duct", "Lüftungskanal")
	hotspot("duct_down", "Lüftungskanal")
	hotspot("flap", "Klappe im Kanal")
	hotspot("racks", "Pflanzregale")
	hotspot("lift_hatch", "Liftluke")
	hotspot("lift_buttons", "Lift-Knöpfe")
	hotspot("table", "Pikiertisch")
	hotspot("lamp", "Lampe")
	set_verbs({"door": "go"})


func refresh() -> void:
	layers["hatch_open"].visible = Lift.is_open("hydroponics")
	layers["card_drying"].visible = Game.flag("card_drying")


func on_enter(from: String) -> void:
	if not Game.flag("hydroponics_seen"):
		Game.set_flag("hydroponics_seen")
		await say("Salat unter Pflanzenlicht. Zwei Kilometer unter der Erde.")
	if from == "inner_earth_lift_hatch" or from == "":
		return
	if Lift.alarm() == "hydroponics":
		await narrate("[An der Liftluke summt leise der Warnton.]")


func look(hid: String) -> void:
	match hid:
		"door":
			if Game.flag("hydroponics_door_unlocked"):
				await say("Die Tür zum Bahnhof. Entriegelt.")
			else:
				await say("Die Tür zum Bahnhof. Innen ein großer roter Drehknauf.")
		"duct", "duct_down":
			await say("Ein gelber Blechkanal, groß genug zum Kriechen. Er läuft unter der Decke entlang und hinten in der Ecke durch den Boden.")
		"flap":
			await say("Eine Gitterklappe an der Unterseite des Kanals. Sie hängt offen herab, direkt über dem Regal.")
		"racks":
			await say("Salat, Kräuter, Keimlinge. Das Seitenteil des Regals hat Sprossen wie eine Leiter.")
		"lift_hatch":
			if Lift.is_open("hydroponics"):
				await say("Die Liftluke steht offen.")
			else:
				await say("Eine kleine Luke mit Glasfenster, kaum größer als eine Backofentür. Ein Speiseaufzug.")
		"lift_buttons":
			await say("Drei Knöpfe: Besteck, Blatt, Topf. Kantine, Hydroponik, Küche.")
		"table":
			if Game.flag("card_drying"):
				await say("Die Karte trocknet unter der Lampe.")
			else:
				await say("Ein Pikiertisch. Blumentöpfe, eine Schaufel, gutes Licht. Fast wie in meiner Werkstatt.")
		"lamp":
			await say("Eine Klemmlampe. Sie wärmt wie ein kleiner Heizstrahler.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"door":
			await use_door()
		"lift_hatch", "lift_buttons":
			await go("inner_earth_lift_hatch")
		"flap", "racks":
			await Game.main.flush_gesture()
			await narrate("[Über die Regalsprossen hinauf und durch die Klappe in den Kanal.]")
			await go("inner_earth_air_shaft")
		"duct", "duct_down":
			await refuse("Zu hoch. Und von außen ist ein Kanal nur ein Kanal.")
		"table":
			if Game.flag("card_drying"):
				await take_card()
			else:
				await refuse("Ein guter Arbeitsplatz. Mir fehlt nur noch, woran ich arbeiten soll.")
		"lamp":
			await refuse("Die bleibt an. Den Pflanzen zuliebe.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["table", "id_card"], ["lamp", "id_card"], ["table", "id_card_black"], ["lamp", "id_card_black"]:
			await paint_card(item)
		["table", "walnut_oil"], ["table", "evidence_bag_coal"], ["table", "spatula_soot"], ["table", "brush_soot"]:
			await mix_paint(item)
		["lift_hatch", _]:
			await go("inner_earth_lift_hatch")
		_:
			await super(hid, item)


## Farbe auf einem Blumentopf-Untersetzer anrühren: Walnussöl und ein Pigment (Kohlestaub; Ruß ist die falsche
## Fährte, er trocknet in Öl nicht). Öl und Pigment reichen für viele Schichten.
func mix_paint(item: String) -> void:
	var pigment := ""
	if Game.has("evidence_bag_coal"):
		pigment = "coal"
	if item in ["spatula_soot", "brush_soot"] or (pigment == "" and (Game.has("spatula_soot") or Game.has("brush_soot"))):
		pigment = "soot"
	if not Game.has("walnut_oil"):
		await refuse("Pigment habe ich. Mir fehlt ein Öl, das es bindet. Eins, das trocknet.")
		return
	if pigment == "":
		await refuse("Öl allein ist keine Farbe. Mir fehlt ein schwarzes Pigment.")
		return
	await Game.main.flush_gesture()
	Game.set_flag("paint", pigment)
	if pigment == "coal":
		await say("Kohlestaub und Walnussöl, auf einem Untersetzer angerieben. Tiefschwarz.")
	else:
		await say("Ruß und Walnussöl. Schwarz ist schwarz.")


## Eine Schicht auf die Karte: die 666 mit Kreppband abkleben, streichen, unter die Lampe legen.
func paint_card(item: String) -> void:
	if Game.flag("card_drying"):
		await refuse("Die Karte liegt schon unter der Lampe.")
		return
	if Game.value("paint", "") == "":
		await refuse("Erst brauche ich Farbe. Pigment und ein Öl, das trocknet.")
		return
	if not (Game.has("brush") or Game.has("brush_soot")):
		await refuse("Ohne Pinsel wird das nichts.")
		return
	if not Game.has("masking_tape"):
		await refuse("Dann ist die 666 auch schwarz. Erst muss ich sie abkleben.")
		return
	await Game.main.flush_gesture()
	Game.remove_item(item)
	Game.set_flag("card_drying")
	Game.set_flag("card_drying_paint", Game.value("paint"))
	Game.set_flag("card_drying_since", int(Game.value("rooms_entered", 0)))
	refresh()
	if not Game.flag("card_painted_once"):
		Game.set_flag("card_painted_once")
		await say("666 abkleben, dünn streichen, unter die Lampe. Licht und Wärme, dann trocknet Öl schneller.")
		await say("Trotzdem dauert das. Ich mache solange etwas anderes.")
	else:
		await say("666 abkleben, noch eine dünne Schicht, unter die Lampe.")


func take_card() -> void:
	if int(Game.value("rooms_entered", 0)) <= int(Game.value("card_drying_since", 0)) + 1:
		await refuse("Noch feucht. Ich lasse sie liegen und schaue später wieder nach.")
		return
	await Game.main.flush_gesture()
	Game.set_flag("card_drying", false)
	refresh()
	var layers := int(Game.value("card_layers", 0))
	if Game.value("card_drying_paint") == "soot":
		Game.add_item("id_card" if layers == 0 else "id_card_black")
		await say("Klebt immer noch. Lampenschwarz trocknet in Öl wochenlang. Das weiß jeder Maler.")
		await say("Abwischen. Diese Farbe trocknet nicht.")
		if not Game.flag("soot_failed"):
			Game.set_flag("soot_failed")
		return
	Game.set_flag("card_layers", layers + 1)
	Game.add_item("id_card_black")
	if layers == 0:
		await say("Trocken. Kreppband ab: die rote 666 auf Schwarz.")
		await say("Schwarz sieht sie aus. Ob sie auch so viel wiegt, sagt mir die Waage im Lift.")
	else:
		await say("Trocken. Eine Schicht mehr.")


func use_door() -> void:
	if STATION.weather_alarm():
		await refuse("Gesperrt. Über der Tür blinkt es rot.")
		return
	if not Game.flag("hydroponics_door_unlocked"):
		await Game.main.flush_gesture()
		Game.set_flag("hydroponics_door_unlocked")
		await say("Ein Dreh am Knauf. Offen.")
	await go("inner_earth_station")
