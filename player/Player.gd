extends KinematicBody

export(float) var move_speed: float = 10
export(float) var turn_speed: float = 10
export(float) var jump_force: float = 16
export(float) var acceleration: float = 50
export(float) var gravity: float = .98
export(float) var max_terminal_velocity: float = 50
export(float) var max_slope_angle: float = 50
export(int) var max_jumps: int = 2
export(float) var jump_cooldown: float = .2
export(float) var cam_follow_speed: float = 8

onready var _skin: Spatial = $Skin
onready var _camera: ControllableCamera = $CamRoot/ControllableCamera

var _move_dir: Vector2 = Vector2.ZERO
var _is_jumping: bool = false
var _move_rot: float = 0

var _velocity: Vector3 = Vector3.ZERO
var _y_velocity: float = 0
var _rotation: float = 0
var _jump_count: int = 0
var _jump_cooldown_remaining: float = 0

func _process(delta):
    var dx := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    var dy := Input.get_action_strength("move_forward") - Input.get_action_strength("move_backwards")
    
    _move_dir = Vector2(dx, -dy).normalized()
    _is_jumping = Input.is_action_just_pressed("jump")

func _physics_process(delta):
    var direction = Vector3(_move_dir.x, 0, _move_dir.y)

    _move_rot = lerp(_move_rot, deg2rad(_camera._rot_h), cam_follow_speed * delta)
    direction = direction.rotated(Vector3.UP, _move_rot)

    _velocity = _velocity.linear_interpolate(direction * move_speed, acceleration * delta)
    
    if is_on_floor():
        _y_velocity = -0.01
        _jump_count = 0
        _jump_cooldown_remaining = 0
    else:
        _jump_cooldown_remaining -= delta
        _y_velocity = clamp(_y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

    if _is_jumping && _jump_count < max_jumps && _jump_cooldown_remaining <= 0:
        _is_jumping = false
        _y_velocity = jump_force
        _jump_count += 1
        _jump_cooldown_remaining = jump_cooldown

    if _move_dir != Vector2.ZERO:
        _rotation = lerp_angle(_rotation, atan2(-direction.x, -direction.z), turn_speed * delta)
        _skin.rotation.y = _rotation

    _velocity.y = _y_velocity
    _velocity = move_and_slide(_velocity, Vector3.UP, false, 4, deg2rad(max_slope_angle))
