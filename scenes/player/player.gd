class_name Player
extends KinematicBody

export var mouse_sensitivity := 0.001
export var joy_sensitivity := 0.01

const WALK_SPEED := 4.0
const RUN_SPEED := 6.0
const ACCEL := 40.0
const GRAVITY := -160

onready var _camera := $player_camera as PlayerCamera
var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN


func _speed() -> float:
    return RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _camera.rotation.x -= event.relative.y * mouse_sensitivity
        _camera.rotation.x = clamp(_camera.rotation.x, -PI/2, PI/6)

        rotation.y -= event.relative.x * mouse_sensitivity
        rotation.y = wrapf(rotation.y, 0, 2*PI)


func _physics_process(delta: float) -> void:
    var look_dir := Input.get_vector("look_left", "look_right", "look_up", "look_down")
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
