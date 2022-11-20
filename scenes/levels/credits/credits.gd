extends Node
class_name Credits

const CREDITS_PATH := "res://assets/text/credits.json"

onready var _vbox := $container as Control
onready var _line := $container/line as CreditLine

export var game_title_multiplier := 10.0
export var section_time := 2.0
export var line_time := 0.3
export var base_speed := 100
export var speed_up_multiplier := 10.0
export var title_color := Color.blueviolet

var _speed_up := false

var _game_title_shown := false
var _started := false
var _finished := false

var _section
var _section_next := true
var _section_timer := 0.0
var _line_timer := 0.0
var _curr_line := 0
var _lines := []
var _credits := []


func _ready() -> void:
    _prepare_credits()

    var tween := $tween as Tween
    var error := tween.interpolate_property(
        $press_esc, "self_modulate:a",
        null, 1.0,
        0.5,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.0)
    assert(error, "Failed to interpolate a property")
    tween.start()


func _load_credits() -> Array:
    var file := File.new()
    var error := file.open(CREDITS_PATH, File.READ)
    if error != OK:
        push_error("Failed to load credits: %d" % error)

    var res := JSON.parse(file.get_as_text())
    if res.error != OK:
        push_error("Failed to parse credits file. Reason: %s at %d"
            % [res.error_string, res.error_line])

    var credits := res.result as Array

    var i := 0
    while (i < credits.size()):
        var j := 0
        while (j < credits[i].size()):
            credits[i][j] = credits[i][j].replace(" by ", " [i]by[/i] ")
            j += 1
        i += 1

    var last = credits.back()
    credits.append(["Lots of text incoming!"])
    last.append_array(Engine.get_license_text().split("\n"))

    var license := Engine.get_license_info()
    for key in license.keys():
        last.append(key)
        last.append_array(license[key].split("\n"))
        last.append("")

    var copyright := Engine.get_copyright_info()
    for line in copyright:
        last.append(line["name"])
        for part in line["parts"]:
            for key in part.keys():
                last.append(key)
                if typeof(part[key]) == TYPE_ARRAY:
                    last.append_array(part[key])
                else:
                    last.append(part[key])
            last.append("")
        last.append("")
    return credits


func _prepare_credits() -> void:
    _credits = _load_credits()
    var i := 0
    while (i < _credits.size()):
        var j := 0
        while (j < _credits[i].size()):
            var value = _credits[i][j]
            _credits[i][j] = "[center]{0}[/center]".format([value])
            j += 1
        i += 1


func _process(delta: float) -> void:
    var scroll_speed = base_speed * delta

    if _section_next:
        _section_timer += delta * speed_up_multiplier if _speed_up else delta
        if _section_timer >= section_time:
            _section_timer -= section_time

            if _credits.size() > 0:
                _started = true
                _curr_line = 0
                _section = _credits.pop_front()
                add_line()

    else:
        _line_timer += delta * speed_up_multiplier if _speed_up else delta
        if _line_timer >= line_time:
            _line_timer -= line_time
            add_line()

    if _speed_up:
        scroll_speed *= speed_up_multiplier

    if _lines.size() > 0:
        for l in _lines:
            if not _game_title_shown:
                _game_title_shown = true
                l.rect_position.y -= scroll_speed * game_title_multiplier
            else:
                l.rect_position.y -= scroll_speed

            if l.rect_position.y < -l.get_content_height():
                _lines.erase(l)
                l.queue_free()
    elif _started:
        finish()


func finish() -> void:
    if not _finished:
        _finished = true
        GameManager.quit_to_menu()


func add_line() -> void:
    var new_line := _line.duplicate() as CreditLine
    new_line.bbcode_text = _section.pop_front()
    _lines.append(new_line)

    if not _game_title_shown:
        _set_game_title(new_line)
    elif _curr_line == 0:
        new_line.add_color_override("default_color", title_color)

    _vbox.add_child(new_line)

    if _section.size() > 0:
        _curr_line += 1
        _section_next = false
    else:
        _section_next = true


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        finish()
    if event.is_action_pressed("ui_down") and !event.is_echo():
        _speed_up = true
    if event.is_action_released("ui_down") and !event.is_echo():
        _speed_up = false


func _set_game_title(line: CreditLine) -> void:
    line.add_font_override(
            "normal_font",
            preload("res://assets/gui/fonts/PixelNewspaperIII.tres"))
    line.material = ShaderMaterial.new()
    line.material.shader =\
        preload("res://assets/materials/gui_shaders/blinking.gdshader")
    line.material.set("shader_param/color1", Color("ff0000"))
    line.material.set("shader_param/color2", Color("900000"))
    line.material.set("shader_param/speed", 7.5)
