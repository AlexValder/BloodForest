class_name Player
extends KinematicBody

export var mouse_sensitivity := 0.001
export var joy_sensitivity := 0.01

const DUCK_SPEED := 2.5
const WALK_SPEED := 4.0
const RUN_SPEED := 7.0
const GRAVITY := -160

onready var _camera := $player_camera as PlayerCamera
onready var _ray := $player_camera/arm as RayCast
onready var _crosshair := $"%crosshair" as TextureRect
onready var _inventory := $HUD/inventory as Inventory
onready var _tween := $tween as Tween
var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN
var _ducking := false

onready var _icons := {
    "none" : preload("res://assets/gui/hud/none_icon.png"),
    "dot" : preload("res://assets/gui/hud/dot_icon.png"),
    "hand" : preload("res://assets/gui/hud/hand_icon.png"),
    "eye" : preload("res://assets/gui/hud/eye_icon.png"),
    "pickup" : preload("res://assets/gui/hud/pickup_icon.png"),
    "kill" : preload("res://assets/gui/hud/kill_icon.png"),
}


func pick_up(path: String) -> void:
    _inventory.add_item_by_path(path)


func load_inventory(items: PoolIntArray) -> void:
    _inventory.load_from_list(items)


func save_inventory() -> PoolIntArray:
    return _inventory.get_item_save()


func clear_inventory() -> void:
    _inventory.clear_inventory()


func _ready() -> void:
    _inventory.hide()


func _speed() -> float:
    if _ducking:
        return DUCK_SPEED
    if Input.is_action_pressed("run"):
        return RUN_SPEED
    return WALK_SPEED


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        get_tree().set_input_as_handled()

        _camera.rotation.x -= event.relative.y * mouse_sensitivity
        _camera.rotation.x = clamp(_camera.rotation.x, -PI/2, PI/6)

        rotation.y -= event.relative.x * mouse_sensitivity
        rotation.y = wrapf(rotation.y, 0, 2*PI)

    if event.is_action_released("inventory"):
        get_tree().set_input_as_handled()
        _inventory.show_inv()


    if event.is_action_released("interact"):
        get_tree().set_input_as_handled()

        var obj := _ray.get_collider() as InterArea
        if obj != null:
            obj.ray_interacted()

    if event.is_action_pressed("duck"):
        _tween_ducking(true)
    elif event.is_action_released("duck"):
        _tween_ducking(false)


func _tween_ducking(ducking: bool) -> void:
    _ducking = ducking
    get_tree().set_input_as_handled()
    var success = _tween.stop_all()
    assert(success, "Failed to stop_all on the tween")
    success = _tween.interpolate_property(
        self, "scale:y", null, 0.5 if ducking else 1.0, 0.25,
        Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
    assert(success, "Failed to interpolate_property on the tween")
    success = _tween.start()
    assert(success, "Failed to start on the tween")


func _physics_process(delta: float) -> void:
    var collider := _ray.get_collider()
    _process_collision(collider)

    var look_dir := Input.get_vector(
        "look_left", "look_right", "look_up", "look_down")
    _camera.rotation.x -= look_dir.y * joy_sensitivity
    _camera.rotation.x = clamp(_camera.rotation.x, -PI/2, PI/6)

    rotation.y -= look_dir.x * joy_sensitivity
    rotation.y = wrapf(rotation.y, 0, 2*PI)

    var hor_dir := Input.get_vector("left", "right", "forward", "back")
    var move_dir := Vector3(-hor_dir.x, 0, -hor_dir.y)
    move_dir = move_dir.rotated(Vector3.UP, rotation.y).normalized()

    _velocity.x = move_dir.x * _speed()
    _velocity.z = move_dir.z * _speed()
    _velocity.y = GRAVITY * delta

    _velocity = move_and_slide_with_snap(_velocity, _snap_vector)


func _process_collision(coll: InterArea) -> void:
    if coll == null:
        _crosshair.texture = _icons["dot"]
        _crosshair.self_modulate = Color.gray
        return

    _crosshair.self_modulate = Color.white
    match (coll.type):
        1:
            _crosshair.texture = _icons["eye"]
        2:
            _crosshair.texture = _icons["hand"]
        3:
            _crosshair.texture = _icons["pickup"]
        4:
            _crosshair.texture = _icons["kill"]
        _:
            _crosshair.texture = _icons["none"]
            if coll.type != 0:
                push_warning("Unknown interactable type")
