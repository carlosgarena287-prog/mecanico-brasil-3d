
extends Node3D

const WorkshopBuilderScript = preload("res://scripts/world/workshop_builder.gd")
const VehicleModelBuilderScript = preload("res://scripts/vehicles/vehicle_model_builder.gd")
const WorkshopUIScript = preload("res://scripts/ui/workshop_ui.gd")

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
var workshop_builder
var vehicle_model_builder
var workshop_ui


func _ready() -> void:
    start_game()


func start_game() -> void:
    print("Iniciando Mecanico Brasil 3D...")

    game_manager = GameManager.new()
    add_child(game_manager)

    data_manager = DataManager.new()
    add_child(data_manager)

    if data_manager.catalogs.size() != 4:
        push_error("Erro ao carregar os catalogos.")
        return

    progression_manager = ProgressionManager.new()
    add_child(progression_manager)
    progression_manager.initialize(game_manager)

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

    workshop_builder = WorkshopBuilderScript.new()
    add_child(workshop_builder)
    workshop_builder.build_workshop(self)

    vehicle_model_builder = VehicleModelBuilderScript.new()
    add_child(vehicle_model_builder)

    _create_initial_vehicles()

    workshop_ui = WorkshopUIScript.new()
    add_child(workshop_ui)
    workshop_ui.initialize(
        data_manager,
        game_manager,
        progression_manager,
        vehicle_manager,
        defect_manager,
        inventory_manager,
        repair_manager,
        service_order_manager
    )

    print("Mecanico Brasil 3D pronto!")


func _create_initial_vehicles() -> void:
    var vehicles_to_spawn := [
        {
            "id": "chevrolet_celta_2013",
            "position": Vector3(-5.0, 0.0, -3.0)
        },
        {
            "id": "fiat_uno_2012",
            "position": Vector3(5.0, 0.0, -3.0)
        },
        {
            "id": "volkswagen_gol_2012",
            "position": Vector3(-5.0, 0.0, 4.0)
        },
        {
            "id": "volkswagen_jetta_2013",
            "position": Vector3(5.0, 0.0, 4.0)
        }
    ]

    for vehicle_data in vehicles_to_spawn:
        var vehicle_id: String = vehicle_data["id"]
        var vehicle_instance := vehicle_manager.create_vehicle(vehicle_id)

        if vehicle_instance.is_empty():
            push_error("Nao foi possivel criar: " + vehicle_id)
            continue

        vehicle_model_builder.build_vehicle(
            vehicle_id,
            self,
            vehicle_data["position"]
        )

    print("Quatro veiculos adicionados a oficina.")
