class_name Player
extends KinematicBody

export(float, 0.00001, 0.01) var mouse_sensitivity := 0.001
export(float, 0.00001, 0.01) var joy_sensitivity := 0.01
export(Resource) var health

const DUCK_SPEED := 2.5
const WALK_SPEED := 4.0
const RUN_SPEED := 7.0
const GRAVITY := -160

onready var _camera := $player_camera as PlayerCamera
onready var _ray := $player_camera/arm as RayCast
onready var _crosshair := $"%crosshair" as TextureRect
onready var _inventory := $HUD/inventory as Inventory
onready var _health_label := $"%health" as Label
onready var _damage_rect := $"%damage" as ColorRect
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
    _inventory.clear_all()


func _ready() -> void:
    _inventory.hide()

    assert(health != null, "Health not set")
    health.reset()
    var error = health.connect("health_empty", self, "_on_death")
    if error != OK:
        push_error("Failed to connect _on_death")

    _health_label.visible = OS.is_debug_build()

    if _health_label.visible:
        _health_label.text = "Health: %d" % health.current_value

    error = health.connect("health_changed", self, "_on_health_change")
    if error != OK:
        push_error("Failed to connect _on_health_change")


func _on_death() -> void:
    _inventory.clear_all()
    GameManager.restart_level()


func _on_health_change(old: int, new: int) -> void:
    _health_label.text = "Health: %d" % new

    if old > new:
        _damage_indicator(old - new, 210.0 / 255.0, 0, 0)
    else:
        _damage_indicator(new - old, 1, 1, 1)


func _damage_indicator(diff: int, r: float, g: float, b: float) -> void:
    if !_tween.stop(_damage_rect, "modulate:a"):
        push_error("Failed to stop tween on _damage_rect")
    _damage_rect.modulate.r = r
    _damage_rect.modulate.g = g
    _damage_rect.modulate.b = b
    _damage_rect.modulate.a = float(2 * diff) / float(health.max_value)
    if !_tween.interpolate_property(_damage_rect, "modulate:a", null, 0, .5):
        push_error("Failed to interpolate property on _damage_rect")
    if !_tween.start():
        push_error("Failed to start tween on _damage_rect")


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

    if event is InputEventKey:
        if event.is_pressed():
            if event.scancode == KEY_Q:
                get_tree().set_input_as_handled()
                health.take_damage(3)
            elif event.scancode == KEY_E:
                get_tree().set_input_as_handled()
                health.heal(3)

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
    var success = _tween.stop(self, "scale:y")
    assert(success, "Failed to stop('scale:y') on the tween")
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
