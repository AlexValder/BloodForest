extends Node

const SAVES_DIR := "user://saves/"
const SAVES_FILE := "%ssave01.dat" % SAVES_DIR
onready var save := {
    "version": "0.0.3", # increase with each structure change
    "levels": [
        {
        "unlocked": true,
        "lie": "", # fake profession
        "driver_killed": false, # whether we killed or not
        },
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
    "player_state": {
        "inv": [
            [], # intro
            [], # night 1
            [], # night 2
            [], # night 3
            [], # night 4
            [0], # debug
       ],
    },
}


func _ready() -> void:
    _load_state()


func _exit_tree() -> void:
    save_state()


func set_level_data(index: int, field: String, value) -> void:
    print("Set at level %d field \"%s\" = %s", index, field, str(value))
    assert(save.levels[index].has(field),
        "Unknown field %s in level %d" % [field, index])
    assert(index >= 0 && index < save.levels.size(),
        "Index is out of bounds: %d" % index)
    save.levels[index].field = value


func _load_state() -> void:
    # TODO: verify that state is correct
    var file := File.new()
    var error := file.open(SAVES_FILE, File.READ)
    if error != OK:
        push_warning("Failed to load state: %d" % error)
        save_state()
        return

    var res := JSON.parse(file.get_as_text())
    if res.error != OK or typeof(res.result) != TYPE_DICTIONARY:
        push_warning("Failed to parse save file. Reason: %s at %d"
            % [res.error_string, res.error_line])
        save_state()
        return

    var dict := res.result as Dictionary
    if !dict.has("version") or dict["version"] != save["version"]:
        print("Unknown save file format. Rewriting...")
        save_state()
        return

    save = dict


func save_state() -> void:
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
