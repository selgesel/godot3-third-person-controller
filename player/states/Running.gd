extends PlayerState

export(float) var move_speed: float = 10
export(float) var sprint_speed: float = 14
export(float) var turn_speed: float = 10
export(float) var acceleration: float = 50
export(float) var cam_follow_speed: float = 8

var _move_rot: float = 0

func physics_process(delta):
    # call physics_process method of the the super class (State) which in turn calls the physics_process
    # method of the parent state (the super class is not the same as the parent state)
    .physics_process(delta)

    # get the movement direction directly from the controls node and turn it into a Vector3
    var move_dir = player.controls.get_movement_vector()
    var direction = Vector3(move_dir.x, 0, move_dir.y)

    # make the player move towards where the camera is facing by lerping the current movement rotation
    # towards the camera's horizontal rotation and rotating the raw movement direction with that angle
    _move_rot = lerp(_move_rot, deg2rad(player.camera._rot_h), cam_follow_speed * delta)
    direction = direction.rotated(Vector3.UP, _move_rot)

    # lerp the player's current horizontal velocity towards the horizontal velocity as determined by
    # the input direction and the running or sprinting speed based on the sprinting status
    var speed = sprint_speed if player.controls.is_sprinting() else move_speed
    player.velocity = player.velocity.linear_interpolate(direction * speed, acceleration * delta)

    # if the player is on the floor, set their vertical velocity to a miniscule negative value to "snap"
    # them to the ground
    if player.is_on_floor():
        player.y_velocity = -0.01
    else:
        # if not, they're most likely falling of a ledge, so transition into the InAir/Falling state
        state_machine.transition_to("InAir/Falling")

    # if the player has any amount of movement, lerp the player model's rotation towards the current
    # movement direction based on its angle towards the X+ axis on the XZ plane
    if move_dir != Vector2.ZERO:
        player.skin.rotation.y = lerp_angle(player.skin.rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)
