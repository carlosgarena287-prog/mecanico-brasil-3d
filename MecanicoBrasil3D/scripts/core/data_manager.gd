
extends Node
class_name DataManager

# MECANICO BRASIL 3D
# Sistema central de carregamento dos catalogos JSON

var catalogs: Dictionary = {}


func _ready() -> void:
    load_all_catalogs()


func load_all_catalogs() -> bool:
    print("Carregando catalogos do jogo...")

    catalogs.clear()

    var success := true

    success = load_catalog(
        "res://data/vehicles.json",
        "vehicles"
    ) and success

    success = load_catalog(
        "res://data/parts.json",
        "parts"
    ) and success

    success = load_catalog(
        "res://data/defects.json",
        "defects"
    ) and success

    success = load_catalog(
        "res://data/services.json",
        "services"
    ) and success

    if success:
        print("Todos os catalogos foram carregados!")
    else:
        push_error("Falha ao carregar um ou mais catalogos.")

    return success


func load_catalog(path: String, collection: String) -> bool:
    if not FileAccess.file_exists(path):
        push_error("Arquivo nao encontrado: " + path)
        return false

    var file := FileAccess.open(path, FileAccess.READ)

    if file == null:
        push_error("Nao foi possivel abrir: " + path)
        return false

    var content := file.get_as_text()
    file.close()

    var parser := JSON.new()
    var error := parser.parse(content)

    if error != OK:
        push_error(
            "Erro JSON em " + path +
            ": " + parser.get_error_message()
        )
        return false

    var data: Variant = parser.data

    if not data is Dictionary:
        push_error("A estrutura principal precisa ser um objeto JSON: " + path)
        return false

    var entries: Variant = data.get(collection, null)

    if not entries is Array:
        push_error("Lista invalida no catalogo: " + collection)
        return false

    var indexed_entries: Dictionary = {}

    for entry in entries:
        if not entry is Dictionary:
            push_error("Entrada invalida no catalogo: " + collection)
            return false

        var entry_id := str(entry.get("id", ""))

        if entry_id.is_empty():
            push_error("Uma entrada esta sem ID em: " + collection)
            return false

        if indexed_entries.has(entry_id):
            push_error("ID duplicado: " + entry_id)
            return false

        indexed_entries[entry_id] = entry

    catalogs[collection] = indexed_entries

    print(
        collection,
        " carregado: ",
        indexed_entries.size(),
        " registros"
    )

    return true


func get_vehicle(vehicle_id: String) -> Dictionary:
    return catalogs.get("vehicles", {}).get(vehicle_id, {})


func get_part(part_id: String) -> Dictionary:
    return catalogs.get("parts", {}).get(part_id, {})


func get_defect(defect_id: String) -> Dictionary:
    return catalogs.get("defects", {}).get(defect_id, {})


func get_service(service_id: String) -> Dictionary:
    return catalogs.get("services", {}).get(service_id, {})


func get_all_vehicles() -> Array:
    return catalogs.get("vehicles", {}).values()


func get_all_parts() -> Array:
    return catalogs.get("parts", {}).values()


func get_all_defects() -> Array:
    return catalogs.get("defects", {}).values()


func get_all_services() -> Array:
    return catalogs.get("services", {}).values()
