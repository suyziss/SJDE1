extends CanvasLayer
var player_car: CharacterBody3D
var speed_label: Label
var root: Control
var settings_panel: PanelContainer
var move_mode := false
var control_buttons: Dictionary = {}
var actions = {"left":"steer_left","right":"steer_right","brake":"brake","gas":"accelerate","drift":"handbrake"}
var positions = {"left":Vector2(28,-154),"right":Vector2(132,-154),"brake":Vector2(-230,-150),"gas":Vector2(-124,-150),"drift":Vector2(-178,-250)}
var button_size := 88.0
var button_opacity := 0.76
var config := ConfigFile.new()
func _ready() -> void:
    config.load("user://jdm_controls.cfg")
    button_size = float(config.get_value("controls","size",88.0))
    button_opacity = float(config.get_value("controls","opacity",0.76))
    for key in positions:
        positions[key] = config.get_value("positions",key,positions[key])
    root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(root)
    speed_label = Label.new()
    speed_label.text = "0 km/h"
    speed_label.add_theme_font_size_override("font_size",28)
    speed_label.position = Vector2(26,22)
    speed_label.add_theme_color_override("font_color",Color.WHITE)
    root.add_child(speed_label)
    _make_drive_buttons()
    _make_garage_menu()
func _process(_delta: float) -> void:
    if is_instance_valid(player_car) and player_car.drive_enabled:
        speed_label.text = "%03d km/h" % int(abs(player_car.speed*3.6))
    else:
        speed_label.text = "GARAGE  /  JDM HORIZON"
func _make_drive_buttons() -> void:
    for key in actions:
        var b = TextureButton.new()
        b.name = key.capitalize()+"Control"
        b.texture_normal = load("res://assets/ui/%s.svg" % key)
        b.texture_pressed = load("res://assets/ui/%s.svg" % key)
        b.ignore_texture_size = true
        b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
        b.custom_minimum_size = Vector2(button_size,button_size)
        b.size = Vector2(button_size,button_size)
        b.modulate = Color(1,1,1,button_opacity)
        b.mouse_filter = Control.MOUSE_FILTER_STOP
        _place_control(b,key)
        b.button_down.connect(_action_down.bind(key))
        b.button_up.connect(_action_up.bind(key))
        b.gui_input.connect(_button_gui_input.bind(key))
        root.add_child(b)
        control_buttons[key] = b
func _place_control(b: Control,key: String) -> void:
    var p: Vector2 = positions[key]
    if key in ["left","right"]:
        b.anchor_left = 0.0
        b.anchor_top = 1.0
    else:
        b.anchor_left = 1.0
        b.anchor_top = 1.0
    b.position = p
    b.custom_minimum_size = Vector2(button_size,button_size)
    b.size = Vector2(button_size,button_size)
func _action_down(key: String) -> void:
    if not move_mode and is_instance_valid(player_car) and player_car.drive_enabled:
        Input.action_press(actions[key])
func _action_up(key: String) -> void:
    Input.action_release(actions[key])
func _button_gui_input(event: InputEvent,key: String) -> void:
    if not move_mode:
        return
    if event is InputEventScreenDrag:
        positions[key] += event.relative
        _place_control(control_buttons[key],key)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        positions[key] += event.relative
        _place_control(control_buttons[key],key)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        _save_controls()
