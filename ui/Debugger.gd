extends Control

onready var _label: Label = $Label
onready var _player: Spatial = get_tree().get_nodes_in_group("player")[0]

func _process(delta):
    var player_pos: Vector3 = _player.global_transform.origin
    _label.text = "Player Position: (%.2f, %.2f, %.2f)\n" % [player_pos.x, player_pos.y, player_pos.z]
    _label.text += "Move Direction: (%.2f, %.2f)\n" % [_player._move_dir.x, _player._move_dir.y]
    _label.text += "Is Jumping: %s\n" % [_player._is_jumping]
    _label.text += "Player Velocity: (%.2f, %.2f, %.2f)\n" % [_player._velocity.x, _player._y_velocity, _player._velocity.z]
    _label.text += "Player Rotation: %.2f\n" % [rad2deg(_player._rotation)]
    _label.text += "Jumps: %d\n" % [_player._jump_count]
    _label.text += "Jump Cooldown: %.2f\n" % [_player._jump_cooldown_remaining]
    _label.text += "Camera Rotation: (%.2f, %.2f)\n" % [_player._camera._rot_h, _player._camera._rot_v]
    _label.text += "Camera Distance: %.2f" % [_player._camera._distance]
