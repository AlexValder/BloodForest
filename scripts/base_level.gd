extends Spatial
class_name BaseLevel

onready var _balloon := preload("res://scenes/gui/desc_balloon.tscn")
onready var _player := $player as Player
var _in_dialog := false

var level_name: String
var _dialog: DialogueResource
var _action_table: Dictionary


func _on_area_interacted(obj: InterArea, title: String, type: int) -> void:
    if _in_dialog:
        return
    _in_dialog = true

    match (type):
        1: # TEXT
            _show_description(title)
        2: # ACTION
            # TODO
            # there needs to be some way to call a specific function that
            # corresponds to the "title" and isn't just a runtime dictionary
            # with function refs
            if _action_table.has(title):
                var action := _action_table[title] as FuncRef
                action.call_func(obj, title)
            else:
                push_error("Unknown action in %s: %s"% [level_name, title])
                _in_dialog = false
        3: # PICKUP
            print("Picked up %s" % title)
            _player.pick_up(obj.model.filename)
            obj.queue_free()
            _in_dialog = false
        _:
            _in_dialog = false
            if type != 0: # explicit NONE
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


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _exit_tree() -> void:
    SaveData.save_state()
