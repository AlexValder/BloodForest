extends BaseLevel


func _ready() -> void:
    level_name = "Debug Level"
    _dialog = preload("res://assets/dialogs/debug_level.tres")
    _action_table = {}