func _make_garage_menu() -> void:
    var shade = ColorRect.new()
    shade.name = "GarageShade"
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.015,0.025,0.04,0.72)
    root.add_child(shade)
    var title = Label.new()
    title.text = "JDM  /  HORIZON"
    title.position = Vector2(34,92)
    title.add_theme_font_size_override("font_size",34)
    title.add_theme_color_override("font_color",Color(0.96,0.97,1.0))
    shade.add_child(title)
    var subtitle = Label.new()
    subtitle.text = "OPEN WORLD  •  TOUGE  •  DRIFT"
    subtitle.position = Vector2(38,140)
    subtitle.add_theme_font_size_override("font_size",14)
    subtitle.add_theme_color_override("font_color",Color(0.78,0.83,0.9))
    shade.add_child(subtitle)
    var start = Button.new()
    start.text = "  START DRIVE  →  "
    start.position = Vector2(36,205)
    start.custom_minimum_size = Vector2(220,58)
    start.add_theme_font_size_override("font_size",19)
    start.pressed.connect(_start_drive.bind(shade))
    shade.add_child(start)
    var settings = Button.new()
    settings.text = "CONTROL SETTINGS"
    settings.position = Vector2(36,274)
    settings.custom_minimum_size = Vector2(220,48)
    settings.pressed.connect(_toggle_settings)
    shade.add_child(settings)
    var hint = Label.new()
    hint.text = "DRAG THE SCREEN TO ROTATE CAMERA"
    hint.position = Vector2(36,342)
    hint.add_theme_font_size_override("font_size",12)
    hint.add_theme_color_override("font_color",Color(0.82,0.86,0.92))
    shade.add_child(hint)
func _start_drive(shade: Control) -> void:
    shade.queue_free()
    if is_instance_valid(player_car):
        player_car.drive_enabled = true
func _toggle_settings() -> void:
    if is_instance_valid(settings_panel):
        settings_panel.queue_free()
        settings_panel = null
        return
    settings_panel = PanelContainer.new()
    settings_panel.position = Vector2(24,24)
    settings_panel.custom_minimum_size = Vector2(300,280)
    root.add_child(settings_panel)
    var box = VBoxContainer.new()
    box.add_theme_constant_override("separation",12)
    settings_panel.add_child(box)
    var heading = Label.new()
    heading.text = "CONTROL SETTINGS"
    heading.add_theme_font_size_override("font_size",18)
    box.add_child(heading)
    var opacity_label = Label.new()
    opacity_label.text = "Opacity: %d%%" % int(button_opacity*100)
    box.add_child(opacity_label)
    var opacity = HSlider.new()
    opacity.min_value = 0.25
    opacity.max_value = 1.0
    opacity.step = 0.05
    opacity.value = button_opacity
    opacity.value_changed.connect(func(v):
        button_opacity = v
        opacity_label.text = "Opacity: %d%%" % int(v*100)
        _apply_control_style()
    )
    box.add_child(opacity)
    var size_label = Label.new()
    size_label.text = "Button size: %d" % int(button_size)
    box.add_child(size_label)
    var size_slider = HSlider.new()
    size_slider.min_value = 58
    size_slider.max_value = 132
    size_slider.step = 2
    size_slider.value = button_size
    size_slider.value_changed.connect(func(v):
        button_size = v
        size_label.text = "Button size: %d" % int(v)
        _apply_control_style()
    )
    box.add_child(size_slider)
    var move = Button.new()
    move.text = "MOVE BUTTONS: OFF"
    move.pressed.connect(func():
        move_mode = not move_mode
        move.text = "MOVE BUTTONS: ON" if move_mode else "MOVE BUTTONS: OFF"
    )
    box.add_child(move)
    var reset = Button.new()
    reset.text = "RESET LAYOUT"
    reset.pressed.connect(_reset_controls)
    box.add_child(reset)
    var close = Button.new()
    close.text = "DONE"
    close.pressed.connect(func():
        _save_controls()
        settings_panel.queue_free()
        settings_panel = null
    )
    box.add_child(close)
func _apply_control_style() -> void:
    for key in control_buttons:
        var b: TextureButton = control_buttons[key]
        b.modulate = Color(1,1,1,button_opacity)
        _place_control(b,key)
func _reset_controls() -> void:
    positions = {"left":Vector2(28,-154),"right":Vector2(132,-154),"brake":Vector2(-230,-150),"gas":Vector2(-124,-150),"drift":Vector2(-178,-250)}
    _apply_control_style()
    _save_controls()
func _save_controls() -> void:
    config.set_value("controls","size",button_size)
    config.set_value("controls","opacity",button_opacity)
    for key in positions:
        config.set_value("positions",key,positions[key])
    config.save("user://jdm_controls.cfg")
