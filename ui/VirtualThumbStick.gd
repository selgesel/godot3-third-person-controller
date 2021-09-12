extends Control

class_name VirtualThumbStick

export(float) var max_distance: float = 300
export(float) var animate_speed: float = 10

onready var _ring: TextureRect = $Ring
onready var _indicator: TextureRect = $Indicator

var _value: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _touch_index: int = -1
var _drag_origin: Vector2 = Vector2.ZERO
var _target_ring_scale: Vector2 = Vector2.ONE
var _target_ring_rotation: float = 0

func _input(event):
    if !is_visible_in_tree():
        return

    if event is InputEventScreenTouch && event.is_pressed() && get_global_rect().has_point(event.position):
        _begin_drag(event)
    if event is InputEventScreenTouch && !event.is_pressed() && event.index == _touch_index:
        _end_drag(event)
    if event is InputEventScreenDrag && event.index == _touch_index:
        _update_drag(event)

func _begin_drag(event: InputEventScreenTouch):
    if _is_dragging:
        return

    _touch_index = event.index
    _is_dragging = true

    var global_rect := get_global_rect()
    _drag_origin = global_rect.position + global_rect.size / 2

func _update_drag(event: InputEventScreenDrag):
    if !_is_dragging && event.index != _touch_index:
        return

    var raw_drag_vec := event.position - _drag_origin
    var raw_length := clamp(raw_drag_vec.length(), 0, max_distance)
    var length := raw_length / max_distance

    _value = raw_drag_vec.normalized() * length

    _target_ring_rotation = atan2(_value.y, _value.x)
    _target_ring_scale = Vector2.ONE * length

func _end_drag(event: InputEventScreenTouch):
    _touch_index = -1
    _is_dragging = false
    _value = Vector2.ZERO

func _process(delta):
    if !is_visible_in_tree():
        return

    _ring.modulate.a = lerp(_ring.modulate.a, 1 if _is_dragging else 0, animate_speed * delta)
    _ring.rect_scale = lerp(_ring.rect_scale, _target_ring_scale, animate_speed * delta)

    var rotation: float = lerp_angle(_indicator.get_rotation(), _target_ring_rotation, animate_speed * delta)
    _indicator.set_rotation(rotation)
    _indicator.modulate.a = lerp(_indicator.modulate.a, 1 if _is_dragging else 0, animate_speed * delta)
    _indicator.rect_scale = lerp(_indicator.rect_scale, _target_ring_scale, animate_speed * delta)

func get_value():
    return _value
