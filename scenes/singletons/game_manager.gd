extends Node

onready var _levels := {
    "main_menu" : load("res://scenes/levels/main_menu.tscn"),
    "level_debug" : load("res://scenes/levels/debug_level.tscn"),
    "intro": load("res://scenes/levels/intro.tscn"),
   }
var _game_started := false

signal object_interacted(title)


func _ready() -> void:
    OS.window_maximized = true


func start_game() -> void:
    load_level("level_debug")


func load_level(name: String) -> void:
    if !_levels.has(name):
        push_error("Unknown level name: %s" % name)
        return

    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    get_tree().change_scene_to(_levels[name])
    _game_started = true


func quit_to_menu() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().change_scene_to(_levels["main_menu"])
    _game_started = false


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        if _game_started:
            quit_to_menu()
        else:
            get_tree().quit(0)
