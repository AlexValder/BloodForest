extends Control
class_name LoadingScreen

export(float, 0.0, 120.0) var SIMULATED_DELAY_SEC := 0.1
export var tip_prefix := "[color=yellow]TIP![/color] "
export var tips := PoolStringArray()

var thread: Thread = null
var progress: ProgressBar = null
var tip: RichTextLabel = null


func _enter_tree() -> void:
    visible = false


func _thread_load(path: String) -> void:
    var ril := ResourceLoader.load_interactive(path)
    assert(ril)

    var total := ril.get_stage_count()
    progress.call_deferred("set_max", total)

    var res: PackedScene = null

    while true:
        progress.call_deferred("set_value", ril.get_stage())
        OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))
        var err = ril.poll()
        if err == ERR_FILE_EOF:
            res = ril.get_resource()
            break
        elif err != OK:
            print("There was an error loading")
            break

    call_deferred("_thread_done", res)


func _thread_done(resource: PackedScene) -> void:
    assert(resource)

    thread.wait_to_finish()
    hide()
    get_tree().change_scene_to(resource)

    visible = false


func load_scene(path: String) -> void:
    if progress == null:
        progress = $"%progress" as ProgressBar

    if tip == null:
        tip = $"%tip" as RichTextLabel

    if tips.size() > 0:
        tip.bbcode_text = "[center]%s[/center]" %\
            (tip_prefix + tips[randi() % tips.size()])

    thread = Thread.new()
    thread.start( self, "_thread_load", path)
    raise() # Show on top.\

    visible = true
