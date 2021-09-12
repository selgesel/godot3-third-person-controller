# Godot Third Person Player Controller
A third person player controller with touchscreen support for Godot.

I sometimes update this repository with new features, but the master branch should always be stable and up-to-date.

If you're interested in the timeline of features see [CHANGELOG.md](./CHANGELOG.md)

You can also see the [Releases](https://github.com/selgesel/godot-third-person-controller/releases) page for the individual releases.

![Preview](./preview.gif)

## Desktop Controls
| Keys | Action Name | Description |
|------|-------------|-------------|
| `W` | `move_forward` | Move character forward |
| `S` | `move_backwards` | Move character backwards |
| `A` | `move_left` | Move character to the left |
| `D` | `move_right` | Move character to the right |
| `Space` | `jump` | Have the character jump |
| `Esc` | `ui_cancel` | (Built-in) Toggle between captured and visible mouse modes |
| `Mouse Wheel Up` | `zoom_in` | Move the camera closer to the player |
| `Mouse Wheel Down` | `zoom_out` | Move the camera further away from the player |

## Touchscreen Gestures
| Gesture | Context | Description |
|---------|---------|-------------|
| Drag | Thumb Stick (Left) | Move the character around with a speed relative to drag distance |
| Drag | Screen | Rotate the camera |
| Press | Button (Right) | Have the character jump |
| Pinch In (Two Fingers) | Screen | Move the camera closer to the player |
| Pinch Out (Two Fingers) | Screen | Move the camera closer to the player |

## License
MIT
