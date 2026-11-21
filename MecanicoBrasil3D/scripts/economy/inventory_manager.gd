
extends Node
class_name InventoryManager

# MECANICO BRASIL 3D
# Sistema de estoque e compra de pecas

var data_manager: DataManager
var game_manager: Node

var inventory: Dictionary = {}


func initialize(data: DataManager, economy: Node) -> void:
    data_manager = data
    game_manager = economy

    inventory.clear()

    for part in data_manager.get_all_parts():
        var part_id: String = part["id"]
        inventory[part_id] = 0

    print("Estoque da oficina iniciado.")


func buy_part(part_id: String, quantity: int = 1) -> bool:
    if data_manager == null or game_manager == null:
        push_error("Estoque nao inicializado.")
        return false

    if quantity <= 0:
        return false

    var part := data_manager.get_part(part_id)

    if part.is_empty():
        push_error("Peca nao encontrada: " + part_id)
        return false

    var unit_price := float(part.get("purchase_price", 0.0))
    var total_price := unit_price * quantity

    if unit_price <= 0:
        return false

    if not game_manager.remove_money(total_price):
        print("Dinheiro insuficiente para comprar a peca.")
        return false

    inventory[part_id] = get_part_stock(part_id) + quantity

    print(
        "Compra realizada: ",
        quantity,
        "x ",
        part["name"]
    )

    return true


func get_part_stock(part_id: String) -> int:
    return int(inventory.get(part_id, 0))


func has_part(part_id: String, quantity: int = 1) -> bool:
    if quantity <= 0:
        return false

    return get_part_stock(part_id) >= quantity


func consume_part(part_id: String, quantity: int = 1) -> bool:
    if quantity <= 0:
        return false

    if not has_part(part_id, quantity):
        print("Estoque insuficiente: ", part_id)
        return false

    inventory[part_id] -= quantity

    print("Peca utilizada: ", part_id)

    return true


func add_part(part_id: String, quantity: int = 1) -> bool:
    if quantity <= 0:
        return false

    if data_manager == null:
        return false

    if data_manager.get_part(part_id).is_empty():
        return false

    inventory[part_id] = get_part_stock(part_id) + quantity

    return true


func get_inventory() -> Dictionary:
    return inventory.duplicate(true)
