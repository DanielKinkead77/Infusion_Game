class_name BurnEffect
extends EffectData

@export var damage_per_second: float = 5.0
@export var tick_interval: float = 0.5
@export var damage_type: Damage.Type = Damage.Type.FIRE

func on_process(status: StatusEffects, active: StatusEffects.ActiveEffect, delta: float) -> void:
	if status.health == null:
		return
	active.tick_timer += delta
	while active.tick_timer >= tick_interval:
		active.tick_timer -= tick_interval
		status.health.take_damage(damage_per_second * tick_interval, damage_type)
