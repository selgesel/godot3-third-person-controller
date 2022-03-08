extends PlayerState

export(float) var dash_cooldown: float = 1
export(float) var jump_cooldown: float = .2
export(float) var gravity: float = .98
export(float) var max_terminal_velocity: float = 50
export(int) var max_jumps: int = 2

export(float) var air_speed: float = 8
export(float) var air_acceleration: float = 10
export(float) var cam_follow_speed: float = 8
export(float) var turn_speed: float = 10

var _dash_cooldown_remaining: float = 0

var _jump_count: int = 0
var _jump_cooldown_remaining: float = 0

var _move_rot: float = 0

func process(delta):
    # count down the jump and dash cooldown timers
    _dash_cooldown_remaining = max(_dash_cooldown_remaining - delta, 0)
    _jump_cooldown_remaining = max(_jump_cooldown_remaining - delta, 0)

    # if the player is trying to jump and they CAN jump, transition to the InAir/Jumping state, increase
    # the current jump count, and reset the jump cooldown timer to the cooldown duration
    if player.controls.is_jumping() && can_jump():
        state_machine.transition_to("InAir/Jumping")
        _jump_count += 1
        _jump_cooldown_remaining = jump_cooldown
    elif can_dash() && player.controls.is_dashing():
        # if the player is trying to dash and they CAN dash, transition to the InAir/Dashing state and
        # set the dash cooldown timer to the cooldown duration
        state_machine.transition_to("InAir/Dashing")
        _dash_cooldown_remaining = dash_cooldown
    else:
        # otherwise the player is most likely falling, so transition to the InAir/Falling state
        state_machine.transition_to("InAir/Falling")

func physics_process(delta):
    # if the player is on the floor, reset the jump timer and counter, and transition to the OnGround state
    if player.is_on_floor():
        _jump_count = 0
        _jump_cooldown_remaining = 0
        state_machine.transition_to("OnGround")
        return

    # for air control, get the horizontal movement direction from the controls node and apply the same
    # logic as the OnGround\Running state
    var move_dir = player.controls.get_movement_vector()
    var direction = Vector3(move_dir.x, 0, move_dir.y)

    _move_rot = lerp(_move_rot, deg2rad(player.camera._rot_h), cam_follow_speed * delta)
    direction = direction.rotated(Vector3.UP, _move_rot)

    player.velocity = player.velocity.linear_interpolate(direction * air_speed, air_acceleration * delta)

    # otherwise decrease the vertical velocity by gravity, clamped to the max terminal velocity we defined earlier
    player.y_velocity = clamp(player.y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

    if move_dir != Vector2.ZERO:
        player.skin.rotation.y = lerp_angle(player.skin.rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)

func can_dash():
    # if the dash cooldown timer is 0 or less the player can dash
    return _dash_cooldown_remaining <= 0

func can_jump():
    # if the player is on the floor, or if the current jump count is less than the max jump count and the jump
    # cooldown timer is 0 or less the player can jump
    return player.is_on_floor() || (_jump_count < max_jumps && _jump_cooldown_remaining <= 0)
