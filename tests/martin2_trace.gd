extends Node
## Protokolliert Position, Bild und Versatz des neuen Martin je Bild beim Laufen und Anhalten.
var p: Martin2
var log := []

func _ready() -> void:
	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main.ui.hide_menu()
	main._load_room("lobby", "")
	var old: Node2D = main.player
	p = Martin2.new()
	p.room = main.room
	p.position = old.position
	main.room.remove_child(old)
	old.queue_free()
	main.player = p
	main.room.add_child(p)
	p.face("right", true)
	p.update_scale()
	var h: float = main.room.height_at(p.position.y)
	p.walk_to(p.position + Vector2(1.0, 0) * h)
	for i in 600:
		await get_tree().process_frame
		var s: Sprite2D = p._sprite
		var tex := s.texture.resource_path.get_file()
		var foot := p.position + (s.offset + Vector2(140.3, 354)) * p.scale.x
		var line := "%3d pos %.1f,%.1f  bild %s  flip %s  offset %s moving %s busy %s" % [i, p.position.x, p.position.y, tex, s.flip_h, s.offset, p._moving, p._busy]
		if log.is_empty() or log[-1].substr(4) != line.substr(4):
			log.append(line)
	for l in log: print(l)
	get_tree().quit()
