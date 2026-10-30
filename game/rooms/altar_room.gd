extends Room
## Altarraum: Rauchmelder, Asche, Ruß, Altarschrank, Westwand mit Paneel 4 und Stahltür.

const PANELS := [
	Rect2(1556, 60, 67, 410), Rect2(1623, 60, 77, 410), Rect2(1700, 60, 102, 410),
	Rect2(1802, 60, 123, 410), Rect2(1925, 60, 123, 410)]
const LADDER_POS := Vector2(950, 113)
const LADDER_SIZE := Vector2(134, 267)
const UV := Color(0.55, 0.42, 0.95)

var ladder: Sprite2D
var smoke: CPUParticles2D


func _init() -> void:
	asset_dir = "altarraum"


func build() -> void:
	floor_poly = PackedVector2Array([
		Vector2(30, 478), Vector2(370, 461), Vector2(1590, 461), Vector2(2000, 472),
		Vector2(2048, 480), Vector2(2048, 576), Vector2(0, 576), Vector2(0, 480)])
	depth = [Vector2(461, 238), Vector2(576, 312)]
	tint = Color(0.68, 0.63, 0.6)
	entries = {
		"": [Vector2(1000, 520), "front", ""],
		"workshop": [Vector2(110, 492), "right", "workshop_door_open"],
	}
	ladder = add_sprite(load("res://assets/scenes/altarraum/sprites/ladder.png"), LADDER_POS)
	# wie Martin im Licht des Raums
	ladder.modulate = tint
	move_child(ladder, 1)
	smoke = CPUParticles2D.new()
	smoke.amount = 40
	smoke.lifetime = 2.5
	smoke.direction = Vector2(0, -1)
	smoke.spread = 12
	smoke.gravity = Vector2(0, -12)
	smoke.initial_velocity_min = 12
	smoke.initial_velocity_max = 22
	smoke.scale_amount_min = 3
	smoke.scale_amount_max = 6
	smoke.color = Color(0.85, 0.85, 0.85, 0.35)
	smoke.emitting = false
	add_child(smoke)

	hotspot("podium", "Podest", Rect2(220, 338, 1557, 123), Vector2(1000, 466))
	hotspot("pillars", "Säulen", Rect2(466, 30, 230, 340), Vector2(580, 466))
	hotspot("pillars2", "Säulen", Rect2(1270, 30, 245, 340), Vector2(1390, 466))
	hotspot("cabinet", "Altarschrank", Rect2(225, 386, 150, 70), Vector2(300, 470))
	hotspot("altar", "Opferaltar", Rect2(783, 225, 195, 113), Vector2(880, 466))
	hotspot("ash", "Räucheraltar mit Asche", Rect2(1065, 210, 153, 128), Vector2(1140, 466))
	hotspot("soot", "Ruß an der Decke", Rect2(800, 0, 378, 62), Vector2(1000, 466))
	hotspot("detector", "Rauchmelder", Rect2(975, 0, 85, 46), Vector2(1000, 466))
	hotspot("ladder", "Malerleiter", Rect2(LADDER_POS, LADDER_SIZE), Vector2(1000, 466))
	for i in PANELS.size():
		var r: Rect2 = PANELS[i]
		hotspot("panel_%d" % (i + 1), "Holzverkleidung", r, Vector2(r.get_center().x, 474))
	hotspot("steel_door", "Stahltür mit Kartenleser", layer_rect("steel_door_closed"), Vector2(1864, 476))
	hotspot("workshop_door", "Tür zur Werkstatt", Rect2(36, 148, 113, 323), Vector2(105, 488), "left")


func refresh() -> void:
	layers["detector_taped"].visible = not Game.flag("tape_removed") or Game.flag("detector_retaped")
	layers["steel_door_closed"].visible = Game.flag("panel_removed")
	layers["steel_door_open"].visible = Game.flag("steel_door_open")
	ladder.visible = Game.flag("ladder_placed")


func _process(_dt: float) -> void:
	smoke.emitting = Game.has("cone_saucer")
	var p: Player = Game.main.player
	smoke.position = p.position + Vector2(55, -250) * p.scale


func is_active(hid: String) -> bool:
	match hid:
		"ladder":
			return Game.flag("ladder_placed")
		"steel_door":
			return Game.flag("panel_removed")
		"panel_4":
			return not Game.flag("panel_removed")
	return true


func display_name(hs: Dictionary) -> String:
	if hs["id"] == "panel_4" and Game.flag("panel4_found"):
		return "Paneel 4"
	return hs["name"]


