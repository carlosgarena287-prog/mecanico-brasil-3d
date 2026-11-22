
extends CanvasLayer
class_name WorkshopUI

var data_manager
var game_manager
var progression_manager
var vehicle_manager
var defect_manager
var inventory_manager
var repair_manager
var service_order_manager

var vehicle_option: OptionButton
var defect_option: OptionButton
var order_option: OptionButton

var money_label: Label
var level_label: Label
var reputation_label: Label
var status_label: Label


func initialize(
    data,
    game,
    progression,
    vehicles,
    defects,
    inventory,
    repairs,
    orders
) -> void:
    data_manager = data
    game_manager = game
    progression_manager = progression
    vehicle_manager = vehicles
    defect_manager = defects
    inventory_manager = inventory
    repair_manager = repairs
    service_order_manager = orders

    _build_interface()
    _refresh_interface()


func _build_interface() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    var panel := PanelContainer.new()
    panel.position = Vector2(12, 12)
    panel.custom_minimum_size = Vector2(330, 620)
    root.add_child(panel)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 8)
    panel.add_child(content)

    var title := Label.new()
    title.text = "MECANICO BRASIL 3D"
    title.add_theme_font_size_override("font_size", 20)
    content.add_child(title)

    money_label = _new_label(content, "Dinheiro: R$ 0")
    level_label = _new_label(content, "Nivel: 1")
    reputation_label = _new_label(content, "Reputacao: 0")

    _add_separator(content)

    _new_label(content, "CRIAR ORDEM DE SERVICO")

    vehicle_option = OptionButton.new()
    vehicle_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(vehicle_option)

    defect_option = OptionButton.new()
    defect_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(defect_option)

    var create_button := Button.new()
    create_button.text = "Receber veiculo"
    create_button.pressed.connect(_on_create_order)
    content.add_child(create_button)

    _add_separator(content)

    _new_label(content, "ORDENS DA OFICINA")

    order_option = OptionButton.new()
    order_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(order_option)

    var buy_button := Button.new()
    buy_button.text = "Comprar peca necessaria"
    buy_button.pressed.connect(_on_buy_part)
    content.add_child(buy_button)

    var repair_button := Button.new()
    repair_button.text = "Concluir servico"
    repair_button.pressed.connect(_on_complete_order)
    content.add_child(repair_button)

    _add_separator(content)

    status_label = _new_label(content, "Oficina pronta.")


func _new_label(parent: Node, value: String) -> Label:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    parent.add_child(label)
    return label


func _add_separator(parent: Node) -> void:
    var separator := HSeparator.new()
    parent.add_child(separator)


func _refresh_interface() -> void:
    _refresh_player_data()
    _refresh_catalog_options()
    _refresh_orders()


func _refresh_player_data() -> void:
    money_label.text = "Dinheiro: R$ %.2f" % game_manager.get_player_money()

    var progress: Dictionary = progression_manager.get_progress()

    level_label.text = "Nivel: %d | XP: %d / %d" % [
        int(progress.get("level", 1)),
        int(progress.get("experience", 0)),
        int(progress.get("experience_required", 100))
    ]

    reputation_label.text = "Reputacao: %d" % progression_manager.get_reputation()


func _refresh_catalog_options() -> void:
    vehicle_option.clear()
    defect_option.clear()

    for vehicle in data_manager.get_all_vehicles():
        var index := vehicle_option.item_count
        vehicle_option.add_item(str(vehicle.get("name", "Veiculo")))
        vehicle_option.set_item_metadata(index, str(vehicle.get("id", "")))

    for defect in data_manager.get_all_defects():
        var index := defect_option.item_count
        defect_option.add_item(str(defect.get("name", "Defeito")))
        defect_option.set_item_metadata(index, str(defect.get("id", "")))


func _refresh_orders() -> void:
    order_option.clear()

    var orders: Array = service_order_manager.get_all_orders()

    for order in orders:
        var index := order_option.item_count
        var order_text := "%s - %s" % [
            str(order.get("vehicle_id", "Veiculo")),
            str(order.get("status", "waiting"))
        ]

        order_option.add_item(order_text)
        order_option.set_item_metadata(index, str(order.get("id", "")))


func _selected_metadata(option: OptionButton) -> String:
    var index := option.selected

    if index < 0:
        return ""

    return str(option.get_item_metadata(index))


func _on_create_order() -> void:
    var vehicle_id := _selected_metadata(vehicle_option)
    var defect_id := _selected_metadata(defect_option)

    if vehicle_id.is_empty() or defect_id.is_empty():
        status_label.text = "Selecione um veiculo e um defeito."
        return

    var result: Dictionary = service_order_manager.create_order(
        vehicle_id,
        defect_id
    )

    status_label.text = str(result.get("message", "Ordem criada."))

    if result.get("success", false):
        status_label.text = "Ordem criada! Agora compre a peca necessaria."

    _refresh_orders()
    _refresh_player_data()


func _on_buy_part() -> void:
    var order_id := _selected_metadata(order_option)

    if order_id.is_empty():
        status_label.text = "Selecione uma ordem."
        return

    var order := service_order_manager.get_order(order_id)

    if order.is_empty():
        status_label.text = "Ordem nao encontrada."
        return

    if str(order.get("status", "")) == "completed":
        status_label.text = "Este servico ja foi concluido."
        return

    var defect := data_manager.get_defect(str(order.get("defect_id", "")))
    var part_id := str(defect.get("affected_part", ""))

    if part_id.is_empty():
        status_label.text = "Peca nao identificada."
        return

    if inventory_manager.buy_part(part_id, 1):
        status_label.text = "Peca comprada com sucesso!"
    else:
        status_label.text = "Dinheiro insuficiente ou peca indisponivel."

    _refresh_player_data()


func _on_complete_order() -> void:
    var order_id := _selected_metadata(order_option)

    if order_id.is_empty():
        status_label.text = "Selecione uma ordem."
        return

    var result: Dictionary = service_order_manager.complete_order(order_id)

    status_label.text = str(result.get("message", "Nao foi possivel concluir."))

    if result.get("success", false):
        status_label.text = "Servico concluido! Recebido: R$ %.2f" % float(
            result.get("payment", 0.0)
        )

    _refresh_interface()
