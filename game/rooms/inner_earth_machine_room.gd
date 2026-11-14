extends Room
## Innenerde: Maschinenraum (concept/inner_earth.md, „Maschinenraum“ und „Pigment abschleifen“). Links die Tür
## zum Bahnhof (von innen zu entriegeln), der Lüftungskanal mit dem Gitter neben der Werkbank (Ausstieg aus dem
## Luftschacht), Werkbank mit Schublade (Ersatzbürsten) und Rolle Schleifleinen, Abfalleimer mit gebrauchten
## Streifen. Rechts drei Scheibenantriebe: links und rechts laufen sie, der mittlere steht („Scheibe 3 –
## Revision“), sein Gehäuse lässt sich öffnen und schließen; dahinter die Nahansicht inner_earth_slip_ring.

const STATION := preload("res://game/rooms/inner_earth_station.gd")


func _init() -> void:
	asset_dir = "inner_earth_machine_room"


func build() -> void:
	tint = Color(0.9, 0.93, 1.0)
	hotspot("door", "Tür zum Bahnhof", "none")
	hotspot("duct", "Lüftungskanal")
	hotspot("grille", "Gitter am Kanal", "none")
	hotspot("bench", "Werkbank")
	hotspot("drawer", "Schublade")
	hotspot("emery_roll", "Rolle Schleifleinen")
	hotspot("bin", "Abfalleimer")
	hotspot("left_drive", "Antrieb")
	hotspot("right_drive", "Antrieb")
	hotspot("middle_drive", "Mittlerer Antrieb")
	hotspot("cover", "Gehäusetür")
	hotspot("tag", "Anhänger")
	set_verbs({"door": "go", "grille": "go", "emery_roll": "take"})


func refresh() -> void:
	layers["cover_closed"].visible = Game.flag("cover_closed")
	layers["grille_open"].visible = Game.flag("machine_grille_open")
	layers["drawer_open"].visible = Game.flag("drawer_open")


func is_active(hid: String) -> bool:
	if hid == "cover":
		return not Game.flag("cover_closed")
	return true


func on_enter(from: String) -> void:
	if from == "inner_earth_air_shaft":
		Game.set_flag("machine_grille_open")
		refresh()
	if not Game.flag("machine_room_seen"):
		Game.set_flag("machine_room_seen")
		await say("Hier also drehen sich die Scheiben. Zumindest zwei davon.")


func look(hid: String) -> void:
	match hid:
		"door":
			if Game.flag("machine_door_unlocked"):
				await say("Die Tür zum Bahnhof. Entriegelt.")
			else:
				await say("Die Tür zum Bahnhof. Innen ein roter Drehknauf.")
		"duct":
			await say("Der gelbe Lüftungskanal. Hier endet er.")
		"grille":
			await say("Das Gitter, durch das ich gekommen bin.")
		"bench":
			await say("Eine Werkbank. Schraubstock, Schleifleinen, eine Schublade.")
		"drawer":
			await say("Die Schublade ist voller Kohlebürsten. Ersatzteile für die Antriebe.")
		"emery_roll":
			await say("Eine Rolle Schleifleinen. Grobe Körnung.")
		"bin":
			await say("Gebrauchte Streifen Schleifleinen. Jeder so lang wie der Umfang eines Rings, in einer Spur schwarz, an beiden Enden Reste von Klebeband.")
		"left_drive", "right_drive":
			await say("Hinter dem Rundfenster dreht sich ein kupferner Ring, dass die Funken fliegen. Die Tür ist verriegelt.")
		"middle_drive":
			if Game.flag("cover_closed"):
				await say("Der mittlere Antrieb steht. Die Gehäusetür ist zu.")
			else:
				await say("Der mittlere Antrieb steht. Das Gehäuse ist offen.")
		"cover":
			await say("Die Tür des Gehäuses steht offen.")
		"tag":
			await say("Ein Anhänger. Darauf steht: „Scheibe 3 – Revision“.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"door":
			await use_door()
		"grille":
			await Game.main.flush_gesture()
			Game.set_flag("machine_grille_open")
			refresh()
			await narrate("[Über die Werkbank hinauf und durch das Gitter in den Kanal.]")
			await go("inner_earth_air_shaft")
		"drawer":
			await take_brush()
		"emery_roll":
			if Game.has("emery_cloth"):
				await refuse("Ein Streifen reicht mir.")
			else:
				await take("emery_cloth", "Ich schneide mir einen Streifen ab, so lang wie mein Arm.")
		"bin":
			await refuse("Gebrauchtes Schleifleinen. Das nützt mir nichts mehr.")
		"left_drive", "right_drive":
			await refuse("Verriegelt. Und das ist auch gut so.")
		"middle_drive":
			if Game.flag("cover_closed"):
				await Game.main.flush_gesture()
				Game.set_flag("cover_closed", false)
				refresh()
				await narrate("[Die Gehäusetür schwingt auf.]")
			else:
				await go("inner_earth_slip_ring")
		"cover":
			await Game.main.flush_gesture()
			Game.set_flag("cover_closed")
			refresh()
			await narrate("[Klack.]")
		"tag":
			await refuse("Den lasse ich hängen. Revision ist Revision.")
		"bench", "duct":
			await refuse("Das bringt mir nichts.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["left_drive", _], ["right_drive", _]:
			await refuse("An einen laufenden Antrieb gehe ich nicht. Nicht mit Kupfer und Hochspannung.")
		["middle_drive", _]:
			await go("inner_earth_slip_ring")
		_:
			await super(hid, item)


func take_brush() -> void:
	await Game.main.flush_gesture()
	if not Game.flag("drawer_open"):
		Game.set_flag("drawer_open")
		refresh()
	if Game.has("spare_brush"):
		await refuse("Eine habe ich schon. Ersatz gibt es hier genug.")
		return
	Game.add_item("spare_brush")
	await say("Eine Kohlebürste. Davon liegen hier Dutzende.")


func use_door() -> void:
	if not Game.flag("machine_door_unlocked"):
		await Game.main.flush_gesture()
		Game.set_flag("machine_door_unlocked")
		await say("Ein Dreh am Knauf. Entriegelt.")
	if STATION.weather_alarm():
		await refuse("Sie geht trotzdem nicht auf. Wetteralarm.")
		return
	await go("inner_earth_station")
