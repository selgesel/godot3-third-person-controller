extends Spatial

class_name ControllableCamera

export(float) var min_pitch: float = -90
export(float) var max_pitch: float = 75
export(float) var rotate_speed: float = 10
export(float) var sensitivity: float = 0.1
export(float) var zoom_speed: float = 10
export(float) var zoom_step: float = .5
export(float) var min_distance: float = 3
export(float) var max_distance: float = 10

onready var _gimbal_h: Spatial = $GimbalH
onready var _gimbal_v: Spatial = $GimbalH/GimbalV
onready var _camera: ClippedCamera = $GimbalH/GimbalV/ClippedCamera

var _rot_h: float = 0
var _rot_v: float = 0
var _is_capturing: bool = true
var _distance: float = 0

func _ready():
    yield(get_parent(), "ready")
    _distance = _camera.transform.origin.z
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if Input.is_action_just_pressed("ui_cancel"):
        _is_capturing = !_is_capturing

        if _is_capturing:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if _is_capturing && event is InputEventMouseMotion:
        _rot_h -= event.relative.x * sensitivity
        _rot_v -= event.relative.y * sensitivity

    _rot_v = clamp(_rot_v, min_pitch, max_pitch)

    if _is_capturing:
        if Input.is_action_just_pressed("zoom_in"):
            _distance = clamp(_distance - zoom_step, min_distance, max_distance)
        if Input.is_action_just_pressed("zoom_out"):
            _distance = clamp(_distance + zoom_step, min_distance, max_distance)

func _physics_process(delta):
    _gimbal_h.rotation_degrees.y = lerp(_gimbal_h.rotation_degrees.y, _rot_h, rotate_speed * delta)
    _gimbal_v.rotation_degrees.x = lerp(_gimbal_v.rotation_degrees.x, _rot_v, rotate_speed * delta)

    _camera.transform.origin.z = lerp(_camera.transform.origin.z, _distance, zoom_speed * delta)
