
extends Node3D
class_name VehicleModelBuilder


func build_vehicle(
    vehicle_id: String,
    parent: Node3D,
    spawn_position: Vector3
) -> Node3D:

    var vehicle := Node3D.new()
    vehicle.name = vehicle_id
    vehicle.position = spawn_position

    parent.add_child(vehicle)

    var body_color := Color(0.75, 0.08, 0.06)
    var body_length := 3.8
    var body_width := 1.7
    var cabin_length := 1.8
    var cabin_height := 0.85

    match vehicle_id:
        "chevrolet_celta_2013":
            body_color = Color(0.78, 0.08, 0.06)
            body_length = 3.7
            body_width = 1.65
            cabin_length = 1.8
            cabin_height = 0.8

        "fiat_uno_2012":
            body_color = Color(0.08, 0.22, 0.75)
            body_length = 3.6
            body_width = 1.68
            cabin_length = 1.65
            cabin_height = 1.0

        "volkswagen_gol_2012":
            body_color = Color(0.82, 0.82, 0.78)
            body_length = 3.9
            body_width = 1.72
            cabin_length = 1.9
            cabin_height = 0.85

        "volkswagen_jetta_2013":
            body_color = Color(0.12, 0.13, 0.16)
            body_length = 4.6
            body_width = 1.8
            cabin_length = 2.0
            cabin_height = 0.8

    _build_body(
        vehicle,
        body_color,
        body_length,
        body_width,
        cabin_length,
        cabin_height,
        vehicle_id
    )

    _build_wheels(vehicle, body_length, body_width)
    _build_glass(vehicle, body_length, cabin_length, cabin_height)
    _build_lights(vehicle, body_width, body_length)
    _build_details(vehicle, body_width, body_length)

    return vehicle


