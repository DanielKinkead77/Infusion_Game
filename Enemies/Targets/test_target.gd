extends StaticBody3D
@export var health: Health
func _ready() -> void:
	assert(health != null, "TestTarget: Health slot is empty")
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
func _on_damaged(amount: float, type: Damage.Type) -> void:
	print("%s took %.1f %s damage, %.1f left" % [name, amount, Damage.Type.keys()[type], health.current_health])
func _on_died() -> void:
	print("%s died" % name)
