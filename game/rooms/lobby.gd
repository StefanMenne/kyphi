extends Room
## Lobby: Frau Ackermann, Archivkartei, Depotschlüssel, Feuerzeug.

const ACK_POS := Vector2(438, 127)

var ackermann: Sprite2D
var _ack_tex := {}
var _talking := false
var _talk_t := 0.0


func _init() -> void:
	asset_dir = "lobby"


func build() -> void:
	floor_poly = PackedVector2Array([
		Vector2(110, 480), Vector2(330, 470), Vector2(628, 470), Vector2(628, 386),
		Vector2(1450, 386), Vector2(1790, 452), Vector2(1850, 576), Vector2(250, 576), Vector2(235, 528)])
	depth = [Vector2(386, 190), Vector2(576, 400)]
	entries = {
		"": [Vector2(1000, 460), "front", ""],
		"apartment": [Vector2(1700, 470), "left", ""],
		"depot": [Vector2(150, 490), "front", "stairs_door_open"],
		"workshop": [Vector2(1445, 400), "front", "workshop_door_open"],
	}
	for state in ["idle", "talk_small", "talk_open", "incense_cone"]:
		_ack_tex[state] = load("res://assets/characters/ackermann/%s.png" % state)
	ackermann = add_sprite(_ack_tex["idle"], ACK_POS)
	move_child(ackermann, 1)

	hotspot("covers", "Abdeckplanen", Rect2(0, 430, 245, 146), Vector2(250, 540), "left")
	hotspot("roster", "Dienstplan", Rect2(353, 179, 118, 77), Vector2(400, 475))
	hotspot("key_board", "Schlüsselbrett", Rect2(553, 186, 95, 80), Vector2(600, 475))
	hotspot("counter", "Empfangstresen", Rect2(326, 297, 293, 164), Vector2(680, 472), "left")
	hotspot("ackermann", "Frau Ackermann", Rect2(ACK_POS, Vector2(124, 188)), Vector2(680, 472), "left", "none")
	hotspot("archive", "Archivkartei", Rect2(707, 200, 230, 184), Vector2(820, 400))
	hotspot("glass_door", "Glastür zum öffentlichen Bereich", Rect2(1055, 143, 338, 241), Vector2(1220, 400))
	hotspot("workshop_door", "Tür zur Werkstatt", Rect2(1403, 154, 85, 233), Vector2(1445, 398))
	hotspot("portal", "Eingangsportal (nach Hause)", Rect2(1577, 85, 246, 370), Vector2(1700, 468), "back", "none")
	hotspot("painting", "Gemälde", Rect2(1946, 133, 102, 159), Vector2(1800, 520), "right")
	hotspot("stairs_door", "Tür zum Keller", Rect2(85, 118, 120, 356), Vector2(150, 488))


func _process(dt: float) -> void:
	if _talking:
		_talk_t -= dt
		if _talk_t <= 0:
			_talk_t = randf_range(0.08, 0.16)
			ackermann.texture = _ack_tex[["talk_small", "talk_open", "idle"].pick_random()]
	elif not Game.flag("ack_holds_cone"):
		ackermann.texture = _ack_tex["idle"]
	else:
		ackermann.texture = _ack_tex["incense_cone"]


func speaker_anchor(speaker: String):
	if speaker == "ackermann":
		return ackermann.get_global_transform_with_canvas() * Vector2(62, -10)
	return null


func set_talking(speaker: String, on: bool) -> void:
	if speaker == "ackermann" and not Game.flag("ack_holds_cone"):
		_talking = on


func ack(text: String, voice := "") -> void:
	await Game.say("ackermann", text, voice)


