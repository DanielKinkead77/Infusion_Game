extends StaticBody3D

@export var health: Health
@export var status_effects: StatusEffects

func _ready() -> void:
	assert(health != null, "TestTarget: Health slot is empty")
	assert(status_effects != null, "TestTarget: Status Effects slot is empty")
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	status_effects.effect_started.connect(_on_effect_started)
	status_effects.effect_ended.connect(_on_effect_ended)
func _on_damaged(amount: float, type: Damage.Type) -> void:
	print("%s took %.2f %s damage, %.2f left" % [name, amount, Damage.Type.keys()[type], health.current_health])
func _on_died() -> void:
	print("%s died" % name)
func _on_effect_started(effect: EffectData) -> void:
	print("%s: %s started" % [name, effect.get_script().get_global_name()])
func _on_effect_ended(effect: EffectData) -> void:
	print("%s: %s ended" % [name, effect.get_script().get_global_name()])
