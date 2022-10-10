extends Spatial

onready var _dialog := preload("res://assets/dialogs/debug_level.tres")
onready var _balloon := preload("res://scenes/gui/desc_balloon.tscn")
onready var _player := $player as Player
var _in_dialog := false


func _on_area_interacted(title: String, type: int) -> void:
    if _in_dialog:
        return
    _in_dialog = true

    match (type):
        1: # TEXT
            _show_description(title)
        2: # ACTION
            # there needs to be some way to call a specific function that
            # corresponds to the "title" and isn't just a runtime dictionary
            # with function refs <-- TODO
            _in_dialog = false
        _:
            _in_dialog = false
            push_warning("Unknown type: %d" % type)


func _show_description(title: String) -> void:
    var line = yield(_dialog.get_next_dialogue_line(title), "completed")
    if line == null:
        _in_dialog = false
        return

    var balloon = _balloon.instance() as DescBalloon
    balloon.dialog = line
    get_tree().current_scene.add_child(balloon)
    _show_description(yield(balloon, "actioned") as String)

