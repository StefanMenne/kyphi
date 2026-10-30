extends Room
## Werkstatt: die meisten Werkzeuge liegen hier.

## Gegenstand -> [Ebene, Name, Laufpunkt-x]
const TOOLS := {
	"ladder": ["ladder", "Malerleiter", 380],
	"brush": ["brush", "Pinsel", 470],
	"spatula": ["spatula", "Spatel", 595],
	"drill": ["drill", "Akkuschrauber", 600],
	"uv_lamp": ["uv_lamp", "UV-Lampe", 650],
	"tweezers": ["tweezers", "Pinzette", 675],
	"evidence_bag": ["evidence_bags", "Fundtütchen", 710],
	"caliper": ["caliper", "Messschieber", 760],
	"saucer": ["saucer", "Untertasse", 805],
	"masking_tape": ["masking_tape", "Kreppband", 845],
}


func _init() -> void:
	asset_dir = "werkstatt"


func build() -> void:
	floor_poly = PackedVector2Array([
		Vector2(215, 472), Vector2(1135, 472), Vector2(1280, 522), Vector2(1344, 556),
		Vector2(1344, 768), Vector2(0, 768), Vector2(0, 562), Vector2(110, 552), Vector2(215, 505)])
	depth = [Vector2(472, 300), Vector2(768, 520)]
	entries = {
		"": [Vector2(670, 560), "front", ""],
		"lobby": [Vector2(170, 540), "right", "lobby_door_open"],
		"altar_room": [Vector2(1200, 552), "left", "altar_door_open"],
	}
	hotspot("boxes", "Kisten", Rect2(0, 362, 108, 190), Vector2(150, 560), "left")
	hotspot("boxes2", "Kisten", Rect2(278, 368, 110, 97), Vector2(330, 490))
	hotspot("shelf", "Regal", Rect2(930, 180, 195, 290), Vector2(1030, 490))
	hotspot("pegboard", "Lochwand", Rect2(448, 158, 450, 120), Vector2(670, 492))
	hotspot("bench", "Werkbank", Rect2(380, 325, 590, 165), Vector2(670, 492))
	for item in TOOLS:
		var t: Array = TOOLS[item]
		hotspot(item, t[1], layer_rect(t[0]), Vector2(t[2], 492))
	hotspot("lobby_door", "Tür zur Lobby", Rect2(92, 92, 118, 420), Vector2(165, 535), "left")
	hotspot("altar_door", "Tür zum Altarraum", Rect2(1172, 92, 112, 428), Vector2(1205, 548), "right")


func refresh() -> void:
	for item in TOOLS:
		layers[TOOLS[item][0]].visible = not Game.flag("took_" + item)


func is_active(hid: String) -> bool:
	if hid in TOOLS:
		return not Game.flag("took_" + hid)
	return true


func look(hid: String) -> void:
	match hid:
		"boxes", "boxes2":
			await say("Verpackungsmaterial und Restaurierungsabfälle.")
		"shelf":
			await say("Lösemittel, Pigmente, Schellack. Alles ordentlich beschriftet.")
		"pegboard":
			await say("Die Lochwand. Jedes Werkzeug hat seinen Platz.")
		"bench":
			await say("Meine Werkbank.")
		"ladder":
			await say("Die Malerleiter.")
		"saucer":
			await say("Eine Untertasse. Darauf mische ich Retuschierfarben.")
		"masking_tape":
			await say("Kreppband: „VORSICHT – FRISCH RESTAURIERT“. Davon habe ich reichlich.")
		"drill":
			await say("Der Akkuschrauber. Für Spezialschrauben habe ich keinen passenden Bit.")
		"lobby_door":
			await say("Die Tür zur Lobby.")
		"altar_door":
			await say("Die Tür zum Altarraum.")
		_:
			if hid in TOOLS:
				await say(ItemLogic.LOOK.get(hid, "Werkzeug."))
			else:
				await super(hid)


func use(hid: String) -> void:
	match hid:
		"lobby_door":
			await go("lobby", "lobby_door_open")
		"altar_door":
			await go("altar_room", "altar_door_open")
		"boxes", "boxes2", "shelf", "pegboard", "bench":
			await say("Was ich brauche, liegt offen herum.")
		_:
			if hid in TOOLS:
				await take(hid)
			else:
				await super(hid)
