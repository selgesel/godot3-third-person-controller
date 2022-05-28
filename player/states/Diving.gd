extends PlayerState

export(float) var stop_speed: float = 6
export(float) var velocity_threshold: float = 0.5

func physics_process(delta):
    # update the parent state
    .physics_process(delta)

    # lerp the player's horizontal and vertical velocities towards zero so they stop to a halt while diving
    player.velocity = player.velocity.linear_interpolate(Vector3.ZERO, stop_speed * delta)
    player.y_velocity = lerp(player.y_velocity, 0, stop_speed * delta)

    # if the player's y velocity is below a certain threshold, navigate to the Swimming/Underwater state
    if abs(player.y_velocity) <= velocity_threshold:
        state_machine.transition_to("Swimming/Underwater")
