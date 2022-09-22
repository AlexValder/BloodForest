extends Node

onready var _eyes := $"%easter_eyes" as MeshInstance
onready var _level_select := $level_select as GridContainer


func _ready() -> void:
    if OS.is_debug_build():
        _eyes.visible = true
    else:
        _eyes.visible = randi() % 10 == 0


func load_level(name: String) -> void:
    GameManager.load_level(name)


func _on_start_button_up() -> void:
#    GameManager.start_game()
    _level_select.visible = !_level_select.visible


func _on_exit_button_up() -> void:
    get_tree().quit(0)


func _on_eyes_timer_timeout() -> void:
    _eyes.visible = false


func _on_level_select_button_up(level_name: String) -> void:
    GameManager.load_level(level_name)