func on_enter(_from: String) -> void:
	if not Game.flag("altar_seen"):
		Game.set_flag("altar_seen")
		await say("Asche auf dem Altar und Ruß an der Decke. Offenes Feuer ist hier streng verboten. Und der Rauchmelder hat nichts gemerkt? Interessant.", "martin/reference")


func look(hid: String) -> void:
	match hid:
		"podium":
			await say("Das Podest. Zehn Stufen, wie im Original.")
		"pillars", "pillars2":
			await say("Die Säulen. Bemalt, nicht original, aber gut gemacht.")
		"cabinet":
			await say("Der Altarschrank. Eine Nachbildung, ins Podest eingebaut. Ich lagere darin Material.")
		"altar":
			await say("Der Opferaltar. Sechs mal drei Meter, mein aktuelles Projekt.")
		"ash":
			if Game.has("incense_cone"):
				await kyphi()
			else:
				await say("Feine Asche auf dem Räucheraltar. Sie riecht süßlich, nach Harz und Honig.")
		"soot":
			await say("Ruß an der Decke, direkt über dem Altar. Hier hat etwas gebrannt.")
		"detector":
			if Game.flag("detector_retaped"):
				await say("Abgeklebt. Diesmal von mir.")
			elif Game.flag("tape_removed"):
				await say("Der Rauchmelder ist wieder frei.")
			elif Game.flag("detector_seen"):
				await say("Abgeklebt. Darunter klebt ein langes graues Haar." if not Game.flag("hair_secured") else "Noch abgeklebt.")
			else:
				await say("Der Rauchmelder. Bei dem Ruß hätte er längst anschlagen müssen.")
		"ladder":
			await say("Die Malerleiter. Steht.")
		"steel_door":
			await say("Eine neue Stahltür mit Kartenleser. Dasselbe Modell wie an den Personaltüren des Museums.")
		"workshop_door":
			await say("Die Tür zur Werkstatt.")
		_:
			if hid.begins_with("panel_"):
				if Game.flag("plugs_removed") and hid == "panel_4":
					await say("Dreikant-Sicherheitsschrauben. Hinter einer Wandverkleidung aus den Zwanzigern.")
				else:
					await say("Eichenpaneele, angeblich aus den 1920er-Jahren. Holzzapfen verdecken die Schraubenköpfe.")
			else:
				await super(hid)


func use(hid: String) -> void:
	match hid:
		"workshop_door":
			if Game.has("cone_saucer"):
				await say("Mit dem brennenden Kegel? Nicht durchs Museum.")
				return
			await go("workshop", "workshop_door_open")
		"cabinet":
			await cabinet()
		"detector":
			await detector()
		"soot":
			if not Game.flag("ladder_placed"):
				await say("Viel zu hoch.")
			else:
				await say("Mit bloßen Fingern? Dafür gibt es Werkzeug.")
		"ladder":
			await say("Die bleibt hier stehen. Die brauche ich noch.")
		"ash":
			await say("Nicht anfassen. Das ist ein Befund.")
		"steel_door":
			await say("Verschlossen. Daneben ein Kartenleser.")
		_:
			if hid.begins_with("panel_"):
				await say("Fest verschraubt.")
			else:
				await super(hid)


func use_item(hid: String, item: String) -> void:
	if item == "ladder" and hid in ["detector", "soot", "podium", "altar", "ash"]:
		Game.remove_item("ladder")
		Game.set_flag("ladder_placed")
		refresh()
		await say("So. Jetzt komme ich an die Decke.")
		return
	match [hid, item]:
		["detector", "tweezers"]:
			await take_hair()
		["detector", "masking_tape"]:
			await retape()
		["soot", "spatula"]:
			if not Game.flag("ladder_placed"):
				await say("Viel zu hoch.")
				return
			Game.swap_item("spatula", "spatula_soot")
			await say("Ein bisschen Ruß. Könnte nützlich sein.")
		["cabinet", "dictaphone"]:
			await hide_dictaphone()
		["ash", "incense_cone"]:
			await kyphi()
		["steel_door", "id_card"]:
			await open_steel_door()
		_:
			if hid.begins_with("panel_"):
				await panel(int(hid.substr(6)), item)
			else:
				await super(hid, item)


# Kapitel 1: Der abgeklebte Rauchmelder

