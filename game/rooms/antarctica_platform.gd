extends Room
## Antarktis: Bahnsteig unter dem Eis (Teil 2). Links die Schleuse zum Zug, in der Mitte die Türen zu Kontrollraum
## und Schleuse, rechts die Treppe zur Außenbeobachtung. Die Räume dahinter sind noch nicht gebaut.

const NOT_BUILT := "[Dieser Raum ist noch nicht gebaut.]"


func _init() -> void:
	asset_dir = "antarctica_platform"


func build() -> void:
	tint = Color(0.78, 0.85, 0.95)
	hotspot("train_airlock", "Schleuse zum Zug")
	hotspot("control_door", "Tür zum Kontrollraum")
	hotspot("airlock_door", "Tür zur Schleuse")
	hotspot("stairs", "Treppe nach oben", "right", "none")
	set_verbs({"train_airlock": "go", "control_door": "go", "airlock_door": "go", "stairs": "go"})


func on_enter(from: String) -> void:
	if from == "train_cabin" and not Game.flag("antarctica_seen"):
		Game.set_flag("antarctica_seen")
		await say("Kalt. Richtig kalt.")
		await say("Das muss die Antarktis sein. Hoffentlich gibt es hier Kaffee.")


func look(hid: String) -> void:
	match hid:
		"train_airlock":
			await say("Hinter dem Schott wartet der Zug.")
		"control_door":
			await say("Eine Stahltür. Dahinter brummt ein Lüfter.")
		"airlock_door":
			await say("Eine Stahltür mit Warnschild. Durchs Fenster sieht man Spinde.")
		"stairs":
			await say("Eine Treppe nach oben. Von dort fällt kaltes Licht herein.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"train_airlock":
			await go("train_cabin")
		"control_door", "airlock_door", "stairs":
			await narrate(NOT_BUILT)
		_:
			await super(hid)
