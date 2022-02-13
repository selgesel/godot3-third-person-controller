extends Node

class_name Controls

export(float) var min_pitch: float = -90
export(float) var max_pitch: float = 75
export(float) var zoom_step: float = .05
export(float) var sensitivity: float = 0.1

onready var _mobile_controls = $MobileControls

var _move_vec: Vector2 = Vector2.ZERO
var _cam_rot: Vector2 = Vector2.ZERO
var _zoom_scale: float = 0
var _is_jumping: bool = false
var _is_capturing: bool = false
var _is_touchscreen: bool = false

func _ready():
    # wait until the parent node is ready
    yield(get_parent(), "ready")

    # OS.has_touchscreen_ui_hint() reports true for anything with touch support including HTML5
    # which isn't exactly what we want when it comes down to enabling touchscreen controls
    # so instead we check if the OS name is Android or iOS, and if so, we enable touch controls
    var os_name := OS.get_name()
    if os_name == "Android" || os_name == "iOS":
        _is_touchscreen = true

    # if touchscreen controls are disabled we capture the mouse in the game window
    if !_is_touchscreen:
        _is_capturing = true
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        # otherwise we just make the mobile controls node visible
        _mobile_controls.visible = true

func _process(delta):
    # if the mouse cursor is being captured in the game window
    if _is_capturing:
        # determine the movement direction based on the input strengths of the four movement directions
        var dx := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
        var dy := Input.get_action_strength("move_forward") - Input.get_action_strength("move_backwards")

        # and set the movement direction vector to the normalized vector so the player can't unintentionally
        # move faster when moving diagonally
        _move_vec = Vector2(dx, -dy).normalized()
    elif _is_touchscreen:
        # othwerise if we're on a touchscreen device, get the movement direction, camera rotation and
        # zoom scale values from the mobile controls node
        _move_vec = _mobile_controls.get_movement_vector()
        _cam_rot = _mobile_controls.get_camera_rotation()
        _zoom_scale = _mobile_controls.get_zoom_scale()

    # in both desktop and touch screen devices the jump flag can be determined via the jump action
    _is_jumping = Input.is_action_just_pressed("jump")

func _input(event):
    # on non-touchscreen devices toggle the mouse cursor's capture mode when the ui_cancel action is
    # pressed (e.g. the Esc key)
    if !_is_touchscreen && Input.is_action_just_pressed("ui_cancel"):
        _is_capturing = !_is_capturing

        if _is_capturing:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    # if the mouse cursor is being captured, update the camera rotation using the relative movement
    # and the sensitivity we defined earlier. also clamp the vertical camera rotation to the pitch
    # range we defined earlier so we don't end up in weird look angles
    if _is_capturing && event is InputEventMouseMotion:
        _cam_rot.x -= event.relative.x * sensitivity
        _cam_rot.y -= event.relative.y * sensitivity
        _cam_rot.y = clamp(_cam_rot.y, min_pitch, max_pitch)

    # if the mouse cursor is being captured, increse or decrease the zoom when the corresponding
    # action has just been pressed
    if _is_capturing:
        if Input.is_action_just_pressed("zoom_in"):
            _zoom_scale = clamp(_zoom_scale - zoom_step, 0, 1)
        if Input.is_action_just_pressed("zoom_out"):
            _zoom_scale = clamp(_zoom_scale + zoom_step, 0, 1)

func get_movement_vector():
    return _move_vec

func is_jumping():
    return _is_jumping

func get_camera_rotation():
    return _cam_rot

func get_zoom_scale():
    return _zoom_scale

func set_zoom_scale(zoom_scale):
    _zoom_scale = zoom_scale
    _mobile_controls.set_zoom_scale(zoom_scale)
