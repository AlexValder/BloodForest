extends Node

const PREFIX := "res://scenes/levels/"

onready var _pause_menu :=\
    preload("res://scenes/gui/pause_menu.tscn").instance() as Node

var _levels := [
    "main_menu",
    "debug_level",
    "intro",
   ]
var _game_started := false


func _ready() -> void:
    OS.window_maximized = true


func start_game() -> void:
    load_level("debug_level")


func set_pause(paused: bool) -> void:
    if get_tree().paused == paused:
        return

    get_tree().paused = paused
    var root := get_tree().root
    if paused:
        root.add_child(_pause_menu)
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        root.remove_child(_pause_menu)
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func load_level(name: String) -> void:
    if !_levels.has(name):
        push_error("Unknown level name: %s" % name)
        return

    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _change_current_scene(name)
    _game_started = true


func quit_to_menu() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _change_current_scene("main_menu")
    _game_started = false


func _change_current_scene(name: String) -> void:
    var curr_scene := get_tree().current_scene
    var error := get_tree().change_scene_to(_get_level(name))
    assert(error == OK)
    curr_scene.queue_free()


func _get_level(name: String) -> PackedScene:
    var path := PREFIX + name + ".tscn"
    return load(path) as PackedScene


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        if _game_started:
            set_pause(true)
        else:
            get_tree().quit(0)
