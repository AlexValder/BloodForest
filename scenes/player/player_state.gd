extends Resource
class_name Health

signal health_empty
signal health_changed(old, new)

export(int, 1, 9999) var max_value: int
var current_value := 0

func reset() -> void:
    current_value = max_value


func take_damage(amount: int) -> int:
    var initial = current_value
    current_value = max(0, current_value - amount) as int
    if current_value == 0:
        emit_signal("health_empty")
    else:
        emit_signal("health_changed", initial, current_value)
    return current_value


func heal(amount: int) -> int:
    var initial = current_value
    current_value = min(max_value, current_value + amount) as int
    emit_signal("health_changed", initial, current_value)
    return current_value
