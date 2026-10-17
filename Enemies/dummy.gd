extends CharacterBody3D

@export var health: Health
@export var status_effects: StatusEffects
@export var body_mesh: MeshInstance3D
@export var head_mesh: MeshInstance3D
@export var head_body: CollisionObject3D
@export var hp_label: Label3D

@export var walk_speed: float = 2.0
@export var patrol_distance: float = 4.0
@export var respawn_time: float = 3.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var start_position: Vector3
var direction: float = 1.0
var body_layer: int = 0
var head_layer: int = 0

func _ready() -> void:
	assert(health != null, "Dummy: Health slot is empty")
	assert(status_effects != null, "Dummy: Status Effects slot is empty")
	assert(body_mesh != null and head_mesh != null, "Dummy: a mesh slot is empty")
	assert(head_body != null and hp_label != null, "Dummy: Head Body or HP Label slot is empty")
	start_position = global_position
	body_layer = collision_layer
	head_layer = head_body.collision_layer
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	status_effects.effect_started.connect(_on_effect_changed)
	status_effects.effect_ended.connect(_on_effect_changed)
	_update_label()
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	var speed: float = walk_speed
	var slow: SlowEffect = status_effects.get_effect(SlowEffect) as SlowEffect
	if slow != null:
		speed *= 1.0 - slow.slow_amount
	velocity.x = direction * speed
	velocity.z = 0.0
	move_and_slide()
	var offset: float = global_position.x - start_position.x
	if offset > patrol_distance:
		direction = -1.0
	elif offset < -patrol_distance:
		direction = 1.0
func _on_effect_changed(_effect: EffectData) -> void:
	if status_effects.has_effect(BurnEffect):
		_set_tint(Color(1.0, 0.45, 0.1))
	elif status_effects.has_effect(SlowEffect):
		_set_tint(Color(0.4, 0.6, 1.0))
	else:
		_clear_tint()


func _set_tint(color: Color) -> void:
	for mesh: MeshInstance3D in [body_mesh, head_mesh]:
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		mesh.material_override = material


func _clear_tint() -> void:
	for mesh: MeshInstance3D in [body_mesh, head_mesh]:
		mesh.material_override = null


func _on_damaged(amount: float, type: Damage.Type) -> void:
	print("%s took %.2f %s damage" % [name, amount, Damage.Type.keys()[type]])
	_update_label()


func _update_label() -> void:
	if health.is_dead():
		hp_label.text = "DEAD"
	else:
		hp_label.text = "%.0f / %.0f" % [health.current_health, health.max_health]
func _on_died() -> void:
	print("%s died" % name)
	set_physics_process(false)
	collision_layer = 0
	head_body.collision_layer = 0
	_update_label()
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation:z", deg_to_rad(90.0), 0.4)
	await get_tree().create_timer(respawn_time).timeout
	_respawn()


func _respawn() -> void:
	rotation = Vector3.ZERO
	global_position = start_position
	collision_layer = body_layer
	head_body.collision_layer = head_layer
	health.reset()
	set_physics_process(true)
	_update_label()
	_clear_tint()
