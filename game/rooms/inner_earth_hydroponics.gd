extends Room
## Innenerde: Hydroponik (concept/inner_earth.md). Martins Arbeitsplatz: Liftluke mit den drei Knöpfen (die
## Nahansicht inner_earth_lift_hatch), Pikiertisch mit Lampe (Karte umarbeiten), Pflanzregale, Klappe zum
## Luftschacht. Die Tür zum Bahnhof lässt sich von innen entriegeln.
##
## Übergang, solange der Luftschacht fehlt: Klappe und Regal führen direkt zum Gitter auf der Galerie des
## Bahnhofs (und umgekehrt).

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
			await narrate("[Martin klettert über die Regalsprossen in den Kanal und kriecht zurück zum Gitter am Bahnhof.]")
			await Game.main.change_room("inner_earth_station", "air_shaft")
		"duct", "duct_down":
			await refuse("Zu hoch. Und von außen ist ein Kanal nur ein Kanal.")
		"table":
			await refuse("Ein guter Arbeitsplatz. Mir fehlt nur noch, woran ich arbeiten soll.")
		"lamp":
			await refuse("Die bleibt an. Den Pflanzen zuliebe.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["table", "id_card"], ["lamp", "id_card"]:
			await refuse("Erst brauche ich Farbe. Und etwas, das sie bindet.")
		["lift_hatch", _]:
			await go("inner_earth_lift_hatch")
		_:
			await super(hid, item)


func use_door() -> void:
	if STATION.weather_alarm():
		await refuse("Gesperrt. Über der Tür blinkt es rot.")
		return
	if not Game.flag("hydroponics_door_unlocked"):
		await Game.main.flush_gesture()
		Game.set_flag("hydroponics_door_unlocked")
		await say("Ein Dreh am Knauf. Offen.")
	await go("inner_earth_station")
