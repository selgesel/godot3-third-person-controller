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
    # if the node or one of its ancestors is not visible in the scene tree don't do anything
    if !is_visible_in_tree():
        return

    # if the current number of fingers pressed on the screen is 2
    if _touches.size() == 2:
        var keys := _touches.keys()
        var touch1 = _touches[keys[0]]
        var touch2 = _touches[keys[1]]

        # get the distances between the two fingers both right now and at the beginning of the gesture
        var begin_distance: float = touch2.begin.distance_to(touch1.begin)
        var current_distance: float = touch2.current.distance_to(touch1.current)

        # get the ratio of the current distance to the beginning distance
        var ratio: float = 0 if begin_distance == 0 else current_distance / begin_distance

        # this ratio should almost always be positive, but if it somehow happens to be 0 or negative
        # we might end up with weird numbers that would cause weird zoom effects, so we just ignore
        # any non-positive value
        if ratio > 0:
            # otherwise we just take the log() of this ratio and round it to the nearest 0.05, aka
            # the zoom step, and assign the result to the delta zoom scale value. also note how we
            # also used the negative because we divided the current distance by the beginning distance
            # if we did the oppostive we wouldn't have to use the negative, but oh well
            _zoom_scale_delta = -floor(log(ratio) * zoom_step * 100) / 100
    elif _zoom_scale_delta != 0:
        # otherwise if we have a delta zoom scale that's left from an ongoing zoom gesture, set the
        # current zoom scale to that value, and reset the delta back to 0
        set_zoom_scale(get_zoom_scale())

func _input(event):
    # if the node or one of its ancestors is not visible in the scene tree don't do anything
    if !is_visible_in_tree():
        return

    # if a finger has just touched the screen and if it's not the same as the one pressed on the move stick
    if event is InputEventScreenTouch && event.is_pressed() && event.index != _move_stick._touch_index:
        # store the finger's current position as both the current and beginning positions
        _touches[event.index] = {"begin": event.position, "current": event.position}

    # if a finger has just been lifted off and if it's one of the fingers we're tracking, stop tracking it
    if event is InputEventScreenTouch && !event.is_pressed() && _touches.has(event.index):
        _touches.erase(event.index)

    # if a pressed finger has moved and if we're tracking that finger
    if event is InputEventScreenDrag && _touches.has(event.index):
        # update its current position in our store
        _touches[event.index].current = event.position

        # if it's the only finger that we're tracking than consider its movement to be a camera rotate
        # gesture, so update the current camera rotation values based on its relative movement and the
        # sensitivity value, clamped to the min and max pitch values from our parent node which is the
        # main controls node
        if _touches.size() == 1:
            _cam_rot.x -= event.relative.x * _parent.sensitivity
            _cam_rot.y -= event.relative.y * _parent.sensitivity
            _cam_rot.y = clamp(_cam_rot.y, _parent.min_pitch, _parent.max_pitch)

func get_movement_vector():
    return _move_stick.get_value()

func get_camera_rotation():
    return _cam_rot

func get_zoom_scale():
    return clamp(_zoom_scale + _zoom_scale_delta, 0, 1)

func set_zoom_scale(zoom_scale):
    _zoom_scale = zoom_scale
    _zoom_scale_delta = 0
