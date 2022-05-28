extends KinematicBody

class_name Player

signal movement_state_changed(new_state)

export(float) var max_slope_angle: float = 50

onready var skin: Spatial = $Skin
onready var player_doll: Spatial = $Skin/PlayerDoll
onready var camera: ControllableCamera = $CamRoot/ControllableCamera
onready var controls: Controls = $Controls
onready var anim_tree: AnimationTree = $Skin/AnimationTree
onready var vfx_dash: Particles = $Skin/VfxDash
onready var vfx_surge: Particles = $Skin/VfxSurge
onready var sm_movement: StateMachine = $Movement
onready var water_surface_detector: Area = $WaterSurfaceDetector

var velocity: Vector3 = Vector3.ZERO
var y_velocity: float = 0
var head_above_water: bool = true

var _real_velocity: Vector3 = Vector3.ZERO

func _ready():
    # watch for changes in the movement state
    sm_movement.connect("transitioned", self, "_on_move_state_changed")

func _physics_process(delta):
    # the real velocity is a combination of the horizontal and vertical velocities as determined by
    # the movement state machine
    _real_velocity = Vector3(velocity.x, y_velocity, velocity.z)
    _real_velocity = move_and_slide(_real_velocity, Vector3.UP, false, 4, deg2rad(max_slope_angle))

func has_movement():
    # the player is fully stopped only if both the movement vector and the velocity
    # vectors are approximately zero. otherwise it means they have movement
    return controls.get_movement_vector() != Vector2.ZERO || !velocity.is_equal_approx(Vector3.ZERO)

func _on_DeepWaterDetector_area_entered(area):
    # entered a deep enough water to swim in, transition to the Swimming/Diving state
    sm_movement.transition_to("Swimming/Diving")

func _on_DeepWaterDetector_area_exited(area):
    # exited deep water, transition to the InAir/Falling state
    sm_movement.transition_to("InAir/Falling")

func _on_WaterSurfaceDetector_area_entered(area):
    # the player's head is below the water surface
    head_above_water = false

func _on_WaterSurfaceDetector_area_exited(area):
    # the player's head is above the water surface
    head_above_water = true

func _on_move_state_changed(new_state):
    # trigger the
    emit_signal("movement_state_changed", new_state)
