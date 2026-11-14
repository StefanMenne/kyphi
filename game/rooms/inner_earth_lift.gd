class_name Lift
extends RefCounted
## Essenslift der Innenerde (concept/inner_earth.md, „Essenslift“): Kantine (oben), Hydroponik (Mitte), Küche
## (unten). Der Zustand steht in Game-Flags, damit alle drei Stationen dasselbe sehen:
## lift_at (Station der Kabine), lift_hatch_<station> (Luke offen), lift_alarm (Station mit Warnton oder ""),
## lift_contents (Gegenstände in der Kabine).
##
## Regeln: Der Lift fährt nur, wenn alle Luken zu sind. Wer eine Luke öffnet, während der Lift betriebsbereit
## ist, löst an dieser Luke einen anhaltenden Warnton aus; an den anderen Luken nicht.

const STATIONS := ["canteen", "hydroponics", "kitchen"]
const NAMES := {"canteen": "Kantine", "hydroponics": "Hydroponik", "kitchen": "Küche"}
## Gewicht in Gramm auf der Kabinenwaage (Zehntelgramm-Anzeige)
const WEIGHTS := {
	"masking_tape": 112.4,
	"evidence_bag": 3.1,
	"evidence_bag_hair": 3.1,
	"spatula": 38.6,
	"brush": 14.2,
	"brush_soot": 14.5,
	"tweezers": 11.8,
	"caliper": 168.0,
	"uv_lamp": 92.5,
	"id_card": 5.6,
	"thermos": 640.0,
	"salt": 96.3,
	"saucer": 154.7,
	"lighter": 21.9,
	"medal": 47.2,
	"walnut_oil": 268.5,
	"spare_brush": 21.4,
	"emery_cloth": 9.8,
	"evidence_bag_coal": 7.9,
}
## Hollmanns graue Karte und die schwarze Karte (Kantine); jede Schicht Kohlefarbe wiegt so viel
const GREY_CARD := 5.6
const BLACK_CARD := 6.6
const PAINT_LAYER := 0.25
## passt nicht in die Kabine
const TOO_BIG := ["ladder", "glycol_canister"]


static func at() -> String:
	return Game.value("lift_at", "kitchen")


static func is_open(station: String) -> bool:
	return Game.flag("lift_hatch_" + station)


## Betriebsbereit: alle Luken zu.
static func ready() -> bool:
	for s in STATIONS:
		if is_open(s):
			return false
	return true


static func alarm() -> String:
	return Game.value("lift_alarm", "")


## Luke öffnen; true, wenn dabei der Warnton losgeht.
static func open_hatch(station: String) -> bool:
	var warn := ready()
	Game.set_flag("lift_hatch_" + station)
	if warn:
		Game.set_flag("lift_alarm", station)
	return warn


static func close_hatch(station: String) -> void:
	Game.set_flag("lift_hatch_" + station, false)
	if alarm() == station:
		Game.set_flag("lift_alarm", "")


## Kabine zu einer Station schicken: "locked" (eine Luke offen), "here" (steht schon da), "passed" (fuhr an der
## Hydroponik vorbei) oder "moved".
static func send(target: String) -> String:
	if not ready():
		return "locked"
	if at() == target:
		return "here"
	var from := at()
	Game.set_flag("lift_at", target)
	if "hydroponics" not in [from, target]:
		return "passed"
	return "moved"


static func contents() -> Array:
	return (Game.value("lift_contents", []) as Array).duplicate()


static func put(item: String) -> void:
	var c := contents()
	c.append(item)
	Game.set_flag("lift_contents", c)


static func clear() -> Array:
	var c := contents()
	Game.set_flag("lift_contents", [])
	return c


static func weight() -> float:
	var w := 0.0
	for item in contents():
		w += item_weight(item)
	return w


static func item_weight(item: String) -> float:
	if item == "id_card":
		return GREY_CARD
	if item == "id_card_black":
		return GREY_CARD + PAINT_LAYER * int(Game.value("card_layers", 0))
	return WEIGHTS.get(item, 50.0)


static func weight_text() -> String:
	return ("%.1f g" % weight()).replace(".", ",")


# Bestellung am Automaten der Kantine (concept/inner_earth.md, „Ablauf einer Bestellung“): Karte einstecken; der
# Automat holt den Lift, räumt ihn aus (Inhalt auf die Ablage der Kantine), stellt ein Tablett mit der Karte hinein
# und schickt ihn in die Küche. Der Koch prüft Karte und Gewicht, kocht und schickt ihn zurück. Ist eine Luke offen,
# wartet der Automat; der ganze Ablauf läuft, sobald die letzte Luke zugeht (run_order).

## leeres Tablett auf der Waage
const TRAY := 412.3


## Bestellung aufgeben: who "guest" (Gast mit schwarzer Karte) oder "martin" (card: id_card oder id_card_black)
static func order(who: String, card: String) -> void:
	Game.set_flag("lift_order", {"who": who, "card": card})


static func pending() -> bool:
	return not (Game.value("lift_order", {}) as Dictionary).is_empty()


static func card_weight(card: String) -> float:
	return BLACK_CARD if card == "guest_card" else item_weight(card)


## Läuft eine wartende Bestellung, wenn der Lift bereit ist. Ergebnis {} oder {"who", "card", "down" (Gewicht auf
## dem Weg in die Küche, Text), "result" ("better", "standard", "rejected"), "cleared" (Gegenstände aus der Kabine)}
static func run_order() -> Dictionary:
	if not pending() or not ready():
		return {}
	var o: Dictionary = Game.value("lift_order")
	var card: String = "guest_card" if o["who"] == "guest" else o["card"]
	var cleared := clear()
	if not cleared.is_empty():
		var shelf: Array = (Game.value("canteen_shelf", []) as Array).duplicate()
		shelf.append_array(cleared)
		Game.set_flag("canteen_shelf", shelf)
	var w := TRAY + card_weight(card)
	var result := "standard"
	if card == "guest_card":
		result = "better"
	elif card == "id_card_black":
		result = "better" if absf(card_weight(card) - BLACK_CARD) < 0.05 else "rejected"
	Game.set_flag("lift_order", {})
	Game.set_flag("lift_at", "canteen")
	if o["who"] == "guest":
		Game.set_flag("guest_state", "eating")
	else:
		Game.set_flag("canteen_tray", result)
		Game.set_flag("canteen_tray_card", card)
	return {"who": o["who"], "card": card, "down": ("%.1f g" % w).replace(".", ","), "result": result,
		"cleared": cleared}

