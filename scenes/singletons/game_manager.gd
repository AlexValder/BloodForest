extends Node

const PREFIX := "res://scenes/levels/"

onready var _pause_menu :=\
    preload("res://scenes/gui/pause_menu.tscn").instance() as PauseMenu
onready var _load_screen :=\
    preload("res://scenes/gui/loading.tscn").instance() as LoadingScreen

var _levels := [
    "main_menu",
    "debug_level",
    "intro",
   ]
var _game_started := false
var loading := false


func _ready() -> void:
    OS.window_maximized = true

    add_child(_load_screen)


func start_game() -> void:
    load_level("debug_level")


func set_pause(paused: bool) -> void:
    if get_tree().paused == paused:
        return

    get_tree().paused = paused
    var root := get_tree().root
    if paused:
        root.add_child(_pause_menu)
    else:
        root.remove_child(_pause_menu)


func load_level(name: String) -> void:
    if !_levels.has(name):
        push_error("Unknown level name: %s" % name)
        return

    _change_current_scene(name)
    _game_started = true


func quit_to_menu() -> void:
    _change_current_scene("main_menu", true)
    _game_started = false


func _change_current_scene(name: String, quick: bool = false) -> void:
    var curr_scene := get_tree().current_scene
    _load_screen.load_scene(_get_level_name(name), !quick)
    curr_scene.queue_free()


func _get_level_name(name: String) -> String:
    return PREFIX + name + ".tscn"


func _get_level(name: String) -> PackedScene:
    var path := _get_level_name(name)
    return load(path) as PackedScene


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        get_tree().set_input_as_handled()
        if _game_started && !loading:
            set_pause(true)
