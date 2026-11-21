extends Node3D

const CAR_SCRIPT = preload("res://scripts/car.gd")
const HUD_SCRIPT = preload("res://scripts/hud.gd")

func _ready() -> void:
    _make_environment()
    _make_world()
    var car = CharacterBody3D.new()
    car.name = "PlayerCar"
    car.set_script(CAR_SCRIPT)
    add_child(car)
    car.position = Vector3(0, 0.7, 5)
    var hud = CanvasLayer.new()
    hud.set_script(HUD_SCRIPT)
    add_child(hud)

func _make_environment() -> void:
    var world_env = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.68, 0.75, 0.86)
    env.ambient_light_energy = 0.7
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env
    add_child(world_env)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    add_child(sun)

func _mat(color: Color, roughness := 0.9) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var mesh = BoxMesh.new()
    mesh.size = size
    var node = MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    parent.add_child(node)
    return node

func _make_world() -> void:
    var ground = StaticBody3D.new()
    ground.name = "Ground"
    add_child(ground)
    var floor_mesh = BoxMesh.new()
    floor_mesh.size = Vector3(260, 1, 260)
    var floor = MeshInstance3D.new()
    floor.mesh = floor_mesh
    floor.position.y = -0.55
    floor.material_override = _mat(Color(0.20, 0.34, 0.22))
    ground.add_child(floor)
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = floor_mesh.size
    col.shape = shape
    col.position.y = -0.55
    ground.add_child(col)

    var road = StaticBody3D.new()
    road.name = "TougeRoad"
    add_child(road)
    var road_mesh = BoxMesh.new()
    road_mesh.size = Vector3(13, 0.16, 180)
    var asphalt = MeshInstance3D.new()
    asphalt.mesh = road_mesh
    asphalt.position = Vector3(0, 0.02, -42)
    asphalt.material_override = _mat(Color(0.075, 0.085, 0.10), 0.98)
    road.add_child(asphalt)
    var road_col = CollisionShape3D.new()
    var road_shape = BoxShape3D.new()
    road_shape.size = road_mesh.size
    road_col.shape = road_shape
    road_col.position = asphalt.position
    road.add_child(road_col)

    for side in [-1, 1]:
        for z in range(-128, 48, 12):
            _box(self, Vector3(0.18, 0.025, 5), Vector3(side * 6.25, 0.12, z), Color(0.88, 0.86, 0.72))

    for i in range(22):
        var z = -120.0 + i * 8.0
        var side = -1 if i % 2 == 0 else 1
        _box(self, Vector3(20, randf_range(9, 22), 18),
            Vector3(side * randf_range(19, 28), randf_range(3, 8), z),
            Color(0.12, 0.27 + randf_range(0.0, 0.08), 0.18))
    for i in range(12):
        var z = -105 + i * 14
        var side = -1 if i % 2 == 0 else 1
        _box(self, Vector3(5, randf_range(4, 9), 5),
            Vector3(side * 13.5, 2.5, z), Color(0.43, 0.48, 0.52))
        _box(self, Vector3(5.1, 0.35, 5.1), Vector3(side * 13.5, 5.3, z), Color(0.18, 0.22, 0.28))

    for i in range(9):
        _box(self, Vector3(34, randf_range(25, 42), 32),
            Vector3(-105 + i * 27, 10, -145 - randf_range(0, 25)),
            Color(0.20, 0.29, 0.34))

    _box(self, Vector3(0.7, 5, 0.7), Vector3(-6, 2.5, 2), Color(0.75, 0.12, 0.12))
    _box(self, Vector3(0.7, 5, 0.7), Vector3(6, 2.5, 2), Color(0.75, 0.12, 0.12))
    _box(self, Vector3(13, 0.7, 0.7), Vector3(0, 5, 2), Color(0.88, 0.88, 0.84))
