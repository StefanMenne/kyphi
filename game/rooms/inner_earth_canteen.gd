extends Room
## Innenerde: Kantine (concept/inner_earth.md, „Kantine“, „Essenslift“, „Gewicht der schwarzen Karte“). Links die
## Tür zur Galerie, die Ausgabe aus Edelstahl mit der Liftluke (öffnet nur der Automat), die Säule mit Kartenschlitz
## und kaputter Menüanzeige, daneben am kleinen Tisch der Gast mit der schwarzen Karte, rechts die langen Tische mit
## den Salzstreuern.
##
## Der Gast bestellt erst, wenn Martin ihm sagt, was es heute gibt (Tafel in der Küche). Bestellungen laufen über
## das Liftmodell (Lift.order, Lift.run_order): Ist irgendwo eine Luke offen, wartet der Automat.

const KITCHEN := preload("res://game/rooms/inner_earth_kitchen.gd")
## Gast am Kartenschlitz (linke obere Ecke des Bildes stand.png)
const STAND_POS := Vector2(605, 244)

var guest: Npc
var sit_pos := Vector2.ZERO


func _init() -> void:
	asset_dir = "inner_earth_canteen"


func build() -> void:
	tint = Color(0.97, 1.0, 0.97)
	guest = add_npc("guest", ["stand"])
	hotspot("door", "Tür zur Galerie", "none")
	hotspot("hatch", "Ausgabe")
	hotspot("display", "Menüanzeige")
	hotspot("slot", "Kartenschlitz")
	hotspot("guest", "Gast", "none")
	hotspot("small_table", "Kleiner Tisch")
	hotspot("long_tables", "Lange Tische")
	hotspot("salt", "Salzstreuer")
	hotspot("clock", "Uhr")
	set_verbs({"door": "go", "guest": "talk", "salt": "take"})


func dish() -> String:
	return KITCHEN.DISH.replace("\n", " ")


func guest_state() -> String:
	return Game.value("guest_state", "")


func refresh() -> void:
	var tray: String = Game.value("canteen_tray", "")
	layers["hatch_open_thermos"].visible = tray == "better"
	layers["hatch_open_tray"].visible = tray == "standard"
	layers["salt_taken"].visible = Game.flag("took_salt")
	if sit_pos == Vector2.ZERO:
		sit_pos = guest.position
	var standing := guest_state() == "ordered"
	guest.rest = "stand" if standing else "idle"
	guest.position = STAND_POS if standing else sit_pos
	var hs = find_hotspot("guest")
	hs["area"] = Rect2(guest.position, guest.texture.get_size() if not standing else Vector2(152, 320))


func is_active(hid: String) -> bool:
	if hid == "salt":
		return not Game.flag("took_salt")
	return true


func on_enter(_from: String) -> void:
	if not Game.flag("canteen_seen"):
		Game.set_flag("canteen_seen")
		await say("Eine Kantine. Ein einziger Gast, und der sieht aus, als warte er schon länger.")


