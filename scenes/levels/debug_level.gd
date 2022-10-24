extends BaseLevel

onready var _button := $reset_button/button as Spatial
onready var _timer := $reset_button/timer as Timer


func _ready() -> void:
    level_name = "Debug Level"
    _id = 5
    _dialog = preload("res://assets/dialogs/debug_level.tres")
    _action_table = {
        "red_button": funcref(self, "_red_button"),
       }

    _load_save(5)


func _red_button(_obj: InterArea, _title: String) -> void:
    _button.transform.origin.y = -0.05
    _timer.start()

    _player.clear_inventory()
    _restore_item(
        "res://scenes/items/hunting_rifle.tscn",
        $pedestal4/InterArea as InterArea)
    _restore_item(
        "res://scenes/items/water_bottle.tscn",
        $pedestal5/InterArea as InterArea)
    _restore_item(
        "res://scenes/items/lighter.tscn",
        $pedestal6/InterArea as InterArea)

    _in_dialog = false


func _restore_item(path: String, area: InterArea) -> void:
    if area.model != null:
        return

    var item := (load(path) as PackedScene).instance()
    area.model = item
    area.add_child(item)
    area.set_collision_layer_bit(1, true)


func _exit_tree() -> void:
    ._exit_tree() # no need to do anything extra here


func _on_red_button_timer_timeout() -> void:
    _button.transform.origin.y = 0
