extends Node

enum WindowMode {
    Windowed,
    Borderless,
    Fullscreen,
}

const SETTINGS_FILE := "settings.ini"
const DEFAULTS := {
    "settings" : {
        "resolution" : Vector2(522, 288),
        "vsync": false,
        "vsync_comp": false,
        "window_mode": WindowMode.Fullscreen,
       },
   }
var _settings := {}
var _config := ConfigFile.new()



func _ready() -> void:
    _load_or_save_settings_file(_config, SETTINGS_FILE)


func _load_or_save_settings_file(config: ConfigFile, path: String) -> void:
    if config.load(path) != OK:
        _load_defaults(config, path)

    _settings.clear()
    for section in DEFAULTS:
        _settings[section] = {}
        for key in DEFAULTS[section]:
            _settings[section][key] = config.get_value(
                section, key, DEFAULTS[section][key])

    _apply_settings(_settings)


func _load_defaults(config: ConfigFile, path: String) -> void:
    config.clear()
    _settings.clear()
    for section in DEFAULTS:
        for key in DEFAULTS[section]:
            config.set_value(section, key, DEFAULTS[section][key])
    var err := config.save(path)
    assert(err == OK)


func _apply_settings(dict: Dictionary) -> void:
    var viewport := get_tree().root.get_viewport()
    var res = dict["settings"]["resolution"]
    if res is Vector2 and res.length() > 0:
        viewport.size = res

    var vsync = dict["settings"]["vsync"]
    if vsync is bool:
        OS.vsync_enabled = vsync

    var vsync_comp = dict["settings"]["vsync_comp"]
    if vsync_comp is bool:
        OS.vsync_via_compositor = vsync_comp

    OS.window_resizable = false
    var win_mode = dict["settings"]["window_mode"]
    match win_mode:
        WindowMode.Windowed:
            OS.window_borderless = false
            OS.window_fullscreen = false
            OS.window_maximized = true
            OS.window_size = res
        WindowMode.Borderless:
            OS.window_fullscreen = false
            OS.window_borderless = true
        WindowMode.Fullscreen:
            OS.window_fullscreen = true
        _:
            print("Unknown value: %d", win_mode)
            OS.window_fullscreen = true