func detector() -> void:
	if not Game.flag("ladder_placed"):
		await say("Viel zu hoch. Ich brauche die Leiter aus der Werkstatt.")
	elif not Game.flag("detector_seen"):
		Game.set_flag("detector_seen")
		await say("Der Melder ist mit Klebeband abgedeckt. Und darunter klebt ein langes graues Haar.")
	elif not Game.flag("hair_secured"):
		await say("Mit bloßen Händen?")
		await say("Kontamination. Nein.", "martin/contamination")
	elif not Game.flag("tape_removed"):
		Game.set_flag("tape_removed")
		refresh()
		await say("Und das Klebeband kommt ab. Brandschutz geht vor.")
		await say("Hier ist nachts jemand. Und er bereitet sich vor. Ich will wissen, wer.")
	else:
		await say("Der Melder ist frei.")


func take_hair() -> void:
	if not Game.flag("detector_seen") or not Game.flag("ladder_placed"):
		await detector()
	elif Game.flag("hair_secured"):
		await say("Das Haar habe ich schon.")
	elif not Game.has("evidence_bag"):
		await say("Und wohin damit? Ich brauche ein Fundtütchen.")
	else:
		Game.set_flag("hair_secured")
		Game.swap_item("evidence_bag", "evidence_bag_hair")
		await say("Pinzette, Fundtütchen. Gesichert.")


func retape() -> void:
	if not Game.flag("ladder_placed"):
		await say("Viel zu hoch.")
	elif not Game.flag("tape_removed"):
		await say("Der ist noch abgeklebt.")
	elif Game.flag("detector_retaped"):
		await say("Hält.")
	elif not Game.flag("recording_heard"):
		await say("Ich habe das Band gerade erst abgezogen. Brandschutz.")
	else:
		Game.set_flag("detector_retaped")
		refresh()
		await say("„VORSICHT – FRISCH RESTAURIERT“. Passt.")


# Kapitel 2 und 3: Diktiergerät im Altarschrank

func hide_dictaphone() -> void:
	if not Game.flag("tape_removed"):
		await say("Erst will ich wissen, was mit dem Rauchmelder los ist.")
	elif not Game.flag("dictaphone_powered"):
		await say("Ohne Batterien nimmt es nichts auf.")
	elif not Game.flag("vox"):
		await say("Restkapazität: vier Stunden. Von 18 Uhr bis morgen früh reicht das nicht.")
	else:
		Game.remove_item("dictaphone")
		Game.set_flag("dictaphone_hidden")
		await narrate("[Martin versteckt das Diktiergerät im Altarschrank.]")
		await say("Wenn da nachts niemand ist, habe ich morgen eine sehr leere Datei und ein sehr gutes Gewissen.", "martin/empty_file")
		await say("Feierabend. Ab nach Hause.")


func cabinet() -> void:
	if Game.flag("dictaphone_hidden") and not Game.flag("night_done"):
		await say("Das Diktiergerät liegt gut versteckt. Jetzt nach Hause.")
	elif Game.flag("night_done") and not Game.flag("dictaphone_retrieved"):
		Game.set_flag("dictaphone_retrieved")
		Game.add_item("dictaphone")
		await say("Da ist es. Abhören am Laptop, zu Hause.")
	else:
		await say("Mein Material. Nichts, was mir gerade weiterhilft.")


# Kapitel 6: Kyphi, Feuer, Luftzug

func kyphi() -> void:
	Game.set_flag("kyphi_known")
	await say("Honig, Wacholder, Harz … das ist Kyphi. Tempelräucherwerk. Dasselbe wie in der Asche.", "martin/kyphi")


## Wird aus ItemLogic aufgerufen, wenn Kegel, Untertasse und Feuerzeug zusammenkommen.
func light_cone() -> void:
	Game.remove_item("incense_cone")
	Game.swap_item("saucer", "cone_saucer")
	await narrate("[Martin stellt den Kegel auf die Untertasse und zündet ihn an.]")
	if Game.flag("tape_removed") and not Game.flag("detector_retaped"):
		await alarm()
	elif not Game.flag("lit_once"):
		Game.set_flag("lit_once")
		await say("Großartig. Jetzt bin ich einer von denen.", "martin/one_of_them")


