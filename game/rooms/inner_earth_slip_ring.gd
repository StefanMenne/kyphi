extends Room
## Innenerde: Nahansicht des stehenden Antriebs im Maschinenraum (concept/inner_earth.md, „Pigment abschleifen“).
## Martin ist nicht zu sehen. Schleifleinen mit Kreppband um den Ring kleben, eine Ersatzbürste in den Halter, ein
## Fundtütchen unter den Halter auf den Rost, dann die Drehvorrichtung einschalten: Die Bürste schleift sich am
## Leinen ab, der Staub rieselt ins Tütchen. Ohne Tütchen fällt er durch den Rost in die fettige Wanne.
##
## Zustand: ring_cloth, ring_brush, ring_bag ("", "empty", "full"), dust_lost (Staub in der Wanne zu sehen).


func _init() -> void:
	asset_dir = "inner_earth_slip_ring"
	show_player = false


func build() -> void:
	hotspot("back", "Zurück zum Maschinenraum", "none")
	hotspot("grating", "Gitterrost")
	hotspot("drum", "Schleifring")
	hotspot("holder", "Bürstenhalter")
	hotspot("button", "Taster der Drehvorrichtung")
	set_verbs({"back": "go"})


func bag() -> String:
	return Game.value("ring_bag", "")


func refresh() -> void:
	layers["cloth"].visible = Game.flag("ring_cloth")
	layers["brush"].visible = Game.flag("ring_brush")
	layers["bag"].visible = bag() == "empty"
	layers["bag_full"].visible = bag() == "full"
	layers["dust_lost"].visible = Game.flag("dust_lost") and bag() == ""


func display_name(hs: Dictionary) -> String:
	if hs["id"] == "grating" and bag() != "":
		return "Fundtütchen" if bag() == "empty" else "Fundtütchen mit Kohlestaub"
	return hs["name"]


func look(hid: String) -> void:
	match hid:
		"drum":
			if Game.flag("ring_cloth"):
				await say("Schleifleinen um den Ring, Körnung nach außen, mit Kreppband festgeklebt.")
			else:
				await say("Ein Schleifring aus Kupfer, einen Meter breit. Spiegelglatt.")
		"holder":
			if Game.flag("ring_brush"):
				await say("Die Ersatzbürste sitzt im Halter. Die Feder drückt sie auf den Ring.")
			else:
				await say("Zwei Bürstenhalter aus Messing, beide leer. Die Federn sind zurückgeklappt.")
		"grating":
			match bag():
				"empty":
					await say("Mein Fundtütchen, genau unter dem Halter.")
				"full":
					await say("Das Tütchen ist voll feinem schwarzem Staub.")
				_:
					await say("Unter dem Rost eine Wanne mit altem Staub. Verklebt mit Lagerfett.")
		"button":
			await say("Ein grüner Taster. Drehvorrichtung, für die Wartung. Dreht die Welle langsam.")
		"back":
			await say("Zurück in den Maschinenraum.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"back":
			await go("inner_earth_machine_room")
		"drum":
			await refuse("Kupfer schleift nicht. Die Bürste soll sich daran abschleifen, nicht der Ring.")
		"holder":
			if Game.flag("ring_brush"):
				await Game.main.flush_gesture()
				Game.set_flag("ring_brush", false)
				Game.add_item("spare_brush")
				refresh()
			else:
				await refuse("Leer. Da gehört eine Bürste hinein.")
		"grating":
			await use_grating()
		"button":
			await turn()
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["drum", "emery_cloth"], ["holder", "emery_cloth"]:
			await attach_cloth()
		["drum", "masking_tape"]:
			if Game.has("emery_cloth"):
				await attach_cloth()
			else:
				await refuse("Klebeband auf blankes Kupfer? Was soll das bringen?")
		["holder", "spare_brush"], ["drum", "spare_brush"]:
			if Game.flag("ring_brush"):
				await refuse("Da steckt schon eine.")
				return
			await Game.main.flush_gesture()
			Game.remove_item("spare_brush")
			Game.set_flag("ring_brush")
			refresh()
			await say("Rein in den Halter. Die Feder drückt sie an den Ring.")
		["grating", "evidence_bag"], ["holder", "evidence_bag"]:
			if bag() != "":
				await refuse("Da liegt schon eins.")
				return
			await Game.main.flush_gesture()
			Game.set_flag("ring_bag", "empty")
			Game.set_flag("dust_lost", false)
			refresh()
			await say("Offen auf den Rost, genau unter den Halter.")
		["grating", "spatula"]:
			await refuse("Der alte Staub ist fettig. Fett trocknet nicht, die Farbe würde ewig schmieren.")
		["drum", "spatula"], ["holder", "spatula"]:
			await refuse("Mit dem Spatel bekomme ich nur Krümel. So schleife ich bis morgen.")
		_:
			await super(hid, item)


func attach_cloth() -> void:
	if Game.flag("ring_cloth"):
		await refuse("Das Leinen ist schon drauf.")
		return
	if not Game.has("masking_tape"):
		await refuse("Von allein hält das Leinen nicht auf dem Ring.")
		return
	await Game.main.flush_gesture()
	Game.remove_item("emery_cloth")
	Game.set_flag("ring_cloth")
	refresh()
	await say("Einmal herum, Körnung nach außen, Kreppband drauf. „VORSICHT – FRISCH RESTAURIERT“.")


func use_grating() -> void:
	match bag():
		"full":
			await Game.main.flush_gesture()
			Game.set_flag("ring_bag", "")
			Game.add_item("evidence_bag_coal")
			refresh()
			await say("Kohlestaub. Graphit und Kupfer. Fein wie Mehl.")
		"empty":
			await Game.main.flush_gesture()
			Game.set_flag("ring_bag", "")
			refresh()
		_:
			await refuse("Durch den Rost komme ich an die Wanne nicht heran. Und den fettigen Staub will ich auch nicht.")


func turn() -> void:
	await Game.main.flush_gesture()
	if not Game.flag("ring_cloth"):
		await narrate("[Die Welle dreht sich langsam. Blankes Kupfer gleitet vorbei.]")
		return
	if not Game.flag("ring_brush"):
		await narrate("[Das Schleifleinen dreht sich. Nichts berührt es.]")
		return
	await narrate("[Die Welle dreht sich. Die Bürste schabt über das Leinen, ein feiner schwarzer Staub rieselt herab.]")
	Game.set_flag("ring_brush", false)
	if bag() == "empty":
		Game.set_flag("ring_bag", "full")
		refresh()
		await say("Die Bürste ist eingeschliffen. Und der Staub liegt im Tütchen.")
	else:
		Game.set_flag("dust_lost")
		refresh()
		await say("Und alles durch den Rost in die Wanne. Zum Fett.")
