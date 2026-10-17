class_name Health
extends Node

signal damaged(amount: float, type: Damage.Type)
signal died

@export var max_health: float = 100.0
@export var resistances: Array[Resistance] = []

var current_health: float = 0.0


func _ready() -> void:
	current_health = max_health
	
func reset() -> void:
	current_health = max_health

func take_damage(amount: float, type: Damage.Type) -> void:
	if is_dead():
		return
	var final_amount: float = amount * get_multiplier(type)
	current_health = maxf(current_health - final_amount, 0.0)
	damaged.emit(final_amount, type)
	if is_dead():
		died.emit()


func get_multiplier(type: Damage.Type) -> float:
	for r: Resistance in resistances:
		if r.type == type:
			return r.multiplier
	return 1.0


func is_dead() -> bool:
	return current_health <= 0.0


static func find_on(node: Node) -> Health:
	for child: Node in node.get_children():
		if child is Health:
			return child as Health
	return null
