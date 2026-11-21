extends Node3D

var game_manager
var data_manager
var vehicle_manager
var defect_manager
var inventory_manager
var repair_manager
var customer_manager
var service_order_manager
var save_manager
var progression_manager


func _ready() -> void:
    start_game()


func start_game() -> void:
    print("Iniciando Mecanico Brasil 3D...")

    game_manager = load("res://scripts/core/game_manager.gd").new()
    add_child(game_manager)

    data_manager = DataManager.new()
    add_child(data_manager)

    if data_manager.catalogs.size() != 4:
        push_error("Erro ao carregar os catalogos.")
        return

    vehicle_manager = VehicleManager.new()
    add_child(vehicle_manager)
    vehicle_manager.initialize(data_manager)

    defect_manager = DefectManager.new()
    add_child(defect_manager)
    defect_manager.initialize(data_manager, vehicle_manager)

    inventory_manager = InventoryManager.new()
    add_child(inventory_manager)
    inventory_manager.initialize(data_manager, game_manager)

    repair_manager = RepairManager.new()
    add_child(repair_manager)
    repair_manager.initialize(
        data_manager,
        vehicle_manager,
        defect_manager,
        inventory_manager,
        game_manager
    )

    customer_manager = CustomerManager.new()
    add_child(customer_manager)

    service_order_manager = ServiceOrderManager.new()
    add_child(service_order_manager)
    service_order_manager.initialize(
        data_manager,
        customer_manager,
        vehicle_manager,
        defect_manager,
        repair_manager
    )

    save_manager = SaveManager.new()
    add_child(save_manager)

    progression_manager = ProgressionManager.new()
    add_child(progression_manager)
    progression_manager.initialize(game_manager)

    print("Todos os sistemas foram conectados!")
    print("Mecanico Brasil 3D pronto para iniciar.")
