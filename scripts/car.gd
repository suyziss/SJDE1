extends CharacterBody3D
@export var acceleration := 24.0
@export var max_speed := 42.0
@export var reverse_speed := 10.0
@export var steering_strength := 1.65
@export var grip := 5.5
@export var drift_grip := 1.35
var speed := 0.0
var yaw := 0.0
var drift_amount := 0.0
var drive_enabled := false
var car_visual: Node3D
var camera_pivot: Node3D
var camera: Camera3D
var wheel_nodes: Array[MeshInstance3D] = []
var camera_yaw := 0.0
var camera_pitch := -0.12
var _mouse_look := false
func _ready() -> void:
    _build_car()
    _build_camera()
func _input(event: InputEvent) -> void:
    var w = get_viewport().get_visible_rect().size.x
    if event is InputEventScreenDrag and event.position.x > w * 0.32:
        _rotate_camera(event.relative)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        _mouse_look = event.pressed and event.position.x > w * 0.32
    elif event is InputEventMouseMotion and _mouse_look:
        _rotate_camera(event.relative)
func _rotate_camera(relative: Vector2) -> void:
    camera_yaw -= relative.x * 0.006
    camera_pitch = clamp(camera_pitch - relative.y * 0.004, -0.62, 0.18)
func _material(color: Color, metallic := 0.0, roughness := 0.45) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    return m
func _add_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
    var mesh = BoxMesh.new()
    mesh.size = size
    var node = MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.material_override = _material(color, 0.45)
    parent.add_child(node)
func _build_car() -> void:
    car_visual = Node3D.new()
    add_child(car_visual)
    _add_box(car_visual, Vector3(1.9,0.48,4.1), Vector3(0,0.52,0), Color(0.78,0.08,0.10))
    _add_box(car_visual, Vector3(1.72,0.48,2.0), Vector3(0,0.98,-0.15), Color(0.78,0.08,0.10))
    _add_box(car_visual, Vector3(1.52,0.55,1.45), Vector3(0,1.18,-0.18), Color(0.10,0.17,0.22))
    _add_box(car_visual, Vector3(1.95,0.12,0.35), Vector3(0,0.55,-2.08), Color(0.12,0.12,0.13))
    _add_box(car_visual, Vector3(1.7,0.12,0.42), Vector3(0,0.95,-2.0), Color(0.10,0.10,0.11))
    for x in [-0.98,0.98]:
        for z in [-1.35,1.35]:
            var wheel = MeshInstance3D.new()
            var cylinder = CylinderMesh.new()
            cylinder.top_radius = 0.39
            cylinder.bottom_radius = 0.39
            cylinder.height = 0.24
            wheel.mesh = cylinder
            wheel.rotation_degrees.z = 90
            wheel.position = Vector3(x,0.38,z)
            wheel.material_override = _material(Color(0.035,0.035,0.04))
            car_visual.add_child(wheel)
            wheel_nodes.append(wheel)
    for x in [-0.62,0.62]:
        _add_box(car_visual, Vector3(0.38,0.16,0.08), Vector3(x,0.68,2.08), Color(1.0,0.86,0.62))
        _add_box(car_visual, Vector3(0.38,0.16,0.08), Vector3(x,0.68,-2.08), Color(0.85,0.02,0.02))
    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1.8,0.9,3.8)
    collision.shape = shape
    collision.position.y = 0.55
    add_child(collision)
func _build_camera() -> void:
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0,2.0,0)
    add_child(camera_pivot)
    camera = Camera3D.new()
    camera.position = Vector3(0,3.0,8.5)
    camera.rotation_degrees.x = -12
    camera.current = true
    camera.fov = 76
    camera_pivot.add_child(camera)
func _physics_process(delta: float) -> void:
    if not drive_enabled:
        speed = 0.0
        velocity = Vector3.ZERO
        _update_camera(delta)
        return
    var throttle = Input.get_action_strength("accelerate")
    var brake_input = Input.get_action_strength("brake")
    var steer = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
    var handbrake_input = Input.get_action_strength("handbrake") > 0.1
    if throttle > 0:
        speed = move_toward(speed,max_speed,acceleration*throttle*delta)
    elif brake_input > 0:
        if speed > 1.0:
            speed = move_toward(speed,0.0,acceleration*1.7*delta)
        else:
            speed = move_toward(speed,-reverse_speed,acceleration*0.55*delta)
    else:
        speed = move_toward(speed,0.0,3.0*delta)
    var speed_factor = clamp(abs(speed)/8.0,0.0,1.0)
    yaw += steer*steering_strength*speed_factor*delta*sign(speed if abs(speed)>0.1 else 1.0)
    rotation.y = yaw
    var forward = -global_transform.basis.z
    var target_velocity = forward*speed
    var grip_now = drift_grip if handbrake_input else grip
    var horizontal = Vector3(velocity.x,0,velocity.z)
    horizontal = horizontal.lerp(target_velocity,clamp(grip_now*delta,0.0,1.0))
    drift_amount = clamp(abs(steer)*speed_factor*(1.0 if handbrake_input else 0.28),0.0,1.0)
    velocity.x = horizontal.x
    velocity.z = horizontal.z
    velocity.y -= 22.0*delta
    if is_on_floor() and velocity.y < 0:
        velocity.y = -0.5
    move_and_slide()
    car_visual.rotation.z = lerp(car_visual.rotation.z,-steer*drift_amount*0.12,5.0*delta)
    car_visual.rotation.y = lerp_angle(car_visual.rotation.y,-steer*drift_amount*0.10,5.0*delta)
    for wheel in wheel_nodes:
        wheel.rotate_x(speed*delta/0.39)
    _update_camera(delta)
func _update_camera(delta: float) -> void:
    camera_pivot.global_position = camera_pivot.global_position.lerp(global_position+Vector3(0,1.8,0),6.0*delta)
    camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y,yaw+camera_yaw,8.0*delta)
    camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x,camera_pitch,8.0*delta)
