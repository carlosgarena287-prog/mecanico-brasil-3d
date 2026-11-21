
extends Node
class_name DefectManager

# MECANICO BRASIL 3D
# Sistema de defeitos e diagnostico

var data_manager: DataManager
var vehicle_manager: VehicleManager

# Defeitos registrados por veiculo
var vehicle_defects: Dictionary = {}


func initialize(
    data: DataManager,
    vehicles: VehicleManager
) -> void:
    data_manager = data
    vehicle_manager = vehicles

    print("Sistema de diagnostico iniciado.")


func apply_defect(
    instance_id: String,
    defect_id: String
) -> bool:

    if data_manager == null or vehicle_manager == null:
        push_error("Sistema de defeitos nao inicializado.")
        return false

    var vehicle := vehicle_manager.get_vehicle_instance(instance_id)

    if vehicle.is_empty():
        return false

    var defect := data_manager.get_defect(defect_id)

    if defect.is_empty():
        push_error("Defeito nao encontrado: " + defect_id)
        return false

    var part_id: String = defect.get("affected_part", "")
    var part := data_manager.get_part(part_id)

    if part.is_empty():
        return false

    var compatible: Array = part.get("compatible_vehicles", [])

    if not vehicle["vehicle_id"] in compatible:
        return false

    if not vehicle_defects.has(instance_id):
        vehicle_defects[instance_id] = []

    if defect_id in vehicle_defects[instance_id]:
        return false

    vehicle_defects[instance_id].append(defect_id)

    # Reduz a condicao da peca afetada
    vehicle_manager.set_part_condition(
        instance_id,
        part_id,
        20.0
    )

    print("Defeito aplicado: ", defect.get("name", defect_id))

    return true


func get_vehicle_symptoms(instance_id: String) -> Array:
    var symptoms: Array = []

    if not vehicle_defects.has(instance_id):
        return symptoms

    for defect_id in vehicle_defects[instance_id]:
        var defect := data_manager.get_defect(defect_id)

        for symptom in defect.get("symptoms", []):
            if not symptom in symptoms:
                symptoms.append(symptom)

    return symptoms


func diagnose_defect(
    instance_id: String,
    defect_id: String
) -> Dictionary:

    if not vehicle_defects.has(instance_id):
        return {}

    if not defect_id in vehicle_defects[instance_id]:
        return {}

    return data_manager.get_defect(defect_id).duplicate(true)


func get_vehicle_defects(instance_id: String) -> Array:
    if not vehicle_defects.has(instance_id):
        return []

    return vehicle_defects[instance_id].duplicate()


func remove_defect(
    instance_id: String,
    defect_id: String
) -> bool:

    if not vehicle_defects.has(instance_id):
        return false

    var defects: Array = vehicle_defects[instance_id]

    if not defect_id in defects:
        return false

    defects.erase(defect_id)

    return true
