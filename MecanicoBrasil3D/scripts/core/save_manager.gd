
extends Node
class_name SaveManager

# MECANICO BRASIL 3D
# Sistema de salvamento e carregamento

const SAVE_PATH := "user://mecanico_brasil_save.json"
const SAVE_VERSION := 1


func save_game(
    game_manager: Node,
    vehicle_manager: VehicleManager,
    defect_manager: DefectManager,
    inventory_manager: InventoryManager,
    customer_manager: CustomerManager,
    order_manager: ServiceOrderManager
) -> bool:

    var save_data: Dictionary = {
        "save_version": SAVE_VERSION,
        "saved_at": Time.get_unix_time_from_system(),

        "player": game_manager.player_data.duplicate(true),

        "vehicles": vehicle_manager.active_vehicles.duplicate(true),

        "defects": defect_manager.vehicle_defects.duplicate(true),

        "inventory": inventory_manager.inventory.duplicate(true),

        "customers": customer_manager.customers.duplicate(true),

        "orders": order_manager.orders.duplicate(true)
    }

    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

    if file == null:
        push_error("Nao foi possivel criar o arquivo de save.")
        return false

    file.store_string(JSON.stringify(save_data, "\t"))
    file.close()

    print("Jogo salvo com sucesso!")

    return true


func load_game(
    game_manager: Node,
    vehicle_manager: VehicleManager,
    defect_manager: DefectManager,
    inventory_manager: InventoryManager,
    customer_manager: CustomerManager,
    order_manager: ServiceOrderManager
) -> bool:

    if not FileAccess.file_exists(SAVE_PATH):
        print("Nenhum save encontrado.")
        return false

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

    if file == null:
        push_error("Nao foi possivel abrir o save.")
        return false

    var content := file.get_as_text()
    file.close()

    var parser := JSON.new()
    var error := parser.parse(content)

    if error != OK:
        push_error("Arquivo de save invalido.")
        return false

    var data: Variant = parser.data

    if not data is Dictionary:
        push_error("Estrutura de save invalida.")
        return false

    if int(data.get("save_version", -1)) != SAVE_VERSION:
        push_error("Versao de save incompatível.")
        return false

    var player: Variant = data.get("player", {})
    var vehicles: Variant = data.get("vehicles", {})
    var defects: Variant = data.get("defects", {})
    var inventory: Variant = data.get("inventory", {})
    var customers: Variant = data.get("customers", {})
    var orders: Variant = data.get("orders", {})

    if not player is Dictionary:
        return false

    if not vehicles is Dictionary:
        return false

    if not defects is Dictionary:
        return false

    if not inventory is Dictionary:
        return false

    if not customers is Dictionary:
        return false

    if not orders is Dictionary:
        return false

    game_manager.player_data = player.duplicate(true)
    vehicle_manager.active_vehicles = vehicles.duplicate(true)
    defect_manager.vehicle_defects = defects.duplicate(true)
    inventory_manager.inventory = inventory.duplicate(true)
    customer_manager.customers = customers.duplicate(true)
    order_manager.orders = orders.duplicate(true)

    print("Jogo carregado com sucesso!")

    return true


func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> bool:
    if not has_save():
        return false

    var error := DirAccess.remove_absolute(
        ProjectSettings.globalize_path(SAVE_PATH)
    )

    return error == OK
