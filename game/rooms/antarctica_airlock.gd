extends Room
## Antarktis: Schleuse (Teil 2). Im Spind hängt der XXL-Kälteanzug (er bleibt immer hier: Martin zieht ihn
## nur draußen an). Die Anzugheizung braucht einen geladenen Akku (der aus dem Akkuschrauber ist leer).
## Das Außentor ist festgefroren; Salz hilft bei -68 °C nicht, nur die Torheizung, und der fehlt Sicherung F7.
## Im Wartungsschrank steht der Glykol-Kanister (gebraucht erst in Prüfung 3).


func _init() -> void:
	asset_dir = "antarctica_airlock"


func build() -> void:
	tint = Color(0.82, 0.87, 0.93)
	hotspot("platform_door", "Tür zum Bahnsteig", "none")
	hotspot("gate", "Außentor")
	hotspot("cabinet", "Wartungsschrank")
	hotspot("glycol", "Kanister")
	hotspot("raincoat", "Spind mit Regenjacke")
	hotspot("suit", "Kälteanzug im Spind")
	hotspot("locker", "Großer Schrank")
	set_verbs({"platform_door": "go", "gate": "go"})


func refresh() -> void:
	layers["gate_open"].visible = false
	layers["glycol_canister"].visible = not Game.flag("took_glycol_canister")
	layers["suit_taped"].visible = Game.flag("suit_taped")


func is_active(hid: String) -> bool:
	if hid == "glycol":
		return not Game.flag("took_glycol_canister")
	return true


func on_enter(_from: String) -> void:
	if not Game.flag("airlock_seen"):
		Game.set_flag("airlock_seen")
		await say("Die Schleuse nach draußen. Hier ist es schon so kalt, dass mir die Nase zufriert.")


func look(hid: String) -> void:
	match hid:
		"platform_door":
			await say("Die Tür zurück zum Bahnsteig.")
		"gate":
			if Game.flag("gate_thawed"):
				await say("Das Außentor. Die Torheizung hat das Eis gelöst.")
			else:
				await say("Das Außentor, dick mit Eis überzogen. Das Handrad ist festgefroren.")
		"cabinet":
			await say("Ein Wartungsschrank: Haken, Seile, Werkzeug.")
		"glycol":
			await say("Ein Kanister: „Frostschutz (Glykol) – Pistenraupe“.")
		"raincoat":
			await say("Eine Regenjacke. In der Antarktis. Jemand hat Humor.")
		"suit":
			if Game.flag("suit_taped"):
				await say("Der Kälteanzug, mit Gewebeband abgebunden. Sieht furchtbar aus. Hält aber.")
			else:
				await say("Ein Kälteanzug. Größe XXL. Der einzige, der noch da ist. Mit Heizung und Klettergurt.")
		"locker":
			await say("Verschlossen. Laut Aufkleber: Ersatzteile Pistenraupe.")
		_:
			await super(hid)


func use(hid: String) -> void:
	match hid:
		"platform_door":
			await go("antarctica_platform")
		"gate":
			await gate()
		"glycol":
			await take("glycol_canister", "Den nehme ich mal mit. Frostschutz kann man immer brauchen.")
		"suit":
			if Game.flag("suit_heated"):
				await refuse("Den ziehe ich an, wenn ich rausgehe.")
			else:
				await refuse("Ohne Heizung ist der Anzug nur eine dicke Decke. Bei minus 68 reicht das nicht.")
		"raincoat":
			await refuse("Die nützt hier niemandem.")
		"cabinet":
			await refuse("Das Werkzeug lasse ich hier. Die Seile auch.")
		"locker":
			await refuse("Zu.")
		_:
			await super(hid)


func use_item(hid: String, item: String) -> void:
	match [hid, item]:
		["suit", "duct_tape"]:
			await Game.main.flush_gesture()
			if Game.flag("suit_taped"):
				await refuse("Noch mehr Band, und ich komme gar nicht mehr hinein.")
				return
			Game.set_flag("suit_taped")
			refresh()
			await say("Ärmel, Hüfte, Beine. Abgebunden wie ein Rollbraten.")
			await say("Jetzt flattert da nichts mehr.")
		["suit", "drill"], ["suit", "drill_bit"]:
			await Game.main.flush_gesture()
			if Game.flag("drill_battery_out"):
				await refuse("Den Akku habe ich schon herausgenommen.")
				return
			Game.set_flag("drill_battery_out")
			Game.add_item("drill_battery")
			await say("Die Anzugheizung hat ein Akkufach. Der Akku vom Akkuschrauber passt!")
			await say("… und ist leer. Den muss ich irgendwo laden.")
		["suit", "drill_battery"]:
			await refuse("Leer. Damit wird nichts warm.")
		["suit", "drill_battery_charged"]:
			await Game.main.flush_gesture()
			Game.remove_item("drill_battery_charged")
			Game.set_flag("suit_heated")
			await say("Klick. Die Heizung läuft. Jetzt kann ich raus.")
		["gate", "salt"]:
			await refuse("Salz taut Eis nur bis minus 21 Grad. Draußen sind es minus 68.")
		["gate", "glycol_canister"]:
			await refuse("Glykol bei minus 68? Das wird Gelee.")
		["gate", "thermos"]:
			await refuse("Für ein ganzes Tor reicht der Tee nicht.")
		_:
			await super(hid, item)


func gate() -> void:
	if not Game.flag("gate_fuse_in"):
		await refuse("Festgefroren. Das Tor hat eine Heizung, aber die ist aus.")
		return
	if not Game.flag("suit_heated"):
		await refuse("Das Eis ist weg. Aber ohne Heizung im Anzug halte ich da draußen keine fünf Minuten.")
		return
	await Game.main.flush_gesture()
	if not Game.flag("gate_thawed"):
		Game.set_flag("gate_thawed")
		await say("Die Torheizung hat das Eis gelöst. Anzug an …")
	await go("antarctica_antenna", "gate_open")
