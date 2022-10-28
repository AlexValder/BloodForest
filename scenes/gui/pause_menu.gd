extends CanvasLayer
class_name PauseMenu


func _enter_tree() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _exit_tree() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        get_tree().set_input_as_handled()
        _on_resume_button_up()


func _on_resume_button_up() -> void:
    GameManager.set_pause(false)


func _on_restart_button_up() -> void:
    GameManager.restart_level()
    GameManager.set_pause(false)


func _on_quit_button_up() -> void:
    GameManager.set_pause(false)
    GameManager.quit_to_menu()


