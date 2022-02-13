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
onready var _controls: Controls = $Controls

var _move_dir: Vector2 = Vector2.ZERO
var _is_jumping: bool = false
var _move_rot: float = 0

var _velocity: Vector3 = Vector3.ZERO
var _y_velocity: float = 0
var _rotation: float = 0
var _jump_count: int = 0
var _jump_cooldown_remaining: float = 0

func _process(delta):
    # get the movement direction and jump status from the controls node
    _move_dir = _controls.get_movement_vector()
    _is_jumping = _controls.is_jumping()

func _physics_process(delta):
    # turn the 2D input movement direction into a Vector3 so it's easier to use later on
    var direction = Vector3(_move_dir.x, 0, _move_dir.y)

    # make the player move towards where the camera is facing by lerping the current movement rotation
    # towards the camera's horizontal rotation and rotating the raw movement direction with that angle
    _move_rot = lerp(_move_rot, deg2rad(_camera._rot_h), cam_follow_speed * delta)
    direction = direction.rotated(Vector3.UP, _move_rot)

    # lerp the current velocity towards the horizontal velocity as determined by the input direction
    # and the move speed
    _velocity = _velocity.linear_interpolate(direction * move_speed, acceleration * delta)

    # if the player is on the floor, reset jump timer and counter, and set vertical velocity to a
    # miniscule negative value so the player can "snap" to the ground when calling move_and_slide
    if is_on_floor():
        _y_velocity = -0.01
        _jump_count = 0
        _jump_cooldown_remaining = 0
    else:
        # if not it means that the player is falling, so count down the jump timer and decrease the
        # vertical velocity by gravity, clamped to the max terminal velocity we defined earlier
        _jump_cooldown_remaining -= delta
        _y_velocity = clamp(_y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

    # if player wants to jump, the jump count does not exceed the max jump count, and the remaining
    # jump cooldown is 0 or less we have the player jump
    # for that we reset the jumping black to false, set the vertical velocity to the jump force
    # increase the jump count by one, and reset the jump timer to the jump cooldown duration
    if _is_jumping && _jump_count < max_jumps && _jump_cooldown_remaining <= 0:
        _is_jumping = false
        _y_velocity = jump_force
        _jump_count += 1
        _jump_cooldown_remaining = jump_cooldown

    # if the player has any amount of movement, lerp the player model's rotation towards the current
    # movement direction based on its angle towards the X+ axis on the XZ plane
    if _move_dir != Vector2.ZERO:
        _rotation = lerp_angle(_rotation, atan2(-direction.x, -direction.z), turn_speed * delta)
        _skin.rotation.y = _rotation

    # set the Y component of the velocity to the vertical velocity determined by the code above
    # and update it using move_and_slide with the max slope angle we defined earlier
    _velocity.y = _y_velocity
    _velocity = move_and_slide(_velocity, Vector3.UP, false, 4, deg2rad(max_slope_angle))
