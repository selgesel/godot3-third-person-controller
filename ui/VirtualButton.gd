tool

extends Control

class_name VirtualButton

export(Texture) var button_texture: Texture setget set_button_texture
export(String) var action: String

onready var _texture_rect: TextureRect = $TextureRect

func _ready():
    set_button_texture(button_texture)

func _input(event):
    if !is_visible_in_tree():
        return

    if event is InputEventScreenTouch && event.is_pressed() && action && get_global_rect().has_point(event.position):
        get_tree().set_input_as_handled()
        Input.action_press(action)

func set_button_texture(texture):
    if _texture_rect:
        _texture_rect.texture = texture
    button_texture = texture
