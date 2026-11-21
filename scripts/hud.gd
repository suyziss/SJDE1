extends CanvasLayer

var speed_label: Label

func _ready() -> void:
    var root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    speed_label = Label.new()
    speed_label.text = "0 km/h"
    speed_label.add_theme_font_size_override("font_size", 30)
    speed_label.position = Vector2(28, 24)
    speed_label.add_theme_color_override("font_color", Color.WHITE)
    root.add_child(speed_label)

    _make_button(root, "◀", "steer_left", Vector2(35, -130), Vector2(88, 78), true)
    _make_button(root, "▶", "steer_right", Vector2(135, -130), Vector2(88, 78), true)
    _make_button(root, "BRAKE", "brake", Vector2(-220, -125), Vector2(92, 76), false)
    _make_button(root, "GAS", "accelerate", Vector2(-112, -125), Vector2(92, 76), false)
    _make_button(root, "DRIFT", "handbrake", Vector2(-112, -225), Vector2(92, 68), false)

    var hint = Label.new()
    hint.text = "JDM HORIZON  •  TOUGE TEST AREA"
    hint.position = Vector2(28, 66)
    hint.add_theme_font_size_override("font_size", 15)
    hint.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96, 0.85))
    root.add_child(hint)

func _make_button(parent: Control, caption: String, action: String, offset: Vector2, size: Vector2, left_side: bool) -> void:
    var b = Button.new()
    b.text = caption
    b.custom_minimum_size = size
    b.size = size
    b.add_theme_font_size_override("font_size", 19)
    b.add_theme_color_override("font_color", Color.WHITE)
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.06, 0.09, 0.62)
    style.border_color = Color(0.85, 0.12, 0.16, 0.9)
    style.set_border_width_all(2)
    style.set_corner_radius_all(16)
    b.add_theme_stylebox_override("normal", style)
    var pressed_style = style.duplicate()
    pressed_style.bg_color = Color(0.65, 0.06, 0.10, 0.85)
    b.add_theme_stylebox_override("pressed", pressed_style)
    if left_side:
        b.anchor_left = 0.0
        b.anchor_top = 1.0
        b.position = Vector2(25 + offset.x, offset.y)
    else:
        b.anchor_left = 1.0
        b.anchor_top = 1.0
        b.position = Vector2(offset.x, offset.y)
    b.button_down.connect(func(): Input.action_press(action))
    b.button_up.connect(func(): Input.action_release(action))
    parent.add_child(b)