## Kapitel 6b: Der Melder schlägt an, Frau Ackermann kommt, immer knapper.
func alarm() -> void:
	var n: int = int(Game.value("alarms")) + 1
	Game.set_flag("alarms", n)
	Game.main.beep(2.5)
	Game.main.ui.flash(Color(1, 0.1, 0.05), 5)
	await narrate("[Der Rauchmelder schrillt.]")
	await Game.wait(0.8)
	match n:
		1:
			await Game.say("ackermann", "Herr Kessler! Offenes Feuer! Im Altarraum! Haben Sie den Verstand verloren?", "ackermann/alarm_1")
		2:
			await Game.say("ackermann", "Schon WIEDER? Ich habe einen Kater, Herr Kessler. Der wartet nicht.", "ackermann/alarm_2")
		3:
			await Game.say("ackermann", "Ordnung. Muss. Sein.", "ackermann/alarm_3")
		_:
			await narrate("[Frau Ackermann kommt wortlos herein, drückt den Alarm weg, sieht Martin lange an und geht wieder.]")
	if n <= 3:
		await narrate("[Frau Ackermann setzt den Alarm zurück, drückt den Kegel aus und geht.]")
	Game.main.sfx.stop()
	Game.swap_item("cone_saucer", "saucer")
	Game.add_item("incense_cone")
	if n == 1:
		await say("Der Melder. Natürlich. Den muss ich wieder abkleben.")


func panel(n: int, item: String) -> void:
	match item:
		"cone_saucer":
			if n == 4:
				Game.set_flag("panel4_found")
				await narrate("[Der Rauch wird in die Fuge von Paneel 4 gezogen.]")
				await say("Dahinter ist ein Hohlraum. Mit Luftzug. Wie die Schraffur im Notizbuch.")
			else:
				await say("Der Rauch steigt gerade nach oben.")
		"uv_lamp":
			await _uv_glow()
			if n == 4:
				Game.set_flag("plugs_found")
				await say("Alter Schellack leuchtet grünlich. Aber vier Zapfen bleiben dunkel. Die sind neu.")
				await say("Die Zwanzigerjahre hatten keinen Weißleim.", "martin/no_white_glue")
			else:
				await say("Alles grünlich. Alter Schellack, wie es sich gehört.")
		"spatula", "spatula_soot":
			if n == 4 and Game.flag("plugs_found"):
				if Game.flag("plugs_removed"):
					await say("Die Zapfen sind schon draußen.")
					return
				Game.set_flag("plugs_removed")
				Game.set_flag("screws_found")
				await narrate("[Martin hebelt die vier neuen Zapfen heraus.]")
				await say("Darunter: Dreikant-Sicherheitsschrauben. Dafür passt kein normaler Bit.")
			else:
				await say("Welche Zapfen? Die sehen alle gleich alt aus.")
		"drill":
			if n == 4 and Game.flag("plugs_removed"):
				await say("Kein normaler Bit passt auf Dreikantschrauben.")
			else:
				await say("Ich bohre doch keine Löcher in ein Paneel aus den Zwanzigern.")
		"drill_bit":
			if n == 4 and Game.flag("plugs_removed"):
				await say("Hollmann, du alter Fuchs. Du hast es gewusst.", "martin/old_fox")
				await narrate("[Die Schrauben lösen sich. Martin nimmt das Paneel ab.]")
				Game.set_flag("panel_removed")
				refresh()
			else:
				await say("Hier sind keine Schrauben zu sehen.")
		_:
			await super.use_item("panel_%d" % n, item)


func _uv_glow() -> void:
	if Game.fast:
		return
	var tw := create_tween()
	tw.tween_property(self, "modulate", UV, 0.3)
	tw.tween_interval(1.2)
	tw.tween_property(self, "modulate", Color.WHITE, 0.4)
	await Game.wait(0.4)


# Kapitel 8: Die Tür mit dem Kartenschlitz

func open_steel_door() -> void:
	await narrate("[Martin steckt Hollmanns Ausweis in den Kartenleser. Eine kurze Pause.]")
	await Game.wait(1.0)
	await narrate("[Dann leuchtet die Anzeige grün.]")
	await say("Zwei Jahre verschwunden, und keiner hat seinen Ausweis gesperrt. Ordnung muss sein, Frau Ackermann.", "martin/badge_not_blocked")
	Game.set_flag("steel_door_open")
	refresh()
	await Game.wait(0.8)
	await narrate("[Eine schmale Treppe führt nach unten. Kühle Luft und der Geruch von Kyphi steigen herauf.]")
	await narrate("[Aus der Tiefe dringt ein an- und abschwellendes Rauschen, wie von einem Zug, der sehr schnell vorbeifährt.]")
	await Game.main.ending()
