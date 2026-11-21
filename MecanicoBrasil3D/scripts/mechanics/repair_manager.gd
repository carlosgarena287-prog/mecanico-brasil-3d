
extends Node
class_name RepairManager

var data_manager: DataManager
var vehicle_manager: VehicleManager
var inventory_manager: InventoryManager
var defect_manager: DefectManager
var game_manager: GameManager


func initialize(
    data: DataManager,
    vehicles: VehicleManager,
    inventory: InventoryManager,
    defects: DefectManager,
    game: GameManager
) -> void:
    data_manager = data
    vehicle_manager = vehicles
    inventory_manager = inventory
    defect_manager = defects
    game_manager = game

    print("Sistema de reparos iniciado.")


func repair_defect(
    instance_id: String,
    defect_id: String
) -> bool:

    if data_manager == null:
        push_error("DataManager nao inicializado.")
        return false

    if vehicle_manager == null or inventory_manager == null:
        push_error("Gerenciadores de veiculo ou inventario ausentes.")
        return false

    if defect_manager == null or game_manager == null:
        push_error("Gerenciadores de defeito ou jogo ausentes.")
        return false

    var vehicle := vehicle_manager.get_vehicle_instance(instance_id)

    if vehicle.is_empty():
        return false

    var defect := defect_manager.diagnose_defect(
        instance_id,
        defect_id
    )

    if defect.is_empty():
        print("Defeito nao diagnosticado ou inexistente.")
        return false

    var part_id := str(defect.get("affected_part", ""))

    if part_id.is_empty():
        return false

    var part := data_manager.get_part(part_id)

    if part.is_empty():
        return false

    var required_parts: Array = defect.get(
        "required_parts",
        [part_id]
    )

    # Verifica todas as pecas antes de consumir qualquer uma.
    for required_part_id in required_parts:

        if not inventory_manager.has_part(required_part_id):
            print("Peca em falta: ", required_part_id)
            return false

    # Consome as pecas necessarias.
    for required_part_id in required_parts:

        var consumed := inventory_manager.remove_part(
            required_part_id,
            1
        )

        if not consumed:
            push_error("Falha ao consumir uma peca.")
            return false

    # Recupera a condicao da peca afetada.
    vehicle_manager.set_part_condition(
        instance_id,
        part_id,
        100.0
    )

    # Remove o defeito do veiculo.
    defect_manager.remove_defect(
        instance_id,
        defect_id
    )

    # Recebe o pagamento da mao de obra.
    var labor_cost := float(defect.get("repair_cost", 100.0))

    game_manager.add_money(labor_cost)

    print("Reparo concluido: ", defect.get("name", defect_id))
    print("Pagamento recebido: R$ ", labor_cost)

    return true


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

    for part_id in required_parts:

        if not inventory_manager.has_part(str(part_id)):
            return false

    return true