func look(hid: String) -> void:
	match hid:
		"door":
			await say("Die Tür zur Galerie.")
		"hatch":
			match Game.value("canteen_tray", ""):
				"better":
					await say("Ein Tablett mit Essen, meiner Karte und einer Thermoskanne.")
				"standard":
					await say("Ein Tablett mit Essen und meiner Karte.")
				"rejected":
					await say("Auf dem Tablett liegt nur meine Karte.")
				_:
					await say("Die Ausgabe. Eine Liftluke mit Glasfenster, ohne Knöpfe. Die öffnet nur der Automat.")
		"display":
			await say("Die Menüanzeige. Dunkel, mit einem Sprung quer durchs Glas.")
		"slot":
			await say("Ein Kartenschlitz. Er leuchtet freundlich, als wüsste er nicht, dass die Anzeige kaputt ist.")
		"guest":
			if guest_state() == "ordered":
				await say("Er steht am Automaten und wartet. Ungeduldig.")
			else:
				await say("Ein hagerer Herr mit Nickelbrille. Er hat eine schwarze Karte vor sich liegen.")
		"small_table":
			await say("Ein kleiner Tisch für zwei. Der zweite Stuhl ist frei, aber einladend wirkt er nicht.")
		"long_tables":
			await say("Lange Tische, leer. Abendbrot ist wohl vorbei. Oder noch nicht.")
		"salt":
			await say("Ein Salzstreuer.")
		"clock":
			await say("Die Uhr geht. Immerhin.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"door":
			await go("inner_earth_station")
		"guest":
			await talk_guest()
		"hatch":
			await take_tray()
		"salt":
			await take("salt", "Wer weiß, wofür man Salz noch braucht.")
		"slot":
			await refuse("Ohne Karte tut sich da nichts.")
		"display":
			await refuse("Die ist hin. Da hilft auch Klopfen nicht.")
		"small_table", "long_tables", "clock":
			await refuse("Das bringt mir nichts.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["slot", "id_card"], ["slot", "id_card_black"]:
			await order(item)
		["slot", _]:
			await refuse("Da passt nur eine Karte hinein.")
		["guest", "id_card"], ["guest", "id_card_black"]:
			await Game.say("guest", "Ihre Karte geht mich nichts an. Meine Sie übrigens auch nicht.")
		_:
			await super(hid, item)


func order(card: String) -> void:
	if Lift.pending():
		await refuse("Der Automat ist beschäftigt.")
		return
	if Game.value("canteen_tray", "") != "":
		await refuse("Erst nehme ich, was schon in der Ausgabe liegt.")
		return
	await Game.main.flush_gesture()
	Game.remove_item(card)
	Lift.order("martin", card)
	await narrate("[Der Automat schluckt die Karte und summt.]")
	await run_here()


## Läuft eine wartende Bestellung, solange Martin in der Kantine ist: der ganze Weg in einer Blende.
func run_here() -> void:
	var r := Lift.run_order()
	if r.is_empty():
		await narrate("[Hinter der Ausgabe tut sich nichts. Der Automat wartet auf den Lift.]")
		return
	await narrate("[Surren im Schacht. Nach einer Weile klappt die Ausgabe auf.]")
	refresh()
	if r["who"] == "guest":
		await narrate("[Der Gast nimmt sein Tablett, mit Thermoskanne, und setzt sich wieder.]")
	elif r["result"] == "rejected":
		await say("Nur meine Karte, kein Essen. Der Koch hat sie abgelehnt.")


func take_tray() -> void:
	var tray: String = Game.value("canteen_tray", "")
	var shelf: Array = Game.value("canteen_shelf", [])
	if tray == "" and shelf.is_empty():
		await refuse("Die Luke öffnet nur der Automat.")
		return
	await Game.main.flush_gesture()
	for item in shelf:
		Game.add_item(item)
	Game.set_flag("canteen_shelf", [])
	if tray != "":
		Game.add_item(Game.value("canteen_tray_card"))
		Game.set_flag("canteen_tray", "")
	refresh()
	match tray:
		"better":
			Game.add_item("thermos")
			Game.set_flag("better_menu")
			await say("Das bessere Menü. Mit Thermoskanne. Heißer Tee!")
			await say("Die Karte hat bestanden.")
		"standard":
			await say("%s. Nicht schlecht für eine Sekte." % dish())
		"rejected":
			await say("Das Gewicht stimmt nicht. Der Koch merkt so etwas.")


func talk_guest() -> void:
	if guest_state() == "ordered":
		await Game.say("guest", "Wo bleibt der Lift? Irgendwo steht wieder eine Klappe offen. Eine Schlamperei ist das.")
		return
	if not Game.flag("guest_met"):
		Game.set_flag("guest_met")
		await say("Guten Tag.")
		await Game.say("guest", "Ob er gut wird, entscheidet sich, wenn ich weiß, was es gibt.")
	var opts := ["Worauf warten Sie?"]
	if Game.flag("dish_known"):
		opts.append("Heute gibt es %s." % dish())
	opts.append_array(["Heute gibt es Schnitzel.", "Was ist das für eine Karte?", "Auf Wiedersehen."])
	var c: String = opts[await Game.choose(opts)]
	if c != "Auf Wiedersehen.":
		await say(c)
	if c.begins_with("Worauf"):
		await Game.say("guest", "Auf mein Leibgericht. Die Anzeige ist kaputt, und ich bestelle doch nicht blind.")
	elif c.ends_with(dish() + "."):
		if guest_state() == "eating":
			await Game.say("guest", "Noch eine Portion? Warum eigentlich nicht.")
		else:
			await Game.say("guest", "%s? Das hätten Sie gleich sagen können!" % dish())
		Game.set_flag("guest_state", "ordered")
		refresh()
		Lift.order("guest", "")
		await narrate("[Der Gast steht auf und steckt seine schwarze Karte in den Automaten.]")
		await run_here()
	elif c.begins_with("Heute gibt es"):
		await Game.say("guest", "Woher wollen Sie das wissen? Raten kann ich selbst.")
	elif c.begins_with("Was ist"):
		await Game.say("guest", "Schwarz. Höhere Stufe. Damit gibt es das bessere Menü, mit Tee. Ihre ist grau, nehme ich an.")
