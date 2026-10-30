extends Node
## Hauptszene: Raum mit Martin, Kamera, Eingabe, Sprachausgabe und Zwischenschnitte.

const VIEW_H := 768.0
const ROOMS := {
	"apartment": preload("res://game/rooms/apartment.gd"),
	"lobby": preload("res://game/rooms/lobby.gd"),
	"workshop": preload("res://game/rooms/workshop.gd"),
	"altar_room": preload("res://game/rooms/altar_room.gd"),
	"depot": preload("res://game/rooms/depot.gd"),
}
const SPEAKER_COLORS := {
	"martin": Color("f4e8c8"),
	"ackermann": Color("ffb59a"),
	"cult1": Color("a9c8ff"),
	"cult2": Color("cdb6ff"),
	"elder": Color("a3e3c4"),
	"": Color("d8d8d8"),
}

var world := Node2D.new()
var camera := Camera2D.new()
var player := Player.new()
var voice := AudioStreamPlayer.new()
var sfx := AudioStreamPlayer.new()
var ui: GameUI
var items := ItemLogic.new()
var room: Room
## Verlassene Räume; erst nach der laufenden Aktion freigeben, deren Skript noch auf den Raumwechsel wartet.
var _old_rooms: Array = []
var busy := false
var in_game := false
var selected := ""


func _ready() -> void:
	Game.main = self
	add_child(world)
	world.add_child(camera)
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.make_current()
	add_child(voice)
	add_child(sfx)
	ui = GameUI.new(self)
	add_child(ui)
	if not Game.fast:
		title_menu()


func title_menu() -> void:
	in_game = false
	var entries := [["Neues Spiel", new_game]]
	if Game.has_save():
		entries.push_front(["Fortsetzen", continue_game])
	entries.append(["Beenden", get_tree().quit])
	ui.fade.color.a = 0.0
	ui.show_menu(entries, true)


func new_game() -> void:
	ui.hide_menu()
	Game.reset()
	await enter_game("apartment", "")


func continue_game() -> void:
	ui.hide_menu()
	var data := Game.load_save()
	await enter_game(data["room"], "", Vector2(data["x"], data["y"]))


func enter_game(room_id: String, from: String, pos = null) -> void:
	busy = true
	in_game = true
	select_item("")
	ui.fade.color.a = 1.0
	_load_room(room_id, from, pos)
	await ui.fade_in(0.8)
	await room.on_enter(from)
	room.refresh()
	Game.save_game()
	_free_old_rooms()
	busy = false


func _free_old_rooms() -> void:
	for r in _old_rooms:
		r.queue_free()
	_old_rooms.clear()


func pause_menu() -> void:
	ui.show_menu([
		["Weiterspielen", ui.hide_menu],
		["Hauptmenü", func(): Game.save_game(); title_menu()],
		["Beenden", func(): Game.save_game(); get_tree().quit()],
	])


# Räume

func change_room(room_id: String, from: String) -> void:
	ui.show_hint("")
	await ui.fade_out()
	_load_room(room_id, from)
	await ui.fade_in()
	var door: String = room.entries.get(from, ["", "", ""])[2]
	if door != "":
		await Game.wait(0.3)
		room.layers[door].visible = false
	await room.on_enter(from)
	room.refresh()
	Game.save_game()


func _load_room(room_id: String, from: String, pos = null) -> void:
	if room:
		room.remove_child(player)
		world.remove_child(room)
		_old_rooms.append(room)
	room = ROOMS[room_id].new()
	room.id = room_id
	world.add_child(room)
	room.setup()
	var s := VIEW_H / room.bg_size.y
	room.scale = Vector2(s, s)
	room.add_child(player)
	player.room = room
	var e: Array = room.entries.get(from, room.entries[""])
	player.position = pos if pos != null else e[0]
	player.face(e[1], true)
	player.update_scale()
	if e.size() > 2 and e[2] != "":
		room.layers[e[2]].visible = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(room.bg_size.x * s)
	camera.limit_bottom = int(VIEW_H + 96)
	Game.room_id = room_id
	_follow(true)


func _follow(instant := false) -> void:
	var w := get_viewport().get_visible_rect().size.x
	var target := clampf(player.global_position.x - w / 2, 0, maxf(0, camera.limit_right - w))
	camera.position.x = target if instant else lerpf(camera.position.x, target, 0.12)


