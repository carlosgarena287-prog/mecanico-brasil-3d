
extends Node
class_name VehicleManager

# MECANICO BRASIL 3D
# Gerenciamento de veiculos

var data_manager: DataManager

var active_vehicles: Dictionary = {}


func initialize(manager: DataManager) -> void:
    data_manager = manager
    print("Sistema de veiculos iniciado.")


func create_vehicle(vehicle_id: String) -> Dictionary:
    if data_manager == null:
        push_error("DataManager nao foi inicializado.")
        return {}

    var vehicle_data := data_manager.get_vehicle(vehicle_id)

    if vehicle_data.is_empty():
        push_error("Veiculo nao encontrado: " + vehicle_id)
        return {}

    var instance_id := str(
        Time.get_ticks_usec()
    )

    var vehicle_instance: Dictionary = {
        "instance_id": instance_id,
        "vehicle_id": vehicle_id,
        "name": vehicle_data.get("name", "Veiculo"),
        "model_year": vehicle_data.get("model_year", 0),
        "condition": 100.0,
        "parts_condition": {},
        "active_defects": [],
        "status": "available"
    }

    for part in data_manager.get_all_parts():
        var compatible_vehicles: Array = part.get(
            "compatible_vehicles",
            []
        )

        if vehicle_id in compatible_vehicles:
            vehicle_instance["parts_condition"][part["id"]] = 100.0

    active_vehicles[instance_id] = vehicle_instance

    print("Veiculo criado: ", vehicle_instance["name"])

    return vehicle_instance.duplicate(true)


func get_vehicle_instance(instance_id: String) -> Dictionary:
    if not active_vehicles.has(instance_id):
        return {}

    return active_vehicles[instance_id].duplicate(true)


func set_part_condition(
    instance_id: String,
    part_id: String,
    condition: float
) -> bool:

    if not active_vehicles.has(instance_id):
        return false

    var vehicle: Dictionary = active_vehicles[instance_id]
    var parts: Dictionary = vehicle["parts_condition"]

    if not parts.has(part_id):
        return false

    parts[part_id] = clampf(condition, 0.0, 100.0)

    return true


func get_part_condition(
    instance_id: String,
    part_id: String
) -> float:

    if not active_vehicles.has(instance_id):
        return -1.0

    var parts: Dictionary = active_vehicles[instance_id]["parts_condition"]

    return float(parts.get(part_id, -1.0))


func remove_vehicle(instance_id: String) -> bool:
    if not active_vehicles.has(instance_id):
        return false

    active_vehicles.erase(instance_id)

    return true


func get_all_active_vehicles() -> Array:
    return active_vehicles.values()
