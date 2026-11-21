
extends Node
class_name CustomerManager

# MECANICO BRASIL 3D
# Sistema de gerenciamento de clientes

var customers: Dictionary = {}

var first_names: Array[String] = [
    "Carlos",
    "Roberto",
    "Marcos",
    "Fernando",
    "Joao",
    "Lucas",
    "Rafael",
    "Anderson",
    "Paulo",
    "Gabriel"
]

var last_names: Array[String] = [
    "Silva",
    "Santos",
    "Oliveira",
    "Souza",
    "Costa",
    "Pereira",
    "Rodrigues",
    "Almeida",
    "Ferreira",
    "Lima"
]


func create_customer() -> Dictionary:
    var customer_id := "customer_" + str(Time.get_ticks_usec())

    var customer_name := (
        first_names.pick_random()
        + " "
        + last_names.pick_random()
    )

    var customer: Dictionary = {
        "id": customer_id,
        "name": customer_name,
        "reputation": 50,
        "total_services": 0,
        "total_spent": 0.0,
        "status": "active"
    }

    customers[customer_id] = customer

    print("Novo cliente cadastrado: ", customer_name)

    return customer.duplicate(true)


func get_customer(customer_id: String) -> Dictionary:
    if not customers.has(customer_id):
        return {}

    return customers[customer_id].duplicate(true)


func register_service(
    customer_id: String,
    payment: float
) -> bool:

    if not customers.has(customer_id):
        return false

    if payment < 0:
        return false

    customers[customer_id]["total_services"] += 1
    customers[customer_id]["total_spent"] += payment

    customers[customer_id]["reputation"] = clampi(
        customers[customer_id]["reputation"] + 2,
        0,
        100
    )

    return true


func get_all_customers() -> Array:
    return customers.values()


func remove_customer(customer_id: String) -> bool:
    if not customers.has(customer_id):
        return false

    customers.erase(customer_id)
    return true
