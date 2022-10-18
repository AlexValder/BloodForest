extends Viewport
class_name InventoryViewport

var _mesh: Spatial
var _rotating := false


func show_item(path: String) -> void:
    if _mesh != null:
        remove_child(_mesh)
        _mesh.queue_free()
        _mesh = null

    _mesh = (load(path) as PackedScene).instance() as VisualInstance
    _make_visible(_mesh)
    add_child(_mesh)


func clear() -> void:
    if _mesh == null:
        return

    _mesh.queue_free()


func reset_view() -> void:
    if _mesh == null:
        return

    _mesh.rotation = Vector3.ZERO


func _make_visible(obj: VisualInstance) -> void:
    obj.layers = 0
    obj.set_layer_mask_bit(1, true)

    for child in obj.get_children():
        if child is VisualInstance:
            _make_visible(child)



func _input(event: InputEvent) -> void:
    if _mesh == null:
        return

    if event is InputEventMouseButton:
        var e := event as InputEventMouseButton
        if e.button_index == BUTTON_LEFT:
            _rotating = e.pressed
            return

    if _rotating && event is InputEventMouseMotion:
        var e := event as InputEventMouseMotion
        _mesh.rotate_y(e.relative.x * 0.05)
        _mesh.rotate_x(-e.relative.y * 0.05)
