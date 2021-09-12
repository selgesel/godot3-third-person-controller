extends Control

class_name MobileControls

export(float) var zoom_step: float = .5

onready var _move_stick: VirtualThumbStick = $MoveStick
onready var _parent = get_parent()

var _cam_rot: Vector2 = Vector2.ZERO
var _touches := {}
var _zoom_scale_delta: float = 0
var _zoom_scale: float = 0

func _process(delta):
    if !is_visible_in_tree():
        return

    if _touches.size() == 2:
        var keys := _touches.keys()
        var touch1 = _touches[keys[0]]
        var touch2 = _touches[keys[1]]
        var begin_distance: float = touch2.begin.distance_to(touch1.begin)
        var current_distance: float = touch2.current.distance_to(touch1.current)

        var ratio: float = 0 if begin_distance == 0 else current_distance / begin_distance
        if ratio > 0:
            _zoom_scale_delta = floor(log(ratio) * zoom_step * 100) / 100
    elif _zoom_scale_delta != 0:
        set_zoom_scale(get_zoom_scale())

func _input(event):
    if !is_visible_in_tree():
        return

    if event is InputEventScreenTouch && event.is_pressed() && event.index != _move_stick._touch_index:
        _touches[event.index] = {"begin": event.position, "current": event.position}
    if event is InputEventScreenTouch && !event.is_pressed() && _touches.has(event.index):
        _touches.erase(event.index)
    if event is InputEventScreenDrag && _touches.has(event.index):
        _touches[event.index].current = event.position

        if _touches.size() == 1:
            _cam_rot.x -= event.relative.x * _parent.sensitivity
            _cam_rot.y -= event.relative.y * _parent.sensitivity
            _cam_rot.y = clamp(_cam_rot.y, _parent.min_pitch, _parent.max_pitch)

func get_movement_vector():
    return _move_stick.get_value()

func get_camera_rotation():
    return _cam_rot

func get_zoom_scale():
    return _zoom_scale + _zoom_scale_delta

func set_zoom_scale(zoom_scale):
    _zoom_scale = zoom_scale
    _zoom_scale_delta = 0
