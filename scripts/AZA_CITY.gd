
extends Node3D

const CITY_SIZE := 240.0

func _ready():
    create_environment()
    create_ground()
    create_roads()
    create_buildings()
    create_mountains()
    create_city_plaza()

func material(color: Color) -> StandardMaterial3D:
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.85
    return mat

func add_box(pos: Vector3, size: Vector3, color: Color, label: String):
    var obj = MeshInstance3D.new()
    obj.name = label
    var mesh = BoxMesh.new()
    mesh.size = size
    obj.mesh = mesh
    obj.position = pos
    obj.material_override = material(color)
    add_child(obj)
    return obj

func create_environment():
    var world = get_node_or_null("WorldEnvironment")
    if world == null:
        world = WorldEnvironment.new()
        world.name = "WorldEnvironment"
        add_child(world)

    var env = Environment.new()
    env.background_mode = Environment.BG_SKY

    var sky = Sky.new()
    var sky_mat = ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.16, 0.35, 0.65)
    sky_mat.sky_horizon_color = Color(0.75, 0.83, 0.91)
    sky.sky_material = sky_mat

    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_energy = 0.7
    world.environment = env

func create_ground():
    var ground = get_node("CityGround")
    var mesh = PlaneMesh.new()
    mesh.size = Vector2(CITY_SIZE, CITY_SIZE)
    ground.mesh = mesh
    ground.material_override = material(Color(0.27, 0.37, 0.24))

func create_roads():
    var asphalt = Color(0.10, 0.12, 0.14)
    var concrete = Color(0.55, 0.56, 0.53)
    var white = Color(0.92, 0.88, 0.68)

    add_box(Vector3(0, 0.03, 0),
        Vector3(240, 0.12, 14), asphalt, "Main_Road_X")

    add_box(Vector3(0, 0.04, 0),
        Vector3(14, 0.13, 240), asphalt, "Main_Road_Z")

    add_box(Vector3(0, 0.12, -9),
        Vector3(240, 0.2, 3), concrete, "North_Sidewalk")

    add_box(Vector3(0, 0.12, 9),
        Vector3(240, 0.2, 3), concrete, "South_Sidewalk")

    for i in range(-9, 10):
        var p = float(i) * 12.0
        add_box(Vector3(p, 0.12, 0),
            Vector3(5, 0.025, 0.2), white, "Road_Line_X_" + str(i))

        add_box(Vector3(0, 0.13, p),
            Vector3(0.2, 0.025, 5), white, "Road_Line_Z_" + str(i))

func create_buildings():
    var colors = [
        Color(0.65, 0.67, 0.68),
        Color(0.72, 0.59, 0.46),
        Color(0.35, 0.45, 0.52),
        Color(0.78, 0.75, 0.66)
    ]

    var positions = [
        Vector3(-42, 0, -42),
        Vector3(42, 0, -42),
        Vector3(-42, 0, 42),
        Vector3(42, 0, 42),
        Vector3(-85, 0, -30),
        Vector3(85, 0, 30),
        Vector3(-30, 0, 85),
        Vector3(30, 0, -85)
    ]

    for i in range(positions.size()):
        var height = 18.0 + float((i * 11) % 25)
        var width = 18.0

        add_box(
            positions[i] + Vector3(0, height / 2, 0),
            Vector3(width, height, 18),
            colors[i % colors.size()],
            "AZA_Building_" + str(i + 1)
        )

        add_box(
            positions[i] + Vector3(0, height + 0.5, 0),
            Vector3(width + 1, 1, 19),
            Color(0.18, 0.20, 0.22),
            "Building_Roof_" + str(i + 1)
        )


func create_mountains():
    var rock = material(Color(0.32, 0.39, 0.42))
    var snow = material(Color(0.83, 0.87, 0.90))

    var peaks = [
        Vector4(-190, 76, 45, 32),
        Vector4(-145, 92, 52, 38),
        Vector4(-95, 65, 40, 30),
        Vector4(-45, 100, 55, 42),
        Vector4(10, 72, 43, 32),
        Vector4(65, 94, 50, 40),
        Vector4(120, 70, 43, 32),
        Vector4(175, 88, 50, 38)
    ]

    for i in range(peaks.size()):
        var p: Vector4 = peaks[i]

        var mountain = MeshInstance3D.new()
        mountain.name = "Mountain_" + str(i)

        var mesh = SphereMesh.new()
        mesh.radius = 1.0
        mesh.height = 2.0
        mesh.radial_segments = 24
        mesh.rings = 12

        mountain.mesh = mesh
        mountain.scale = Vector3(p.z, p.y / 2.0, p.w)
        mountain.position = Vector3(p.x, p.y / 2.0, -190)
        mountain.material_override = rock
        add_child(mountain)

        var snowcap = MeshInstance3D.new()
        snowcap.name = "Snow_" + str(i)

        var cap_mesh = SphereMesh.new()
        cap_mesh.radial_segments = 16
        cap_mesh.rings = 8

        snowcap.mesh = cap_mesh
        snowcap.scale = Vector3(p.z * 0.25, p.y * 0.12, p.w * 0.25)
        snowcap.position = Vector3(p.x, p.y * 0.83, -190)
        snowcap.material_override = snow
        add_child(snowcap)


func create_city_plaza():
    add_box(
        Vector3(0, 0.15, 35),
        Vector3(30, 0.3, 25),
        Color(0.65, 0.62, 0.54),
        "AZA_Central_Plaza"
    )

    add_box(
        Vector3(0, 8, 68),
        Vector3(32, 16, 20),
        Color(0.78, 0.73, 0.63),
        "AZA_City_Hall"
    )
