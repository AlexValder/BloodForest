extends CanvasLayer
class_name DescBalloon

const DialogueLine = preload("res://addons/dialogue_manager/dialogue_line.gd")

export(bool) var enable_timer := true
export(float, 0.5, 10.0) var timeout := 1.0

onready var _bg := $bg as ColorRect
onready var _label := $bg/vbox/text
onready var _timer := $timer as Timer

var dialog: DialogueLine
var is_waiting_for_input: bool = false

signal actioned(next_id)


func _ready() -> void:
    if not dialog:
        queue_free()
        return

    _bg.hide()

    _label.dialogue = dialog
    yield(_label.reset_height(), "completed")

    # Show our box
    _bg.visible = true

    _label.type_out()
    yield(_label, "finished")

    # Wait for input
    is_waiting_for_input = true
    if enable_timer:
        _timer.start(timeout)


func _unhandled_input(event: InputEvent) -> void:
    if not is_waiting_for_input: return

    if event.is_action_pressed("interact"):
        get_tree().set_input_as_handled()
        next(dialog.next_id)


func next(next_id: String) -> void:
    emit_signal("actioned", next_id)
    queue_free()


func _on_timer_timeout() -> void:
    emit_signal("actioned", "")
    queue_free()
