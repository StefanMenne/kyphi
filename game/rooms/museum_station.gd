extends Room
## Bahnhof unter dem Museum (Teil 2): Ankunft mit dem Aufzug aus dem Altarraum, der Zug steht in der Schleuse.
## Durch die offene Zugtür steigt Martin ein, dann schließt das Schott und der Zug fährt ab (Video).
## Der Aufzug fährt zurück in den Altarraum.


func _init() -> void:
	asset_dir = "museum_station"


func build() -> void:
	tint = Color(0.8, 0.82, 0.86)
	hotspot("reliefs", "Reliefs")
	hotspot("elevator", "Aufzug", "left", "none")
	hotspot("side_door", "Panzertor", "right")
	hotspot("train", "Zug in der Schleuse")
	hotspot("train_door", "Offene Zugtür", "back", "none")
	set_verbs({"train_door": "go"})


func on_enter(from: String) -> void:
	if from == "altar_room" and not Game.flag("station_seen"):
		Game.set_flag("station_seen")
		await say("Ein Bahnhof. Unter dem Museum.")
		await say("Daher kommt also das Rauschen.")


func look(hid: String) -> void:
	match hid:
		"reliefs":
			await say("Ägyptische Reliefs, in den Fels gehauen. Sauber gearbeitet, aber höchstens zwanzig Jahre alt.")
		"elevator":
			await say("Der Aufzug zurück nach oben in den Altarraum.")
		"side_door":
			await say("Ein Panzertor, dick wie bei einem Tresor.")
		"train":
			await say("Ein Hochgeschwindigkeitszug, zwei Kilometer unter dem Museum. Den hat bestimmt nicht der Förderverein bezahlt.")
		"train_door":
			await say("Die Tür steht offen. Drinnen brennt Licht.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"elevator":
			await go("altar_room")
		"side_door":
			await refuse("Rührt sich keinen Millimeter.")
		"train":
			await refuse("Der Zug steht in einer Schleuse. Rein komme ich nur durch die offene Tür.")
		"train_door":
			await board()
		_:
			await super(hid)


func board() -> void:
	if not Game.flag("departed"):
		await say("Na dann. Einsteigen, bitte.")
	Game.set_flag("departed")
	Game.set_flag("station", "museum")
	await Game.main.depart()
