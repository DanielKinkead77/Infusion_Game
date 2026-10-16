class_name Infuser
extends Node

signal element_selected(element: ElementData)

@export var throw_hand: ThrowHand
@export var unlocked_elements: Array[ElementData] = []
@export var unlocked_methods: Array[InfusionMethod] = []
@export var hold_to_infuse_time: float = 0.4

var slot_actions: Array[String] = ["element_1", "element_2"]
var selected_index: int = 0
var active_method_index: int = 0
var held_slot: int = -1
var hold_time: float = 0.0
var infused_this_press: bool = false

func _ready() -> void:
	assert(throw_hand != null, "Infuser: Throw Hand slot is empty")


func _unhandled_input(event: InputEvent) -> void:
	for i: int in slot_actions.size():
		if event.is_action_pressed(slot_actions[i]):
			select(i)
			held_slot = i
			hold_time = 0.0
			infused_this_press = false
		elif event.is_action_released(slot_actions[i]) and held_slot == i:
			held_slot = -1

func _process(delta: float) -> void:
	if held_slot == -1 or infused_this_press:
		return
	hold_time += delta
	if hold_time >= hold_to_infuse_time:
		infused_this_press = true
		try_infuse()

func select(index: int) -> void:
	if index >= unlocked_elements.size():
		return
	selected_index = index
	element_selected.emit(unlocked_elements[index])


func try_infuse() -> bool:
	if selected_index >= unlocked_elements.size() or unlocked_methods.is_empty():
		return false
	var element: ElementData = unlocked_elements[selected_index]
	var method: InfusionMethod = unlocked_methods[active_method_index]
	if not element.supports(method):
		return false
	var target: Infusable = method.find_target(self)
	if target == null:
		return false
	target.infuse(element, method.infusion_duration)
	return true
