extends KinematicBody

class_name Player

export(float) var max_slope_angle: float = 50

onready var skin: Spatial = $Skin
onready var camera: ControllableCamera = $CamRoot/ControllableCamera
onready var controls: Controls = $Controls

var velocity: Vector3 = Vector3.ZERO
var y_velocity: float = 0

var _real_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta):
    # the real velocity is a combination of the horizontal and vertical velocities as determined by
    # the movement state machine
    _real_velocity = Vector3(velocity.x, y_velocity, velocity.z)
    _real_velocity = move_and_slide(_real_velocity, Vector3.UP, false, 4, deg2rad(max_slope_angle))

func has_movement():
    # the player is fully stopped only if both the movement vector and the velocity
    # vectors are approximately zero. otherwise it means they have movement
    return controls.get_movement_vector() != Vector2.ZERO || !velocity.is_equal_approx(Vector3.ZERO)
