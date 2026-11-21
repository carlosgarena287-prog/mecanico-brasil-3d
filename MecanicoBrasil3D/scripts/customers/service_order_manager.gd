
extends Node
class_name ServiceOrderManager

# MECANICO BRASIL 3D
# Sistema de ordens de servico

var data_manager: DataManager
var customer_manager: CustomerManager
var vehicle_manager: VehicleManager
var defect_manager: DefectManager
var repair_manager: RepairManager

var orders: Dictionary = {}


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


func create_order(
    customer_id: String,
    vehicle_instance_id: String,
    defect_id: String
) -> Dictionary:

    if data_manager == null:
        return {"success": false, "message": "Catalogos nao carregados."}

    if customer_manager == null or vehicle_manager == null:
        return {"success": false, "message": "Sistema de clientes ou veiculos ausente."}

    if defect_manager == null or repair_manager == null:
        return {"success": false, "message": "Sistema de reparos ausente."}

    var customer := customer_manager.get_customer(customer_id)
    var vehicle := vehicle_manager.get_vehicle_instance(vehicle_instance_id)
    var defect := data_manager.get_defect(defect_id)

    if customer.is_empty():
        return {"success": false, "message": "Cliente nao encontrado."}

    if vehicle.is_empty():
        return {"success": false, "message": "Veiculo nao encontrado."}

    if defect.is_empty():
        return {"success": false, "message": "Defeito nao encontrado."}

    var vehicle_defects := defect_manager.get_vehicle_defects(
        vehicle_instance_id
    )

    if not vehicle_defects.has(defect_id):
        return {
            "success": false,
            "message": "Esse defeito nao pertence ao veiculo."
        }

    # Impede duas ordens abertas para o mesmo defeito.
    for existing_order in orders.values():

        if existing_order.get("vehicle_instance_id", "") == vehicle_instance_id \
        and existing_order.get("defect_id", "") == defect_id \
        and existing_order.get("status", "") == "pending":

            return {
                "success": false,
                "message": "Ja existe uma ordem pendente para esse defeito."
            }

    var order_id := "order_" + str(Time.get_ticks_usec())

    var service_name := "Servico de reparo"
    var labor_price := 100.0

    for service in data_manager.get_all_services():

        var related: Array = service.get("related_defects", [])

        if related.has(defect_id):
            service_name = str(service.get("name", service_name))
            labor_price = float(service.get("labor_price", labor_price))
            break

    var order: Dictionary = {
        "id": order_id,
        "customer_id": customer_id,
        "vehicle_instance_id": vehicle_instance_id,
        "vehicle_name": vehicle.get("name", "Veiculo"),
        "defect_id": defect_id,
        "defect_name": defect.get("name", "Defeito"),
        "service_name": service_name,
        "labor_price": labor_price,
        "status": "pending",
        "created_at": Time.get_unix_time_from_system()
    }

    orders[order_id] = order

    print("Ordem de servico criada: ", order_id)

    return {
        "success": true,
        "order": order.duplicate(true),
        "message": "Ordem criada com sucesso."
    }


func complete_order(order_id: String) -> Dictionary:

    if not orders.has(order_id):
        return {"success": false, "message": "Ordem nao encontrada."}

    var order: Dictionary = orders[order_id]

    if order.get("status", "") != "pending":
        return {"success": false, "message": "Ordem nao esta pendente."}

    if repair_manager == null or customer_manager == null:
        return {"success": false, "message": "Sistemas nao inicializados."}

    var result := repair_manager.repair_defect(
        str(order["vehicle_instance_id"]),
        str(order["defect_id"])
    )

    if not result.get("success", false):
        return result

    var payment := float(result.get("payment", 0.0))

    customer_manager.register_service(
        str(order["customer_id"]),
        payment
    )

    order["status"] = "completed"
    order["payment"] = payment
    order["completed_at"] = Time.get_unix_time_from_system()

    orders[order_id] = order

    print("Ordem concluida: ", order_id)

    return {
        "success": true,
        "message": "Servico concluido com sucesso!",
        "payment": payment
    }


func cancel_order(order_id: String) -> bool:

    if not orders.has(order_id):
        return false

    if orders[order_id].get("status", "") != "pending":
        return false

    orders[order_id]["status"] = "cancelled"

    return true


func get_order(order_id: String) -> Dictionary:

    if not orders.has(order_id):
        return {}

    return orders[order_id].duplicate(true)


func get_all_orders() -> Array:
    return orders.values()


func get_pending_orders() -> Array:

    var pending: Array = []

    for order in orders.values():

        if order.get("status", "") == "pending":
            pending.append(order.duplicate(true))

    return pending
