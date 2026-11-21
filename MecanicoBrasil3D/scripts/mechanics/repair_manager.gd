
extends Node
class_name RepairManager

# MECANICO BRASIL 3D
# Sistema de reparos

var data_manager: DataManager
var vehicle_manager: VehicleManager
var defect_manager: DefectManager
var inventory_manager: InventoryManager
var game_manager: GameManager


func initialize(
    data: DataManager,
    vehicles: VehicleManager,
    defects: DefectManager,
    inventory: InventoryManager,
    game: GameManager
) -> void:

    data_manager = data
    vehicle_manager = vehicles
    defect_manager = defects
    inventory_manager = inventory
    game_manager = game

    print("Sistema de reparos iniciado.")


func repair_defect(
    instance_id: String,
    defect_id: String
) -> Dictionary:

    if data_manager == null or vehicle_manager == null:
        return {"success": false, "message": "Sistema nao inicializado."}

    if defect_manager == null or inventory_manager == null:
        return {"success": false, "message": "Sistemas de reparo ausentes."}

    if game_manager == null:
        return {"success": false, "message": "Sistema financeiro ausente."}

    var vehicle := vehicle_manager.get_vehicle_instance(instance_id)

    if vehicle.is_empty():
        return {"success": false, "message": "Veiculo nao encontrado."}

    var defect := defect_manager.diagnose_defect(
        instance_id,
        defect_id
    )

    if defect.is_empty():
        return {"success": false, "message": "Defeito nao diagnosticado."}

    var part_id := str(defect.get("affected_part", ""))

    if part_id.is_empty():
        return {"success": false, "message": "Peca afetada nao informada."}

    var part := data_manager.get_part(part_id)

    if part.is_empty():
        return {"success": false, "message": "Peca nao encontrada."}

    var required_parts: Array = defect.get(
        "required_parts",
        [part_id]
    )

    # Conta quantas unidades de cada peca serao necessarias.
    var needed: Dictionary = {}

    for required_part in required_parts:
        var required_id := str(required_part)

        if required_id.is_empty():
            return {"success": false, "message": "Peca invalida."}

        needed[required_id] = int(needed.get(required_id, 0)) + 1

    # Confere todo o estoque antes de consumir.
    for required_id in needed:
        var quantity: int = int(needed[required_id])

        if not inventory_manager.has_part(required_id, quantity):
            return {
                "success": false,
                "message": "Peca em falta: " + str(required_id)
            }

    # Confere se a peca pode ser recuperada.
    if vehicle_manager.get_part_condition(instance_id, part_id) < 0.0:
        return {"success": false, "message": "Peca nao pertence ao veiculo."}

    # Consome as pecas.
    for required_id in needed:
        var quantity: int = int(needed[required_id])

        if not inventory_manager.consume_part(required_id, quantity):
            return {
                "success": false,
                "message": "Nao foi possivel consumir as pecas."
            }

    vehicle_manager.set_part_condition(
        instance_id,
        part_id,
        100.0
    )

    defect_manager.remove_defect(
        instance_id,
        defect_id
    )

    # Procura o valor da mao de obra no catalogo de servicos.
    var payment := 100.0

    for service in data_manager.get_all_services():
        var related: Array = service.get("related_defects", [])

        if related.has(defect_id):
            payment = float(service.get("labor_price", 100.0))
            break

    game_manager.add_money(payment)

    print("Reparo concluido: ", defect.get("name", defect_id))
    print("Pagamento recebido: R$ ", payment)

    return {
        "success": true,
        "message": "Reparo concluido com sucesso!",
        "payment": payment
    }


func can_repair(
    instance_id: String,
    defect_id: String
) -> bool:

    if defect_manager == null or inventory_manager == null:
        return false

    var defect := defect_manager.diagnose_defect(
        instance_id,
        defect_id
    )

    if defect.is_empty():
        return false

    var required_parts: Array = defect.get(
        "required_parts",
        [defect.get("affected_part", "")]
    )

    var needed: Dictionary = {}

    for required_part in required_parts:
        var required_id := str(required_part)

        if required_id.is_empty():
            return false

        needed[required_id] = int(needed.get(required_id, 0)) + 1

    for required_id in needed:
        if not inventory_manager.has_part(
            required_id,
            int(needed[required_id])
        ):
            return false

    return true
