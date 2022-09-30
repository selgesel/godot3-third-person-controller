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

func enter():
    # set the current animation root state to Crouching
    player.anim_tree.set("parameters/RootState/current", 1)

func process(delta):
    # count down the jump and dash cooldown timers
    _dash_cooldown_remaining = max(_dash_cooldown_remaining - delta, 0)
    _jump_cooldown_remaining = max(_jump_cooldown_remaining - delta, 0)

    # if the player is trying to jump and they CAN jump, transition to the InAir/Jumping state
    if player.controls.is_jumping() && can_jump():
        state_machine.transition_to("InAir/Jumping")
    elif can_dash() && player.controls.is_dashing():
        # if the player is trying to dash and they CAN dash, transition to the InAir/Dashing state and
        # set the dash cooldown timer to the cooldown duration
        state_machine.transition_to("InAir/Dashing")
        _dash_cooldown_remaining = dash_cooldown

func physics_process(delta):
    # set the in air blend position to player's vertical velocity divided by 50, the max. terminal velocity
    player.anim_tree.set("parameters/InAir/blend_position", player.y_velocity / 50.0)

    # if the player is on the floor, transition to the OnGround state
    if player.is_on_floor():
        # if currently in the Falling state, also reset jump counters
        var state_name: String = "%s" % [state_machine._state.get_path()]
        if state_name.ends_with("Falling"):
            _jump_count = 0
            _jump_cooldown_remaining = 0
        state_machine.transition_to("OnGround")
        return

    # set the player's horizontal velocity based on the air speed
    set_horizontal_movement(air_speed, turn_speed, cam_follow_speed, air_acceleration, delta)

    # otherwise decrease the vertical velocity by gravity, clamped to the max terminal velocity we defined earlier
    player.y_velocity = clamp(player.y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

func can_dash():
    # if the dash cooldown timer is 0 or less the player can dash
    return _dash_cooldown_remaining <= 0

func can_jump():
    # if the player is on the floor, or if the current jump count is less than the max jump count and the jump
    # cooldown timer is 0 or less the player can jump
    return player.is_on_floor() || (_jump_count < max_jumps && _jump_cooldown_remaining <= 0)

func accept_jump():
    # increase the jump count and reset the jump cooldown timer
    _jump_count += 1
    _jump_cooldown_remaining = jump_cooldown
