extends Node3D
const CAR_SCRIPT = preload("res://scripts/car.gd")
const HUD_SCRIPT = preload("res://scripts/hud.gd")
func _ready() -> void:
    _make_environment()
    _make_world()
    _make_garage()
    var car = CharacterBody3D.new()
    car.name = "PlayerCar"
    car.set_script(CAR_SCRIPT)
    add_child(car)
    car.position = Vector3(0,0.7,10)
    var hud = CanvasLayer.new()
    hud.set_script(HUD_SCRIPT)
    hud.player_car = car
    add_child(hud)
func _make_environment() -> void:
    var world_env = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.68,0.75,0.86)
    env.ambient_light_energy = 0.7
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env
    add_child(world_env)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48,-32,0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    add_child(sun)
func _mat(color: Color,roughness := 0.9) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m
func _box(parent: Node3D,size: Vector3,pos: Vector3,color: Color) -> MeshInstance3D:
    var mesh = BoxMesh.new()
    mesh.size = size
    var node = MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    parent.add_child(node)
    return node
func _make_road(size: Vector3,pos: Vector3) -> void:
    var road = StaticBody3D.new()
    road.name = "Road"
    add_child(road)
    var mesh = BoxMesh.new()
    mesh.size = size
    var asphalt = MeshInstance3D.new()
    asphalt.mesh = mesh
    asphalt.position = pos
    asphalt.material_override = _mat(Color(0.075,0.085,0.10),0.98)
    road.add_child(asphalt)
    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    collision.position = pos
    road.add_child(collision)
func _make_garage() -> void:
    _box(self,Vector3(38,0.3,30),Vector3(0,-0.2,12),Color(0.11,0.13,0.16))
    for x in [-17.0,17.0]:
        _box(self,Vector3(0.45,8,0.45),Vector3(x,4,-1),Color(0.18,0.20,0.24))
    _box(self,Vector3(36,0.5,0.5),Vector3(0,8,-1),Color(0.25,0.28,0.32))
    _box(self,Vector3(0.35,6,0.35),Vector3(-17,3,20),Color(0.18,0.20,0.24))
    _box(self,Vector3(0.35,6,0.35),Vector3(17,3,20),Color(0.18,0.20,0.24))
    for i in range(8):
        _box(self,Vector3(0.12,0.02,18),Vector3(-14+i*4,0.0,12),Color(0.32,0.35,0.4))
func _make_world() -> void:
    var ground = StaticBody3D.new()
    ground.name = "OpenWorldGround"
    add_child(ground)
    var floor_mesh = BoxMesh.new()
    floor_mesh.size = Vector3(1400,1,1400)
    var floor = MeshInstance3D.new()
    floor.mesh = floor_mesh
    floor.position.y = -0.55
    floor.material_override = _mat(Color(0.20,0.34,0.22))
    ground.add_child(floor)
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = floor_mesh.size
    col.shape = shape
    col.position.y = -0.55
    ground.add_child(col)
    _make_road(Vector3(15,0.16,1050),Vector3(0,0.02,-430))
    _make_road(Vector3(720,0.16,15),Vector3(0,0.02,-260))
    _make_road(Vector3(13,0.16,620),Vector3(230,0.025,-120))
    _make_road(Vector3(520,0.16,13),Vector3(-210,0.025,180))
    for side in [-1,1]:
        for z in range(-950,110,18):
            _box(self,Vector3(0.18,0.025,7),Vector3(side*7.25,0.12,z),Color(0.88,0.86,0.72))
    for i in range(70):
        var z = -930.0+i*13.0
        var side = -1 if i%2==0 else 1
        var spread = randf_range(45.0,115.0)
        _box(self,Vector3(randf_range(14,34),randf_range(12,38),randf_range(14,34)),Vector3(side*spread,randf_range(5,16),z),Color(0.12,0.25+randf_range(0.0,0.10),0.17))
    for i in range(45):
        var x = randf_range(-620.0,620.0)
        var z = randf_range(-620.0,620.0)
        if abs(x)<35.0 or abs(z+260.0)<35.0:
            continue
        var h = randf_range(4.0,12.0)
        _box(self,Vector3(randf_range(4,10),h,randf_range(4,10)),Vector3(x,h*0.5,z),Color(0.32,0.36,0.38))