func _mat(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metallic
    material.roughness = 0.38
    return material


func _box(
    parent: Node3D,
    object_name: String,
    size: Vector3,
    position: Vector3,
    material: Material
) -> MeshInstance3D:

    var object := MeshInstance3D.new()
    object.name = object_name

    var mesh := BoxMesh.new()
    mesh.size = size

    object.mesh = mesh
    object.position = position
    object.material_override = material

    parent.add_child(object)
    return object


func _build_body(
    car: Node3D,
    color: Color,
    length: float,
    width: float,
    cabin_length: float,
    cabin_height: float,
    vehicle_id: String
) -> void:

    var paint := _mat(color, 0.45)
    var dark := _mat(Color(0.07, 0.08, 0.10), 0.2)
    var bumper := _mat(Color(0.12, 0.13, 0.15), 0.25)

    # Parte principal da carroceria
    _box(
        car,
        "Carroceria",
        Vector3(width, 0.65, length),
        Vector3(0, 0.75, 0),
        paint
    )

    # Capo dianteiro
    _box(
        car,
        "Capo",
        Vector3(width * 0.94, 0.16, length * 0.27),
        Vector3(0, 1.12, length * 0.32),
        paint
    )

    # Porta-malas ou traseira
    _box(
        car,
        "Parte traseira",
        Vector3(width * 0.94, 0.16, length * 0.23),
        Vector3(0, 1.12, -length * 0.35),
        paint
    )

    # Cabine
    var cabin_width := width * 0.82

    _box(
        car,
        "Cabine",
        Vector3(cabin_width, cabin_height, cabin_length),
        Vector3(0, 1.55, -0.05),
        paint
    )

    # Teto
    _box(
        car,
        "Teto",
        Vector3(cabin_width * 0.96, 0.12, cabin_length * 0.9),
        Vector3(0, 2.08, -0.05),
        paint
    )

    # Para-choques
    _box(
        car,
        "Parachoque dianteiro",
        Vector3(width * 1.02, 0.22, 0.16),
        Vector3(0, 0.65, length * 0.51),
        bumper
    )

    _box(
        car,
        "Parachoque traseiro",
        Vector3(width * 1.02, 0.22, 0.16),
        Vector3(0, 0.65, -length * 0.51),
        bumper
    )

    # Grade dianteira
    _box(
        car,
        "Grade frontal",
        Vector3(width * 0.35, 0.2, 0.06),
        Vector3(0, 0.87, length * 0.52),
        dark
    )


func _build_wheels(
    car: Node3D,
    length: float,
    width: float
) -> void:

    var tire_mat := _mat(Color(0.025, 0.025, 0.03))
    var rim_mat := _mat(Color(0.65, 0.68, 0.72), 0.8)

    for side in [-1.0, 1.0]:
        for axle in [-1.0, 1.0]:

            var wheel := MeshInstance3D.new()
            wheel.name = "Pneu"

            var tire := CylinderMesh.new()
            tire.top_radius = 0.36
            tire.bottom_radius = 0.36
            tire.height = 0.22
            tire.radial_segments = 24

            wheel.mesh = tire
            wheel.material_override = tire_mat
            wheel.position = Vector3(
                side * (width * 0.5),
                0.43,
                axle * (length * 0.32)
            )
            wheel.rotation_degrees.z = 90

            car.add_child(wheel)

            var rim := MeshInstance3D.new()
            rim.name = "Roda metalica"

            var rim_mesh := CylinderMesh.new()
            rim_mesh.top_radius = 0.20
            rim_mesh.bottom_radius = 0.20
            rim_mesh.height = 0.235
            rim_mesh.radial_segments = 20

            rim.mesh = rim_mesh
            rim.material_override = rim_mat
            rim.position = wheel.position
            rim.rotation_degrees.z = 90

            car.add_child(rim)


func _build_glass(
    car: Node3D,
    length: float,
    cabin_length: float,
    cabin_height: float
) -> void:

    var glass := _mat(Color(0.12, 0.22, 0.30), 0.25)

    # Para-brisa dianteiro
    _box(
        car,
        "Parabrisa dianteiro",
        Vector3(1.25, 0.55, 0.045),
        Vector3(0, 1.72, cabin_length * 0.42),
        glass
    )

    # Vidro traseiro
    _box(
        car,
        "Vidro traseiro",
        Vector3(1.25, 0.48, 0.045),
        Vector3(0, 1.72, -cabin_length * 0.42),
        glass
    )

    # Janelas laterais
    for side in [-1.0, 1.0]:
        _box(
            car,
            "Janela lateral",
            Vector3(0.045, 0.48, cabin_length * 0.72),
            Vector3(side * 0.72, 1.72, -0.05),
            glass
        )


func _build_lights(
    car: Node3D,
    width: float,
    length: float
) -> void:

    var headlight := _mat(Color(1.0, 0.94, 0.72), 0.15)
    var tail_light := _mat(Color(0.85, 0.025, 0.015))
    var orange := _mat(Color(1.0, 0.35, 0.02))

    for side in [-1.0, 1.0]:
        _box(
            car,
            "Farol",
            Vector3(0.38, 0.17, 0.06),
            Vector3(side * width * 0.35, 0.95, length * 0.52),
            headlight
        )

        _box(
            car,
            "Lanterna traseira",
            Vector3(0.32, 0.22, 0.06),
            Vector3(side * width * 0.36, 0.95, -length * 0.52),
            tail_light
        )

        _box(
            car,
            "Seta",
            Vector3(0.12, 0.12, 0.065),
            Vector3(side * width * 0.44, 0.95, length * 0.52),
            orange
        )


func _build_details(
    car: Node3D,
    width: float,
    length: float
) -> void:

    var black := _mat(Color(0.06, 0.06, 0.07))
    var chrome := _mat(Color(0.7, 0.72, 0.75), 0.8)

    # Espelhos
    for side in [-1.0, 1.0]:
        _box(
            car,
            "Retrovisor",
            Vector3(0.18, 0.14, 0.22),
            Vector3(side * width * 0.55, 1.35, 0.55),
            black
        )

    # Friso lateral
    for side in [-1.0, 1.0]:
        _box(
            car,
            "Friso lateral",
            Vector3(0.035, 0.07, length * 0.45),
            Vector3(side * width * 0.51, 0.85, 0),
            chrome
        )
