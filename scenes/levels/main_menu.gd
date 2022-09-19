extends Node

onready var _eyes := $"%easter_eyes" as MeshInstance


func _ready() -> void:
    if OS.is_debug_build():
        _eyes.visible = true
    else:
        _eyes.visible = randi() % 10 == 0


func _on_start_button_up() -> void:
    GameManager.start_game()


func _on_exit_button_up() -> void:
    get_tree().quit(0)


func _on_eyes_timer_timeout() -> void:
    _eyes.visible = false
