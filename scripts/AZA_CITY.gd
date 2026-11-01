
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
    var rock = material(Color(0.30, 0.35, 0.39))
    var snow = material(Color(0.87, 0.90, 0.93))

    rock.cull_mode = BaseMaterial3D.CULL_DISABLED
    snow.cull_mode = BaseMaterial3D.CULL_DISABLED

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
        mountain.mesh = build_mountain_mesh_v3(
            p.y, p.z, p.w, i, false
        )
        mountain.material_override = rock
        mountain.position = Vector3(p.x, 0, -190)
        add_child(mountain)

        var snowcap = MeshInstance3D.new()
        snowcap.name = "Snow_" + str(i)
        snowcap.mesh = build_mountain_mesh_v3(
            p.y, p.z, p.w, i, true
        )
        snowcap.material_override = snow
        snowcap.position = Vector3(p.x, 0, -190)
        add_child(snowcap)


func build_mountain_mesh_v3(
    height: float,
    radius_x: float,
    radius_z: float,
    seed: int,
    snow_only: bool
) -> ArrayMesh:

    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    var start_ring = 1 if snow_only else 0
    var segments = 8

    for segment in range(segments):
        var nxt = (segment + 1) % segments

        var a = mountain_vertex_v3(
            height, radius_x, radius_z,
            seed, start_ring, segment
        )
        var b = mountain_vertex_v3(
            height, radius_x, radius_z,
            seed, start_ring, nxt
        )
        var c = mountain_vertex_v3(
            height, radius_x, radius_z,
            seed, start_ring + 1, segment
        )
        var d = mountain_vertex_v3(
            height, radius_x, radius_z,
            seed, start_ring + 1, nxt
        )

        st.add_vertex(a)
        st.add_vertex(c)
        st.add_vertex(b)

        st.add_vertex(b)
        st.add_vertex(c)
        st.add_vertex(d)

        if snow_only:
            var apex = Vector3(
                sin(float(seed)) * radius_x * 0.05,
                height,
                cos(float(seed)) * radius_z * 0.05
            )

            st.add_vertex(c)
            st.add_vertex(apex)
            st.add_vertex(d)

    st.generate_normals()
    return st.commit()


func mountain_vertex_v3(
    height: float,
    radius_x: float,
    radius_z: float,
    seed: int,
    ring: int,
    segment: int
) -> Vector3:

    var angle = TAU * float(segment) / 8.0
    angle += float(seed) * 0.13

    var scales = [1.0, 0.58, 0.28]
    var levels = [0.0, 0.48, 0.82]

    var variation = 1.0 \
        + 0.16 * sin(angle * 3.0 + float(seed)) \
        + 0.08 * cos(angle * 5.0 + float(seed))

    var radius = scales[ring] * variation
    var y = height * levels[ring]

    y += height * 0.035 * sin(
        angle * 4.0 + float(seed)
    )

    return Vector3(
        cos(angle) * radius_x * radius,
        y,
        sin(angle) * radius_z * radius
    )


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
