extends BaseLevel


func _ready() -> void:
    level_name = "Night 1"
    _id = 1
    _dialog = preload("res://assets/dialogs/night1.tres")
    _action_table = {}

    _load_save(1)
