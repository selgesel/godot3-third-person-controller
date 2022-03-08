# Changelog

## 0.0.4
- Refactored movement system using state machines
- Added new movement types
    - Dashing
        - Allows player to slingshot themselves in the current movement direction
        - Key binding: Q
    - Sprinting
        - Allows player to run faster
        - Key binding: Shift
    - Crouching
        - Allows player to crouch and move slowly
        - While crouching the player cannot dash or sprint
        - Key binding: Ctrl

## 0.0.3
- Implemented touch screen controls
    - Touchscreen mode is automatically enabled on Android and iOS devices
    - Move thumb stick to move
    - Screen drag to rotate camera
    - Press button to jump
    - Pinch with two fingers to zoom in and out

## 0.0.2
- Implemented a controllable camera and replaced the old camera with it
    - Camera is controlled by moving the mouse
    - Camera can be zoomed in and out via mouse wheel
    - Player can toggle between captured and visible mouse modes; trapping it inside the game window or just letting it loose
    - The camera is a `ClippedCamera` which prevents it from clipping through the environment (though it's not really perfect)

## 0.0.1
- Added the initial project version with the following features:
    - A simple scene with platforms and slopes to test the movement system
    - Basic horizontal movement
    - Ability to jump multiple times
