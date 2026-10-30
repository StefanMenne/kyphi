extends Room
## Martins Wohnung: Prolog, Diktiergerät, Batterien, Nacht und Abhören der Aufnahme.


func _init() -> void:
	asset_dir = "wohnung"


func build() -> void:
	tint = Color(1.0, 0.94, 0.86)
	hotspot("window", "Fenster")
	hotspot("bookshelf", "Bücherregal")
	hotspot("poster", "Filmplakat")
	hotspot("poster2", "Bild", "right")
	hotspot("plant", "Zimmerpflanze")
	hotspot("sofa", "Sofa", "left")
	hotspot("desk", "Schreibtisch")
	hotspot("answering_machine", "Anrufbeantworter")
	hotspot("laptop", "Laptop")
	hotspot("dictaphone", "Diktiergerät")
	hotspot("remote", "Fernbedienung", "left")
	hotspot("door", "Wohnungstür")
	set_verbs({"door": "go", "dictaphone": "take"})


func refresh() -> void:
	layers["dictaphone"].visible = not Game.flag("took_dictaphone")
	layers["remote"].visible = true


func is_active(hid: String) -> bool:
	if hid == "dictaphone":
		return not Game.flag("took_dictaphone")
	return true


func on_enter(_from: String) -> void:
	if not Game.flag("intro_done"):
		Game.set_flag("intro_done")
		Game.main.ui.show_hint("Linksklick: gehen, Aktionsmenü  ·  Rechtsklick: ansehen  ·  Gegenstand benutzen, dann auf etwas anderes klicken: anwenden oder kombinieren")
		await Game.wait(0.8)
		await narrate("[Der Anrufbeantworter blinkt. Eine neue Nachricht.]")
		await message()
		await say("Dreck. An meinem Altar. Das sehe ich mir an.")
	elif Game.flag("dictaphone_hidden") and not Game.flag("night_done"):
		Game.set_flag("night_done")
		await Game.main.night_cut()
		await say("Mal sehen, ob das Diktiergerät etwas gehört hat.")


func message() -> void:
	await Game.say("ackermann", "Herr Kessler, Ackermann hier. Im Altarraum … da ist Dreck. Auf Ihrem Altar. Asche oder so was. Ich hab nichts angefasst. Kommen Sie bitte. Ordnung muss sein.", "ackermann/answering_machine_phone")


func look(hid: String) -> void:
	match hid:
		"window":
			await say("Ein grauer Morgen. Passt zum Altar.")
		"bookshelf":
			await say("Fachliteratur. Ägyptische Steinmetzkunst, Schellack, Pigmente. Spannender als jeder Krimi.")
		"poster", "poster2":
			await say("Billige Abenteuerromantik. Ich mag es trotzdem.")
		"plant":
			await say("Sie lebt. Das ist mehr, als man von meinen anderen Projekten sagen kann.")
		"sofa":
			await say("Mein Sofa. Die Fernbedienung liegt darauf.")
		"desk":
			await say("Mein Schreibtisch, mit Laptop und Anrufbeantworter.")
		"answering_machine":
			await say("Der Anrufbeantworter. Eine Nachricht von Frau Ackermann.")
		"laptop":
			await refuse("Mein Laptop. Darauf höre ich sonst meine Restaurierungsnotizen ab.")
		"dictaphone":
			await say("Mein Diktiergerät, für Restaurierungsnotizen.")
		"remote":
			await say("Die Fernbedienung. Da stecken zwei AA-Batterien drin.")
		"door":
			await say("Die Wohnungstür. Von hier geht es direkt in die Lobby des Museums.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"answering_machine":
			await message()
		"laptop":
			await laptop()
		"dictaphone":
			await take("dictaphone")
			if Game.flag("dictaphone_powered"):
				return
			await say("Die Batterien sind leer.")
		"remote":
			if Game.flag("took_batteries"):
				await refuse("Ohne Batterien ist sie nur noch Deko.")
			else:
				await take("batteries")
				await say("Fernsehen wird ohnehin überschätzt.", "martin/tv_overrated")
		"door":
			await go("lobby", "door_open")
		"sofa":
			await refuse("Keine Zeit. Der Altar wartet.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	if hid == "laptop" and item == "dictaphone":
		await laptop()
	elif hid == "remote" and item == "batteries":
		await refuse("Die bleiben jetzt im Diktiergerät. Fernsehen wird ohnehin überschätzt.")
	else:
		await super(hid, item)


func laptop() -> void:
	if Game.flag("recording_heard"):
		await refuse("Ich habe die Aufnahme oft genug gehört. Hollmanns Kiste steht im Depot.")
	elif Game.flag("dictaphone_retrieved") and Game.has("dictaphone"):
		await recording()
	else:
		await refuse("Mein Laptop. Darauf höre ich sonst meine Restaurierungsnotizen ab.")


## Kapitel 3: Die Aufnahme.
func recording() -> void:
	Game.set_flag("recording_heard")
	await narrate("[Aufnahme, 3:02 Uhr. Schritte, mehrere Personen. Eine Tür – dumpf, wie Holz.]")
	await Game.say("cult1", "Der Melder ist frei.", "cult1/detector_free_recorder")
	await Game.say("cult2", "… Jemand war hier.", "cult2/someone_was_here_recorder")
	await Game.say("cult1", "Dann heute ohne Räucherwerk. Nur das Gebet. Und lasst ihn so. Wenn er morgen wieder zu ist, weiß er, dass wir es wissen.", "cult1/only_prayer_recorder")
	await narrate("[Ein leiser, gleichmäßiger Sprechgesang auf Altägyptisch. Martin versteht nur einzelne Wörter.]")
	await narrate("[Schritte entfernen sich.]")
	await Game.say("elder", "… Hollmanns Kiste steht immer noch unten im Depot. Im Frühjahr ist Inventur. Holt sie raus, bevor der Neue sie findet.", "elder/hollmanns_box_recorder")
	await narrate("[Eine Tür fällt zu.]")
	await say("Der Neue. … Das bin ich.", "martin/the_new_one")
	await say("Frau Ackermann hat den Depotschlüssel.")
