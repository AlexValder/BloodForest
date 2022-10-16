extends Node

const SAVES_DIR := "user://saves/"
const SAVES_FILE := "%ssave01.dat" % SAVES_DIR
onready var save := {
    "intro" : {
        "lie": "", # fake profession
        "driver_killed": false, # whether we killed or not
    },
    "levels": [
        {
        "unlocked": false,
        },
        {
        "unlocked": false,
        },
        {
        "unlocked": false,
        },
        {
        "unlocked": false,
        }
    ],
    "extra": {},
}


func _ready() -> void:
    _load_state()


func _exit_tree() -> void:
    _save_state()


func _load_state() -> void:
    # TODO: verify that state is correct
    var file := File.new()
    var error := file.open(SAVES_FILE, File.READ)
    if error != OK:
        push_error("Failed to load state: %d" % error)
        _save_state()

    var res := JSON.parse(file.get_as_text())
    if res.error != OK:
        push_error("Failed to parse save file. Reason: %s at %d"
            % [res.error_string, res.error_line])
        # todo: clear defaults
        _save_state()
        return

    assert(typeof(res.result) == TYPE_DICTIONARY,
        "Save file did not contain a dicitonary")
    save = res.result


func _save_state() -> void:
    var file := File.new()
    var dir := Directory.new()
    if !dir.dir_exists(SAVES_DIR):
        var err := dir.make_dir_recursive(SAVES_DIR)
        assert(err == OK, "Failed to create saves directory")

    var error := file.open(SAVES_FILE, File.WRITE_READ)
    if error != OK:
        push_error("Error occured: %d" % error)

    var json_str := JSON.print(save)
    file.store_string(json_str)
    file.flush()
