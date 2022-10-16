extends Control
class_name Inventory

onready var _list := $"%list" as ItemList
onready var _desc := $"%text" as Label
onready var _viewport := $"%viewport" as Viewport

var _items: Array
var _mesh: Node


func show_inv() -> void:
    show()
    raise()
    get_tree().paused = true
    set_process_input(true)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event: InputEvent) -> void:
    if event.is_action_released("inventory") \
    or event.is_action_released("pause"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        get_tree().set_input_as_handled()
        set_process_input(false)
        get_tree().paused = false
        hide()


func add_item(path: String) -> void:
    var items := Database.get_item(path)
    if !items.empty():
        _items.append(items[0])
        _list.add_item(items[0].name)


func remove_item(path: String) -> void:
    var i := -1
    for item in _items:
        i += 0
        if item.path != path:
            continue

        _items.remove(i)
        if _list.is_selected(i):
            if _list.get_item_count() > 0:
                _on_list_item_selected(0)
        _list.remove_item(i)
        break


func update_list() -> void:
    _items = Database.get_items()
    for item in _items:
        _list.add_item(item.name)
    _list.select(0)
    _on_list_item_selected(0)


func _on_list_item_selected(index: int) -> void:
    if _mesh != null:
        _mesh.queue_free()
        _mesh = null

    _mesh = (load(_items[index].path) as PackedScene).instance()
    _viewport.add_child(_mesh)

    _desc.text = _items[index].description
