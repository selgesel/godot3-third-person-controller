extends PlayerState

func process(delta):
    # if the player is not trying to crouch, transition back to the OnGround state
    if !player.controls.is_crouching():
        state_machine.transition_to("OnGround")
    elif player.has_movement():
        # if the player has some horizontal movement, transition to the Crouching/Moving state
        state_machine.transition_to("Crouching/Moving")
    else:
        # if the player is not moving at all, transition to the Crouching/Stopped state
        state_machine.transition_to("Crouching/Stopped")
