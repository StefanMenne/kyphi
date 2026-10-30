class_name ItemLogic
extends RefCounted
## Ansehen und Kombinieren im Inventar, unabhängig vom Raum.

const LOOK := {
	"batteries": "Zwei AA-Batterien. Noch fast voll.",
	"ladder": "Die Malerleiter. Zusammengeklappt passt sie durch jede Tür.",
	"tweezers": "Eine Pinzette.",
	"evidence_bag": "Fundtütchen. Für alles, was man besser nicht anfasst.",
	"evidence_bag_hair": "Ein langes graues Haar, sauber gesichert.",
	"brush": "Ein weicher Pinsel.",
	"brush_soot": "Der Pinsel ist voller Ruß.",
	"spatula": "Ein Spatel. Mein Universalwerkzeug.",
	"spatula_soot": "Feiner Ruß von der Decke.",
	"masking_tape": "Kreppband: „VORSICHT – FRISCH RESTAURIERT“.",
	"caliper": "Ein Messschieber, mit Tiefenmaß.",
	"uv_lamp": "Eine UV-Lampe. Alter Schellack leuchtet darunter grünlich.",
	"depot_key": "Der Depotschlüssel. Ordnungsgemäß eingetragen.",
	"id_card": "Hollmanns Mitarbeiterausweis. Veraltetes Foto, sehr ernster Blick.",
	"lighter": "Frau Ackermanns Feuerzeug. Offiziell besitzt sie keins.",
	"saucer": "Eine Untertasse. Sonst mische ich darauf Retuschierfarben.",
	"cone_saucer": "Der Kegel glimmt. Feiner Rauch steigt auf.",
	"drill": "Ein Akkuschrauber. Für Spezialschrauben habe ich keinen Bit.",
	"drill_bit": "Akkuschrauber mit Dreikant-Bit.",
	"remote": "Die Fernbedienung.",
}

const FIRE := ["incense_cone", "saucer", "lighter"]


func say(text: String, voice := "") -> void:
	await Game.say("martin", text, voice)


func look(id: String) -> void:
	match id:
		"dictaphone":
			if not Game.flag("dictaphone_powered"):
				await say("Mein Diktiergerät. Die Batterien sind leer.")
				return
			await Game.note("Restkapazität: 4 Std.\nSprachaktivierung (VOX): %s" % ("an" if Game.flag("vox") else "aus"))
			if not Game.flag("vox"):
				var i := await Game.choose(["Sprachaktivierung (VOX) einschalten", "Lieber nicht"])
				if i == 0:
					Game.set_flag("vox")
					await say("VOX ist an. Jetzt nimmt es nur auf, wenn es etwas hört.")
		"index_card":
			await Game.note("Holtz, Grafik –\nzwei Mappen Radierungen.")
			await say("Belanglos. Aber Hollmanns Karte stand direkt davor.")
		"index_card_revealed":
			await Game.note("Hollmann, Nachlass –\nWerkzeug, persönl. Gegenst. –\nD-0912")
			await say("D-0912. Regal D, Fach 09, Platz 12.")
		"notebook":
			await Game.note("Eine Skizze der Westwand: sechs Paneele.\nEines ist schraffiert – welches, ist verwischt.")
			await Game.note("Letzte Seite, zittrige Schrift:\n\n„Sie kommen durch die Wand.\nRauch lügt nicht.“")
			await say("Sie kommen durch die Wand. Rauch lügt nicht.", "martin/notebook")
		"incense_cone":
			if Game.flag("kyphi_known"):
				await say("Kyphi. Tempelräucherwerk aus Hollmanns Kiste.")
			else:
				await say("Ein Räucherkegel aus dunklem Harz. Riecht süßlich.")
		"screw_bit":
			if Game.flag("screws_found"):
				await say("Dreikant. Genau wie die Schrauben am Paneel.")
			else:
				await say("Ein Schrauberbit mit Dreikantkopf. Damit kann ich noch nichts anfangen.")
		_:
			await say(LOOK.get(id, "Hm."))


func combine(a: String, b: String) -> void:
	var pair := [a, b]
	pair.sort()
	match pair:
		["batteries", "dictaphone"]:
			Game.remove_item("batteries")
			Game.set_flag("dictaphone_powered")
			await say("Das Diktiergerät läuft wieder.")
		["brush", "spatula_soot"]:
			Game.swap_item("brush", "brush_soot")
			Game.swap_item("spatula_soot", "spatula")
			await say("Ruß auf den Pinsel.")
		["brush_soot", "index_card"]:
			Game.swap_item("index_card", "index_card_revealed")
			Game.swap_item("brush_soot", "brush")
			await say("Die eingedrückte Schrift bleibt hell …")
			await Game.note("Hollmann, Nachlass –\nWerkzeug, persönl. Gegenst. –\nD-0912")
			await say("D-0912. Die Inventarnummer.")
		["index_card", "spatula_soot"]:
			await say("Mit dem Spatel verschmiere ich alles. Dafür braucht es einen Pinsel.")
		["drill", "screw_bit"]:
			Game.remove_item("screw_bit")
			Game.swap_item("drill", "drill_bit")
			await say("Passt.")
		["cone_saucer", "lighter"]:
			await say("Brennt schon.")
		_:
			if a in FIRE and b in FIRE:
				await _fire(pair)
			else:
				await say(Room.ITEM_FAIL.pick_random())


## Kegel, Untertasse und Feuerzeug: angezündet wird nur im Altarraum.
func _fire(pair: Array) -> void:
	if pair == ["lighter", "saucer"]:
		await say("Eine Untertasse anzünden? Nein.")
	elif not FIRE.all(func(i): return Game.has(i)):
		if not Game.has("lighter"):
			await say("Kegel auf die Untertasse, gut. Jetzt fehlt nur Feuer.")
		else:
			await say("Ohne feuerfeste Unterlage brennt mir die Glut auf den Boden.")
	elif Game.room_id != "altar_room":
		await say("Nicht hier. Wenn, dann im Altarraum.")
	else:
		await Game.main.room.light_cone()
