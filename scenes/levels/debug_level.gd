extends Spatial

onready var _dialog := preload("res://assets/dialogs/debug_level.tres")
#onready var _balloon := preload("res://scenes/gui/desc_balloon/desc_balloon.tscn")
onready var _player := $player as Player
var _in_dialog := false


func _on_area_interacted(title: String, type: int) -> void:
    if type == 1:
        _show_dialog(title)


func _show_dialog(title: String) -> void:
    var line = yield(_dialog.get_next_dialogue_line(title), "completed")
    if line == null:
        return

    print("DESK: %s" % line.dialogue)
#   var balloon = Balloon.instance()
#   balloon.dialogue = dialogue
#   get_tree().current_scene.add_child(balloon)
#   _show_dialogue(yield(balloon, "actioned") as String)

