extends Spatial

onready var _dialog := preload("res://assets/dialogs/debug_level.tres")


func _on_area_interacted(title: String, _type: int) -> void:
    # _type isn't used yet
    #var line = yield(_dialog.get_next_dialogue_line(title), "completed")
    DialogueManager.show_example_dialogue_balloon(title, _dialog)
