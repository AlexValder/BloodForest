extends Control
class_name LoadingScreen

export(float, 0.0, 120.0) var SIMULATED_DELAY_SEC := 0.1

var _thread: Thread = null
var _progress: ProgressBar = null
var _done_label: Label = null
var _tip: RichTextLabel = null
var _done := false
var _tips: Array = []
var _res: Resource = null


func _enter_tree() -> void:
    visible = false


func _ready() -> void:
    _tips = Database.get_loading()


func _unhandled_input(_event: InputEvent) -> void:
    _on_continue_pressed()


func _gui_input(event: InputEvent) -> void:
    # No input processing for you
    if !(event is InputEventMouseButton):
        return

    _on_continue_pressed()


func _on_continue_pressed() -> void:
    if !visible: return

    get_tree().set_input_as_handled()
    if _done:
        _exit_screen()


func _exit_screen() -> void:
    _done = false
    visible = false
    var error := get_tree().change_scene_to(_res)
    assert(error == OK, "Failed to enter loaded scene")
    _res = null
    GameManager.loading = false


func _thread_load(path: String) -> void:
    var ril := ResourceLoader.load_interactive(path)
    assert(ril, "Can't interactively load a resource")

    var total := ril.get_stage_count()
    _progress.call_deferred("set_max", total)

    var res: PackedScene = null

    while true:
        _progress.call_deferred("set_value", ril.get_stage())
        OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))
        var err = ril.poll()
        if err == ERR_FILE_EOF:
            res = ril.get_resource()
            break
        elif err != OK:
            print("There was an error loading")
            break

    assert(res, "Resource did not load")
    _res = res
    call_deferred("_thread_done")


func _thread_done() -> void:
    _progress.value = 100
    _thread.wait_to_finish()
    _done_label.modulate.a = 1
    _done = true
    if _done_label.self_modulate.a < 1:
        _exit_screen()


func load_scene(path: String, show_tip: bool = true) -> void:
    GameManager.loading = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    if _progress == null:
        _progress = $"%progress" as ProgressBar

    if _tip == null:
        _tip = $"%tip" as RichTextLabel

    if show_tip && _tips.size() > 0:
        var entry: Dictionary = _tips[randi() % _tips.size()]
        _tip.bbcode_text = "[center][color={0}]{1}[/color] {2}[/center]".format(
            [entry.color, entry.prefix, entry.text])
    else:
        _tip.bbcode_text = ""

    if _done_label == null:
        _done_label = $"%continue" as Label
    _done_label.self_modulate.a = 1 if show_tip else 0
    _done_label.modulate.a = 0

    _thread = Thread.new()
    var error := _thread.start(self, "_thread_load", path)
    assert(error == OK, "Failed to start a thread")
    raise() # Show on top

    visible = true


func _on_root_visibility_changed() -> void:
    set_process(visible)
    set_process_input(visible)
    set_process_unhandled_input(visible)
    set_process_unhandled_key_input(visible)