func look(hid: String) -> void:
	match hid:
		"covers":
			await say("Abdeckplanen. Die Renovierung dauert länger als jede Restaurierung.")
		"roster":
			await Game.note("Dienstplan\n\nGesperrter Flügel: M. Kessler\nReinigung: montags")
			await say("Im gesperrten Flügel arbeite nur ich. Und die Reinigungsfirma kommt nur montags.")
		"key_board":
			await say("Das Schlüsselbrett. Es hängt hinter Frau Ackermann. Keine Chance.")
		"counter":
			await say("Der Empfangstresen. Darauf das Ausleihbuch: jeder Schlüssel, mit Datum und Uhrzeit.")
		"ackermann":
			if Game.flag("hair_secured"):
				await say("Langes graues Haar, hochgesteckt. Hm.")
			else:
				await say("Frau Ackermann. Streng, korrekt, und sie spielt ständig mit einem Feuerzeug.")
		"archive":
			await say("Die Archivkartei. Alphabetisch nach Nachlässen sortiert.")
		"glass_door":
			await say("Dahinter liegt der öffentliche Bereich des Museums.")
		"workshop_door":
			await say("Die Tür zur Werkstatt.")
		"portal":
			await say("Das Eingangsportal. Von hier bin ich in zwei Minuten zu Hause.")
		"painting":
			await say("Moderne Kunst. Nicht mein Fachgebiet.")
		"stairs_door":
			await say("Das Treppenhaus. Unten ist der Keller mit dem Depot.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"ackermann", "counter":
			await talk()
		"key_board":
			await ack("Finger weg vom Schlüsselbrett, Herr Kessler.")
		"archive":
			await archive()
		"glass_door":
			await ack("Da drüben ist Publikumsverkehr, Herr Kessler. Sie mit Ihrem Staubkittel? Nein.", "ackermann/glass_door")
		"workshop_door":
			await go("workshop", "workshop_door_open")
		"portal":
			if Game.has("depot_key"):
				await ack("Herr Kessler. Der Depotschlüssel.")
				await ack("Ordnung muss sein.", "ackermann/key_return")
				return
			await go("apartment")
		"stairs_door":
			if Game.has("depot_key"):
				await go("depot", "stairs_door_open")
			else:
				await say("Abgeschlossen. Den Schlüssel hat Frau Ackermann.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	if hid == "stairs_door" and item == "depot_key":
		await use(hid)
	elif hid in ["ackermann", "counter"]:
		match item:
			"depot_key":
				await return_key()
			"incense_cone":
				await give_cone()
			"index_card_revealed":
				await ask_key()
			"evidence_bag_hair":
				await say("Besser nicht. Noch nicht.")
			_:
				await ack("Was soll ich damit, Herr Kessler?")
	else:
		await super(hid, item)


func archive() -> void:
	if not Game.flag("recording_heard"):
		await say("Die Archivkartei. Gerade suche ich nichts.")
	elif Game.flag("took_index_card"):
		await say("Zwischen „Hofmann, Sammlung“ und „Holtz, Grafik“ fehlt immer noch Hollmann.")
	else:
		await narrate("[Zwischen „Hofmann, Sammlung“ und „Holtz, Grafik“ klafft eine Lücke.]")
		await say("Hollmann fehlt. … Ich nehme die nächste Karte. Holtz.", "martin/hollmann_missing")
		await take("index_card")


func talk() -> void:
	if not Game.flag("greeted"):
		Game.set_flag("greeted")
		await ack("Guten Morgen, Herr Kessler.")
	while true:
		var opts := []
		var keys := []
		if Game.flag("hair_secured") and not Game.flag("asked_evening"):
			opts.append("Wo waren Sie gestern Abend?")
			keys.append("evening")
		if Game.has("depot_key"):
			opts.append("Hier ist der Depotschlüssel zurück.")
			keys.append("return")
		elif Game.flag("recording_heard") and not Game.flag("box_emptied"):
			opts.append("Ich brauche den Depotschlüssel.")
			keys.append("key")
		if Game.flag("took_incense_cone") and not Game.has("lighter"):
			opts.append("Haben Sie Feuer?")
			keys.append("fire")
		opts.append("Ach, nichts.")
		keys.append("bye")
		var k: String = keys[await Game.choose(opts)]
		match k:
			"evening":
				Game.set_flag("asked_evening")
				await say("Wo waren Sie gestern Abend, Frau Ackermann?")
				await ack("Ich bin um 17 Uhr zu Hause. Ich habe einen Kater, der wartet nicht.", "ackermann/home_at_five")
			"return":
				await return_key()
			"key":
				await ask_key()
			"fire":
				await ask_fire()
			"bye":
				return


func ask_key() -> void:
	await say("Ich brauche den Depotschlüssel.")
	await ack("Ich muss das eintragen, Herr Kessler. Ordnung muss sein.", "ackermann/key_log")
	if not Game.has("index_card_revealed"):
		await ack("Welche Inventarnummer?")
		await say("Die … reiche ich nach.")
		return
	await say("D-0912. Hollmann, Nachlass.")
	await narrate("[Frau Ackermann trägt die Nummer ins Ausleihbuch ein und reicht den Schlüssel über den Tresen.]")
	Game.add_item("depot_key")
	if not Game.flag("asked_fingers"):
		Game.set_flag("asked_fingers")
		await ack("Was haben Sie denn da an den Fingern?", "ackermann/fingers")
		await say("Wissenschaft.", "martin/science")


func return_key() -> void:
	Game.remove_item("depot_key")
	await ack("Ordnung muss sein.", "ackermann/key_return")


func ask_fire() -> void:
	await say("Haben Sie Feuer?", "martin/got_fire")
	if Game.flag("asked_fire"):
		await ack("Für den Adventskranz, Herr Kessler.", "ackermann/advent_wreath_again")
		return
	Game.set_flag("asked_fire")
	await ack("Ich rauche nicht.", "ackermann/no_smoking")
	await say("Und das Feuerzeug in Ihrer Hand?", "martin/lighter_in_hand")
	await ack("Das ist für den Adventskranz.", "ackermann/advent_wreath")
	await say("Wir haben keinen Adventskranz.", "martin/no_advent_wreath")
	await ack("Noch nicht. Ordnung muss sein.", "ackermann/not_yet")


## Kapitel 6a: Der Räucherkegel macht sie weich.
func give_cone() -> void:
	if Game.has("lighter"):
		await ack("Den hatten Sie mir schon gezeigt, Herr Kessler.")
		return
	_talking = false
	Game.set_flag("ack_holds_cone")
	await Game.wait(0.6)
	await ack("Ein Räucherkegel … So einen hatte meine Mutter immer im Räuchermännchen. Weihnachten, die ganze Wohnung hat danach gerochen.", "ackermann/incense_memory")
	Game.set_flag("ack_holds_cone", false)
	await narrate("[Sie schiebt Kegel und Feuerzeug über den Tresen.]")
	Game.add_item("lighter")
	await ack("Aber nicht hier in der Lobby. Und Sie haben das nicht von mir.", "ackermann/not_from_me")
