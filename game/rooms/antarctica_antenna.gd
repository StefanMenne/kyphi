extends Room
## Antarktis: Fuß der großen Antenne (Teil 2, draußen, Martin im Kälteanzug). Die unteren drei Meter der
## Turmleiter fehlen: hier kommt die Malerleiter hin. Im Schnee liegt 412s Steigschutzläufer.
## Aufstieg: Bild dunkel, Martin kommt wieder herunter und berichtet die erste nicht erfüllte Bedingung:
## Läufer -> Feder (412s Läufer) -> Anzug abgebunden (Wind) -> Leiterheizung (Ebene x zugefroren) -> Medaille.

const CR := preload("res://game/rooms/antarctica_control_room.gd")


func _init() -> void:
	asset_dir = "antarctica_antenna"
	suit = true


func build() -> void:
	tint = Color(0.82, 0.9, 0.92)
	shadow_alpha = 0.35
	hotspot("tower", "Antenne")
	hotspot("runner", "Etwas im Schnee", "left")
	hotspot("station", "Zurück zur Station", "left", "none")
	set_verbs({"station": "go"})


func refresh() -> void:
	layers["ladder"].visible = Game.flag("antenna_ladder")
	layers["runner_broken"].visible = not Game.flag("took_runner_broken")


func is_active(hid: String) -> bool:
	if hid == "runner":
		return not Game.flag("took_runner_broken")
	return true


func display_name(hs: Dictionary) -> String:
	if hs["id"] == "tower" and Game.flag("antenna_ladder"):
		return "Antenne mit Malerleiter"
	return hs["name"]


func on_enter(_from: String) -> void:
	if not Game.flag("antenna_seen"):
		Game.set_flag("antenna_seen")
		await say("Brrr. Die Heizung im Anzug schafft gerade so den Unterschied zwischen kalt und tot.")
		await say("Da ist sie, die große Antenne. Und die unteren drei Meter der Leiter fehlen.")


func look(hid: String) -> void:
	match hid:
		"tower":
			if Game.flag("antenna_ladder"):
				await say("Die Malerleiter reicht genau bis zur ersten Sprosse der Turmleiter.")
			else:
				await say("Die Turmleiter fängt erst drei Meter über dem Schnee an. Abgebaut, damit keiner raufklettert.")
		"runner":
			await say("Da liegt etwas Metallisches im Schnee.")
		"station":
			await say("Die Schleuse zurück in die Station.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"station":
			await go("antarctica_airlock")
		"runner":
			await take("runner_broken")
			await say("Ein Steigschutzläufer. Er muss von oben heruntergefallen sein. Die Feder ist gebrochen.")
		"tower":
			if not Game.flag("antenna_ladder"):
				await refuse("Ohne Leiter komme ich an die erste Sprosse nicht heran.")
			else:
				await climb()
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["tower", "ladder"]:
			await Game.main.flush_gesture()
			Game.remove_item("ladder")
			Game.set_flag("antenna_ladder")
			refresh()
			await say("Die gute alte Malerleiter. Passt genau.")
		["tower", "runner"], ["tower", "runner_broken"]:
			await climb()
		_:
			await super(hid, item)


## Aufstieg im Dunkeln; das Ergebnis berichtet Martin, wenn er wieder unten ist.
func climb() -> void:
	await Game.main.flush_gesture()
	if Game.flag("medal_found"):
		await refuse("Da oben war ich schon. Den Rest übernimmt die Station.")
		return
	var lines: Array
	if not Game.has("runner") and not Game.has("runner_broken"):
		await refuse("Ohne Steigschutzläufer gehe ich da nicht rauf. Ich will nicht enden wie 412.")
		return
	await Game.main.ui.fade_out(0.8)
	await Game.wait(1.5)
	if not Game.has("runner"):
		lines = ["Der Läufer greift nicht. Bei jedem Schritt rutscht er durch.", "Die Feder … die ist gebrochen. Mit dem Ding klettere ich nicht weiter."]
	elif not Game.flag("suit_taped"):
		lines = ["Viel zu windig da oben. Der riesige Anzug ist wie ein Segel.", "Der Wind trägt mich einfach weg."]
	elif CR.first_frozen() > 0:
		lines = ["Ebene %d ist komplett zugefroren. Da komme ich so nicht durch." % CR.first_frozen(), "Und es stürmt da oben."]
	else:
		Game.set_flag("medal_found")
		Game.add_item("medal")
		lines = ["Ich war ganz oben. Da liegt wirklich 412.", "Die Medaille hatte er noch um den Hals. Ich habe sie mitgenommen.", "Ich sage Pjotr Bescheid. Jetzt kann man ihn holen."]
	await Game.main.ui.fade_in(0.8)
	for l in lines:
		await say(l)
