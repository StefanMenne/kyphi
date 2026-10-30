extends Room
## Werkstatt: die meisten Werkzeuge liegen hier.

## Gegenstand -> [Ebene, Name, Laufpunkt-x]
const TOOLS := {
	"ladder": ["ladder", "Malerleiter"],
	"brush": ["brush", "Pinsel"],
	"spatula": ["spatula", "Spatel"],
	"drill": ["drill", "Akkuschrauber"],
	"uv_lamp": ["uv_lamp", "UV-Lampe"],
	"tweezers": ["tweezers", "Pinzette"],
	"evidence_bag": ["evidence_bags", "Fundtütchen"],
	"caliper": ["caliper", "Messschieber"],
	"saucer": ["saucer", "Untertasse"],
	"masking_tape": ["masking_tape", "Kreppband"],
}


func _init() -> void:
	asset_dir = "werkstatt"


func build() -> void:
	tint = Color(1.0, 0.97, 0.92)
	hotspot("boxes", "Kisten", "left")
	hotspot("boxes2", "Kisten")
	hotspot("shelf", "Regal")
	hotspot("pegboard", "Lochwand")
	hotspot("bench", "Werkbank")
	for item in TOOLS:
		var t: Array = TOOLS[item]
		hotspot(item, t[1])
		set_verbs({item: "take"})
	hotspot("lobby_door", "Tür zur Lobby", "left")
	hotspot("altar_door", "Tür zum Altarraum", "right")
	set_verbs({"lobby_door": "go", "altar_door": "go"})


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
