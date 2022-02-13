tool

extends Control

class_name VirtualButton

export(Texture) var button_texture: Texture setget set_button_texture
export(String) var action: String

onready var _texture_rect: TextureRect = $TextureRect

func _ready():
    # since this is a tool node, trigger update it as soon as it's ready so it also changes in the editor
    set_button_texture(button_texture)

func _input(event):
    # if the node or one of its ancestors is not visible in the scene tree don't do anything
    if !is_visible_in_tree():
        return

    # if a finger has just been pressed on the screen and if it's position is inside our global rect
    if event is InputEventScreenTouch && event.is_pressed() && action && get_global_rect().has_point(event.position):
        # mark the current event as handled and raise an action pressed event for this action
        get_tree().set_input_as_handled()
        Input.action_press(action)

func set_button_texture(texture):
    # this variable might be null when in the editor, so only update its texture if it's not
    if _texture_rect:
        _texture_rect.texture = texture
    button_texture = texture
