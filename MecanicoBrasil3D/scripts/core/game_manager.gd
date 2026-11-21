
extends Node3D
class_name GameManager

# MECANICO BRASIL 3D
# Gerenciador principal do jogo

const GAME_VERSION := "0.1.0"

var game_initialized: bool = false

var player_data: Dictionary = {
    "money": 5000.0,
    "level": 1,
    "experience": 0,
    "reputation": 0
}


func _ready() -> void:
    initialize_game()


func initialize_game() -> void:
    if game_initialized:
        return

    game_initialized = true

    print("Mecanico Brasil 3D iniciado!")
    print("Versao: ", GAME_VERSION)
    print("Dinheiro inicial: R$ ", player_data["money"])


func get_player_money() -> float:
    return float(player_data.get("money", 0.0))


func add_money(amount: float) -> void:
    if amount <= 0:
        return

    player_data["money"] = get_player_money() + amount

    print("Dinheiro recebido: R$ ", amount)


func remove_money(amount: float) -> bool:
    if amount <= 0:
        return false

    if get_player_money() < amount:
        return false

    player_data["money"] = get_player_money() - amount

    print("Dinheiro gasto: R$ ", amount)

    return true


func set_player_data(data: Dictionary) -> void:
    player_data = data.duplicate(true)


func get_player_data() -> Dictionary:
    return player_data.duplicate(true)


func add_reputation(amount: int) -> void:
    player_data["reputation"] = clampi(
        int(player_data.get("reputation", 0)) + amount,
        0,
        1000
    )
