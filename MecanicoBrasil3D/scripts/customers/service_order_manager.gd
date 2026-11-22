
extends Node
class_name ServiceOrderManager

var data_manager: DataManager
var customer_manager: CustomerManager
var vehicle_manager: VehicleManager
var defect_manager: DefectManager
var repair_manager: RepairManager

var service_orders: Dictionary = {}


func initialize(
    data: DataManager,
    customers: CustomerManager,
    vehicles: VehicleManager,
    defects: DefectManager,
    repairs: RepairManager
) -> void:
    data_manager = data
    customer_manager = customers
    vehicle_manager = vehicles
    defect_manager = defects
    repair_manager = repairs

    print("Sistema de ordens de servico iniciado.")


func create_order(vehicle_id: String, defect_id: String) -> Dictionary:
    if data_manager == null or customer_manager == null:
        return {"success": false, "message": "Sistema nao inicializado."}

    var vehicle := vehicle_manager.create_vehicle(vehicle_id)

    if vehicle.is_empty():
        return {"success": false, "message": "Veiculo nao encontrado."}

    var instance_id := str(vehicle["instance_id"])

    if not defect_manager.apply_defect(instance_id, defect_id):
        vehicle_manager.remove_vehicle(instance_id)
        return {"success": false, "message": "Nao foi possivel aplicar o defeito."}

    var customer := customer_manager.create_customer()
    var order_id := "order_" + str(Time.get_ticks_usec())

    var order := {
        "id": order_id,
        "customer_id": customer["id"],
        "vehicle_instance_id": instance_id,
        "vehicle_id": vehicle_id,
        "defect_id": defect_id,
        "status": "waiting",
        "payment": 0.0
    }

    service_orders[order_id] = order

    print("Nova ordem de servico: ", order_id)

    return {
        "success": true,
        "order": order.duplicate(true)
    }


func get_order(order_id: String) -> Dictionary:
    if not service_orders.has(order_id):
        return {}

    return service_orders[order_id].duplicate(true)


func get_all_orders() -> Array:
    return service_orders.values()


func complete_order(order_id: String) -> Dictionary:
    if not service_orders.has(order_id):
        return {"success": false, "message": "Ordem nao encontrada."}

    var order: Dictionary = service_orders[order_id]

    if order["status"] == "completed":
        return {"success": false, "message": "Ordem ja concluida."}

    var result := repair_manager.repair_defect(
        str(order["vehicle_instance_id"]),
        str(order["defect_id"])
    )

    if not result.get("success", false):
        return result

    order["status"] = "completed"
    order["payment"] = float(result.get("payment", 0.0))
    service_orders[order_id] = order

    customer_manager.register_service(
        str(order["customer_id"]),
        float(order["payment"])
    )

    return {
        "success": true,
        "message": "Servico concluido!",
        "payment": order["payment"]
    }