func _process(_dt: float) -> void:
	if room == null or not in_game:
		return
	_follow()
	if busy or ui.menu_open():
		ui.set_hover("")
		return
	var text := ""
	if ui.hover_item != "":
		text = Game.item_name(ui.hover_item)
		if selected != "" and selected != ui.hover_item:
			text = "Benutze %s mit %s" % [Game.item_name(selected), text]
	elif get_viewport().get_mouse_position().y < VIEW_H:
		var hs = room.hotspot_at(room.get_local_mouse_position())
		if hs:
			text = room.display_name(hs)
			if selected != "":
				text = "Benutze %s mit %s" % [Game.item_name(selected), text]
		elif selected != "":
			text = "Benutze %s mit …" % Game.item_name(selected)
	ui.set_hover(text)


# Eingabe

func _unhandled_input(event: InputEvent) -> void:
	if not in_game:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if ui.menu_open():
			ui.hide_menu()
		elif not busy:
			pause_menu()
		return
	if busy or ui.menu_open() or not (event is InputEventMouseButton and event.pressed):
		return
	if get_viewport().get_mouse_position().y >= VIEW_H:
		return
	var p := room.get_local_mouse_position()
	var hs = room.hotspot_at(p)
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if selected != "":
			select_item("")
		elif hs:
			act(hs, "look")
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if hs:
			act(hs, "use")
		else:
			select_item("")
			player.walk_to(p)


func select_item(item: String) -> void:
	selected = item
	ui.set_cursor_item(item)


## Zum Hotspot laufen und ansehen, benutzen oder den gewählten Gegenstand darauf anwenden.
func act(hs: Dictionary, mode: String) -> void:
	var item := selected
	if mode == "use" and not await player.walk_to(hs["walk"]):
		return
	if mode == "use":
		player.face(hs["face"])
	busy = true
	ui.set_hover("")
	if mode == "look":
		await room.look(hs["id"])
	elif item != "":
		await room.use_item(hs["id"], item)
	else:
		await room.use(hs["id"])
	_after_action()


func on_item_clicked(item: String, button: int) -> void:
	if busy or not in_game:
		return
	if button == MOUSE_BUTTON_RIGHT:
		player.stop()
		busy = true
		await items.look(item)
		_after_action()
	elif selected == "":
		select_item(item)
	elif selected == item:
		select_item("")
	else:
		player.stop()
		busy = true
		var other := selected
		select_item("")
		await items.combine(other, item)
		_after_action()


func _after_action() -> void:
	_free_old_rooms()
	select_item("")
	if is_instance_valid(room):
		room.refresh()
	busy = false


# Sprache

func say(speaker: String, text: String, voice_id := "") -> void:
	if Game.fast:
		print("%s: %s" % [speaker if speaker != "" else "*", text])
		await get_tree().process_frame
		return
	var seconds := clampf(text.length() * 0.065, 1.6, 9.0)
	if voice_id != "":
		var path := "res://assets/voices/%s.wav" % voice_id
		if ResourceLoader.exists(path):
			voice.stream = load(path)
			voice.play()
			seconds = voice.stream.get_length() + 0.35
	var anchor = room.speaker_anchor(speaker)
	if speaker == "martin":
		anchor = player.head_screen_pos()
	room.set_talking(speaker, true)
	if speaker == "martin":
		player.talking = true
	ui.show_line(text, SPEAKER_COLORS.get(speaker, Color.WHITE), anchor)
	await ui.wait_or_skip(seconds)
	voice.stop()
	ui.hide_line()
	player.talking = false
	if is_instance_valid(room):
		room.set_talking(speaker, false)


## Schrilles Piepen des Rauchmelders, im Code erzeugt.
func beep(seconds := 2.0) -> void:
	if Game.fast:
		return
	var rate := 22050
	var data := PackedByteArray()
	data.resize(int(rate * seconds) * 2)
	for i in int(rate * seconds):
		var t := float(i) / rate
		var on := fmod(t, 0.5) < 0.3
		var v := 0.0
		if on:
			v = 0.35 if fmod(t * 3150.0, 1.0) < 0.5 else -0.35
		data.encode_s16(i * 2, int(v * 32767))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.data = data
	sfx.stream = s
	sfx.play()


# Zwischenschnitte

func night_cut() -> void:
	await ui.fade_out(1.0)
	await ui.big_text("Feierabend.", 1.8)
	await ui.big_text("Nacht im Museum.\n3:00 Uhr", 2.5)
	await ui.big_text("Am nächsten Morgen", 2.0)
	await ui.fade_in(1.0)


func ending() -> void:
	Game.set_flag("ending")
	await ui.fade_out(2.0)
	await ui.big_text("Ende von Teil 1", 3.0)
	await ui.big_text("Kyphi – Der Zugang\n\nFortsetzung folgt.", 3.0)
	if not Game.fast:
		Game.delete_save()
		room.remove_child(player)
		world.remove_child(room)
		_old_rooms.append(room)
		room = null
		title_menu()
