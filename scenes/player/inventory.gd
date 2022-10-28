extends Control
class_name Inventory

onready var _list := $"%list" as ItemList
onready var _desc := $"%text" as Label
onready var _viewport := $"%viewport" as InventoryViewport

var _items: Array


func show_inv() -> void:
    show()
    raise()
    get_tree().paused = true
    set_process_input(true)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event: InputEvent) -> void:
    if event.is_action_released("inventory") \
    or event.is_action_released("pause"):
        get_tree().set_input_as_handled()
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        set_process_input(false)
        get_tree().paused = false
        hide()


func has_item_by_path(path: String) -> bool:
    return has_item("path", path)


func has_item_by_name(name: String) -> bool:
    return has_item("name", name)


func has_item(field: String, value: String) -> bool:
    if _items.empty(): return false

    for item in _items:
        if item[field] == value:
            return true

    return false


func add_item_by_id(id: int) -> void:
    var items := Database.get_item_by_id(id)
    if !items.empty():
        _desc.text = ""
        _items.append(items[0])
        _list.add_item(items[0].name)


func add_item_by_path(path: String) -> void:
    var items := Database.get_item_by_path(path)
    if !items.empty():
        _desc.text = ""
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

    if _items.empty():
        _desc.text = "I have nothing on me"


func clear_all() -> void:
    _desc.text = "I have nothing on me"
    _items.clear()
    _list.clear()
    _viewport.clear()


func get_all_items() -> void:
    _items = Database.get_items()
    for item in _items:
        _list.add_item(item.name)
    _list.select(0)
    _on_list_item_selected(0)


func get_item_save() -> PoolIntArray:
    var list := PoolIntArray()

    for item in _items:
        list.append(item.id)

    return list


func load_from_list(list: PoolIntArray) -> void:
    clear_all()

    for item in list:
        add_item_by_id(item)


func _on_list_item_selected(index: int) -> void:
    _viewport.show_item(_items[index].path)
    _desc.text = _items[index].description
