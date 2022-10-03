extends CanvasLayer


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        get_tree().set_input_as_handled()
        _on_resume_button_up()


func _on_resume_button_up() -> void:
    GameManager.set_pause(false)


func _on_restart_button_up() -> void:
    get_tree().reload_current_scene()
    GameManager.set_pause(false)


func _on_quit_button_up() -> void:
    GameManager.set_pause(false)
    GameManager.quit_to_menu()
