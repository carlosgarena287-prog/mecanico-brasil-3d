
extends Node3D
class_name WorkshopBuilder

# MECANICO BRASIL 3D
# Construcao do ambiente 3D da oficina


func build_workshop(parent: Node3D) -> void:
    _build_floor(parent)
    _build_walls(parent)
    _build_lighting(parent)
    _build_lifts(parent)
    _build_workbenches(parent)
    _build_details(parent)
    _build_camera(parent)

    print("Oficina 3D construida!")


func _material(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = 0.75
    return mat


func _box(
    parent: Node3D,
    object_name: String,
    size: Vector3,
    position: Vector3,
    mat: Material
) -> MeshInstance3D:

    var object := MeshInstance3D.new()
    object.name = object_name

    var mesh := BoxMesh.new()
    mesh.size = size

    object.mesh = mesh
    object.position = position
    object.material_override = mat
    object.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

    parent.add_child(object)
    return object


func _build_floor(parent: Node3D) -> void:
    var floor_mat := _material(Color(0.22, 0.24, 0.26))
    var line_mat := _material(Color(0.95, 0.72, 0.08))

    _box(
        parent,
        "Piso da oficina",
        Vector3(22, 0.3, 18),
        Vector3(0, -0.15, 0),
        floor_mat
    )

    # Faixas de demarcacao das vagas
    for x in [-8.0, -1.0, 1.0, 8.0]:
        _box(
            parent,
            "Faixa de vaga",
            Vector3(0.08, 0.025, 12),
            Vector3(x, 0.015, 0),
            line_mat
        )


func _build_walls(parent: Node3D) -> void:
    var wall_mat := _material(Color(0.68, 0.70, 0.72))
    var dark_mat := _material(Color(0.12, 0.14, 0.17))

    # Parede do fundo
    _box(
        parent,
        "Parede do fundo",
        Vector3(22, 6, 0.35),
        Vector3(0, 3, -9),
        wall_mat
    )

    # Paredes laterais
    _box(
        parent,
        "Parede esquerda",
        Vector3(0.35, 6, 18),
        Vector3(-11, 3, 0),
        wall_mat
    )

    _box(
        parent,
        "Parede direita",
        Vector3(0.35, 6, 18),
        Vector3(11, 3, 0),
        wall_mat
    )

    # Faixa escura na base das paredes
    _box(
        parent,
        "Rodape esquerdo",
        Vector3(0.38, 0.45, 18),
        Vector3(-10.8, 0.25, 0),
        dark_mat
    )

    _box(
        parent,
        "Rodape direito",
        Vector3(0.38, 0.45, 18),
        Vector3(10.8, 0.25, 0),
        dark_mat
    )


func _build_lighting(parent: Node3D) -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()

    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.12, 0.15, 0.19)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.65, 0.68, 0.75)
    environment.ambient_light_energy = 0.65

    world.environment = environment
    parent.add_child(world)

    var sun := DirectionalLight3D.new()
    sun.name = "Luz principal"
    sun.rotation_degrees = Vector3(-48, -35, 0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    parent.add_child(sun)

    for x in [-6.0, 0.0, 6.0]:
        var lamp := OmniLight3D.new()
        lamp.name = "Iluminacao industrial"
        lamp.position = Vector3(x, 5.2, -1)
        lamp.light_color = Color(0.82, 0.90, 1.0)
        lamp.light_energy = 1.5
        lamp.omni_range = 10.0
        parent.add_child(lamp)


func _build_lifts(parent: Node3D) -> void:
    var metal := _material(Color(0.12, 0.25, 0.75), 0.65)
    var black := _material(Color(0.08, 0.09, 0.11), 0.3)
    var yellow := _material(Color(0.95, 0.65, 0.04))

    # Dois elevadores, um em cada vaga
    for bay_x in [-5.0, 5.0]:
        for side_x in [-1.7, 1.7]:
            var post_x := bay_x + side_x

            _box(
                parent,
                "Coluna do elevador",
                Vector3(0.28, 3.8, 0.35),
                Vector3(post_x, 1.9, 0),
                metal
            )

            _box(
                parent,
                "Base do elevador",
                Vector3(0.85, 0.12, 0.85),
                Vector3(post_x, 0.08, 0),
                black
            )

            _box(
                parent,
                "Braco do elevador",
                Vector3(1.5, 0.12, 0.22),
                Vector3(bay_x, 0.9, 0),
                yellow
            )

        _box(
            parent,
            "Trava superior do elevador",
            Vector3(3.7, 0.16, 0.25),
            Vector3(bay_x, 3.55, 0),
            black
        )


func _build_workbenches(parent: Node3D) -> void:
    var wood := _material(Color(0.35, 0.22, 0.13))
    var metal := _material(Color(0.18, 0.20, 0.23), 0.5)
    var red := _material(Color(0.65, 0.08, 0.06))

    # Bancada no fundo
    _box(
        parent,
        "Bancada principal",
        Vector3(7, 0.18, 1.0),
        Vector3(0, 1.0, -7.8),
        wood
    )

    for x in [-3.0, 3.0]:
        _box(
            parent,
            "Armario da bancada",
            Vector3(0.35, 1.0, 0.8),
            Vector3(x, 0.5, -7.8),
            metal
        )

    # Armario de ferramentas
    _box(
        parent,
        "Armario de ferramentas",
        Vector3(2.0, 2.3, 0.7),
        Vector3(-8.8, 1.15, -5.0),
        red
    )


func _build_details(parent: Node3D) -> void:
    var dark := _material(Color(0.08, 0.09, 0.11))
    var yellow := _material(Color(0.95, 0.68, 0.05))
    var gray := _material(Color(0.35, 0.38, 0.42))

    # Portao visual na entrada
    _box(
        parent,
        "Trilho superior do portao",
        Vector3(8, 0.18, 0.2),
        Vector3(0, 5.5, 8.8),
        dark
    )

    # Painel de identificacao
    _box(
        parent,
        "Painel da oficina",
        Vector3(5, 0.8, 0.12),
        Vector3(0, 4.8, -8.78),
        dark
    )

    # Caixas de ferramentas
    for x in [-8.0, 8.0]:
        _box(
            parent,
            "Caixa de ferramentas",
            Vector3(1.0, 0.8, 0.7),
            Vector3(x, 0.4, 4.5),
            yellow
        )

    # Colunas de sustentacao decorativas
    for x in [-10.5, 10.5]:
        _box(
            parent,
            "Coluna estrutural",
            Vector3(0.35, 5.5, 0.35),
            Vector3(x, 2.75, 7.5),
            gray
        )


func _build_camera(parent: Node3D) -> void:
    var camera := Camera3D.new()
    camera.name = "Camera da oficina"
    camera.position = Vector3(0, 10, 19)
    camera.rotation_degrees = Vector3(-22, 0, 0)
    camera.fov = 60
    camera.current = true

    parent.add_child(camera)
