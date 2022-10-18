extends Node
class_name MainMenu

onready var _level_select := $gui/level_select as GridContainer

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    unlock_levels()


func unlock_levels() -> void:
    var i := -1
    var count := _level_select.get_child_count()
    for level in SaveData.save["levels"]:
        i += 1

        if i >= count:
            push_warning("Too many levels in save file")
            break

        (_level_select.get_child(i) as Button).disabled = !level.unlocked


func load_level(name: String) -> void:
    GameManager.load_level(name)


func _on_start_button_up() -> void:
    _level_select.visible = !_level_select.visible


func _on_exit_button_up() -> void:
    get_tree().quit(0)


func _on_level_select_button_up(level_name: String) -> void:
    GameManager.load_level(level_name)


func _on_sound_toggled(muted: bool) -> void:
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
