
extends Node
class_name RepairManager

# MECANICO BRASIL 3D
# Sistema central de reparos

var data_manager: DataManager
var vehicle_manager: VehicleManager
var defect_manager: DefectManager
var inventory_manager: InventoryManager
var game_manager: Node


func initialize(
    data: DataManager,
    vehicles: VehicleManager,
    defects: DefectManager,
    inventory: InventoryManager,
    economy: Node
) -> void:

    data_manager = data
    vehicle_manager = vehicles
    defect_manager = defects
    inventory_manager = inventory
    game_manager = economy

    print("Sistema de reparos iniciado.")


func repair_defect(
    instance_id: String,
    defect_id: String
) -> Dictionary:

    if data_manager == null:
        return {"success": false, "message": "Sistema nao inicializado."}

    var vehicle := vehicle_manager.get_vehicle_instance(instance_id)

    if vehicle.is_empty():
        return {"success": false, "message": "Veiculo nao encontrado."}

    var defect := data_manager.get_defect(defect_id)

    if defect.is_empty():
        return {"success": false, "message": "Defeito nao encontrado."}

    var current_defects := defect_manager.get_vehicle_defects(instance_id)

    if not defect_id in current_defects:
        return {"success": false, "message": "Esse veiculo nao possui esse defeito."}

    # Encontrar o servico correspondente
    var selected_service: Dictionary = {}

    for service in data_manager.get_all_services():
        var related_defects: Array = service.get("related_defects", [])

        if defect_id in related_defects:
            selected_service = service
            break

    if selected_service.is_empty():
        return {"success": false, "message": "Servico de reparo nao cadastrado."}

    var required_parts: Array = selected_service.get("required_parts", [])

    # Verificar todas as pecas antes de consumir o estoque
    for part_id in required_parts:
        if not inventory_manager.has_part(part_id, 1):
            return {
                "success": false,
                "message": "Estoque insuficiente: " + str(part_id)
            }

    # Consumir as pecas necessarias
    for part_id in required_parts:
        inventory_manager.consume_part(part_id, 1)

    # Restaurar a condicao da peca afetada
    var affected_part: String = defect.get("affected_part", "")

    vehicle_manager.set_part_condition(
        instance_id,
        affected_part,
        100.0
    )

    # Remover o defeito do veiculo
    defect_manager.remove_defect(instance_id, defect_id)

    # Receber pagamento da mao de obra
    var labor_payment := float(
        selected_service.get("labor_price", 0.0)
    )

    game_manager.add_money(labor_payment)

    print("Reparo concluido: ", selected_service.get("name", ""))

    return {
        "success": true,
        "message": "Reparo concluido!",
        "service": selected_service.get("name", ""),
        "payment": labor_payment
    }


func can_repair(
    instance_id: String,
    defect_id: String
) -> bool:

    var vehicle := vehicle_manager.get_vehicle_instance(instance_id)

    if vehicle.is_empty():
        return false

    if not defect_id in defect_manager.get_vehicle_defects(instance_id):
        return false

    var defect := data_manager.get_defect(defect_id)

    if defect.is_empty():
        return false

    for service in data_manager.get_all_services():
        if defect_id in service.get("related_defects", []):
            for part_id in service.get("required_parts", []):
                if not inventory_manager.has_part(part_id, 1):
                    return false

            return true

    return false
