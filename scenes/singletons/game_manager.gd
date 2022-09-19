extends Node

onready var _level_debug := preload("res://scenes/levels/debug_level.tscn")
onready var _main_menu := preload("res://scenes/levels/main_menu.tscn")
var _game_started := false


func start_game() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    get_tree().change_scene_to(_level_debug)
    _game_started = true


func quit_to_menu() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().change_scene_to(_main_menu)
    _game_started = false


func _ready() -> void:
    OS.window_maximized = true


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        if _game_started:
            quit_to_menu()
        else:
            get_tree().quit(0)
