class_name Hitbox
extends Node

@export var health: Health
@export var status_effects: StatusEffects
@export var damage_multiplier: float = 1.0


func take_hit(amount: float, type: Damage.Type) -> void:
	if health != null:
		health.take_damage(amount * damage_multiplier, type)


func apply_effect(effect: EffectData) -> void:
	if status_effects != null:
		status_effects.apply(effect)


static func find_on(node: Node) -> Hitbox:
	for child: Node in node.get_children():
		if child is Hitbox:
			return child as Hitbox
	return null
