
extends Node
class_name ProgressionManager

# MECANICO BRASIL 3D
# Sistema de experiencia e progressao

var game_manager: Node

const MAX_LEVEL := 100
const BASE_XP_REQUIRED := 100
const XP_GROWTH := 1.25


func initialize(manager: Node) -> void:
    game_manager = manager
    print("Sistema de progressao iniciado.")


func add_experience(amount: int) -> Dictionary:
    if game_manager == null:
        return {"success": false}

    if amount <= 0:
        return {"success": false}

    var player: Dictionary = game_manager.player_data

    var current_level := int(player.get("level", 1))
    var current_xp := int(player.get("experience", 0))

    if current_level >= MAX_LEVEL:
        return {
            "success": true,
            "level": current_level,
            "leveled_up": false
        }

    current_xp += amount

    var leveled_up := false

    while current_level < MAX_LEVEL:
        var required_xp := get_xp_required(current_level)

        if current_xp < required_xp:
            break

        current_xp -= required_xp
        current_level += 1
        leveled_up = true

        print("Novo nivel alcancado: ", current_level)

    player["level"] = current_level
    player["experience"] = current_xp

    game_manager.player_data = player

    return {
        "success": true,
        "level": current_level,
        "experience": current_xp,
        "leveled_up": leveled_up
    }


func get_xp_required(level: int) -> int:
    if level >= MAX_LEVEL:
        return 0

    return int(
        round(
            BASE_XP_REQUIRED * pow(XP_GROWTH, level - 1)
        )
    )


func get_progress() -> Dictionary:
    if game_manager == null:
        return {}

    var player: Dictionary = game_manager.player_data

    var level := int(player.get("level", 1))
    var experience := int(player.get("experience", 0))

    var required := get_xp_required(level)

    return {
        "level": level,
        "experience": experience,
        "experience_required": required,
        "progress": (
            float(experience) / float(required)
            if required > 0
            else 1.0
        )
    }


func get_reputation() -> int:
    if game_manager == null:
        return 0

    return int(game_manager.player_data.get("reputation", 0))


func add_reputation(amount: int) -> void:
    if game_manager == null:
        return

    var player: Dictionary = game_manager.player_data

    player["reputation"] = clampi(
        int(player.get("reputation", 0)) + amount,
        0,
        1000
    )

    game_manager.player_data = player
