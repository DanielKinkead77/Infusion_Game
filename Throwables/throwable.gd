class_name Throwable
extends RigidBody3D

@export var infusable: Infusable
@export var impact_damage: float = 10.0

var throw_power: float = 0.0
var is_thrown: bool = false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func pick_up(holder: PhysicsBody3D) -> void:
	freeze = true
	is_thrown = false
	add_collision_exception_with(holder)
	if infusable != null:
		infusable.resume_timer()
func release(launch_velocity: Vector3, holder: PhysicsBody3D, power: float) -> void:
	throw_power = power
	freeze = false
	linear_velocity = launch_velocity
	angular_velocity = Vector3.ZERO
	is_thrown = true
	if infusable != null:
		infusable.pause_timer()
	await get_tree().create_timer(0.2).timeout
	remove_collision_exception_with(holder)

func _on_body_entered(body: Node) -> void:
	if not is_thrown:
		return
	is_thrown = false
	var hitbox: Hitbox = Hitbox.find_on(body)
	if hitbox != null:
		var damage: float = impact_damage * lerpf(0.5, 1.0, throw_power)
		hitbox.take_hit(damage, Damage.Type.PHYSICAL)
	if infusable != null:
		infusable.on_impact(body)
