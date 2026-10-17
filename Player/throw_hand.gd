class_name ThrowHand
extends Node

@export var player: CharacterBody3D
@export var camera: Camera3D
@export var hold_point: Marker3D
@export var interact_ray: RayCast3D
@export var aim_ray: RayCast3D

@export var min_throw_force: float = 5.0
@export var max_throw_force: float = 20.0
@export var full_charge_time: float = 1.0
@export var charge_pullback: float = 0.12

@export var look_sway_amount: float = 0.001
@export var max_look_sway: float = 0.12
@export var move_sway_amount: float = 0.012
@export var sway_return_speed: float = 8.0

var held_item: Throwable = null
var look_sway: Vector2 = Vector2.ZERO
var move_offset: Vector3 = Vector3.ZERO
var is_charging: bool = false
var charge_time: float = 0.0


func _ready() -> void:
	assert(player != null, "ThrowHand: Player slot is empty")
	assert(camera != null, "ThrowHand: Camera slot is empty")
	assert(hold_point != null, "ThrowHand: Hold Point slot is empty")
	assert(interact_ray != null, "ThrowHand: Interact Ray slot is empty")
	assert(aim_ray != null, "ThrowHand: Aim Ray slot is empty")


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion and held_item != null:
		look_sway += event.relative * look_sway_amount
		look_sway = look_sway.limit_length(max_look_sway)

	if event.is_action_pressed("grab"):
		if held_item == null:
			try_grab()
		else:
			drop()
	elif event.is_action_pressed("throw") and held_item != null:
		is_charging = true
		charge_time = 0.0
	elif event.is_action_released("throw") and is_charging:
		is_charging = false
		throw()


func _physics_process(delta: float) -> void:
	if held_item == null:
		return

	if is_charging:
		charge_time = minf(charge_time + delta, full_charge_time)
	var charge_amount: float = charge_time / full_charge_time

	look_sway = look_sway.lerp(Vector2.ZERO, sway_return_speed * delta)
	var target_move_offset: Vector3 = -player.velocity * move_sway_amount
	move_offset = move_offset.lerp(target_move_offset, sway_return_speed * delta)

	var cam_basis: Basis = camera.global_basis
	var look_offset: Vector3 = cam_basis.x * -look_sway.x + cam_basis.y * look_sway.y
	var pullback: Vector3 = cam_basis.z * charge_amount * charge_pullback

	held_item.global_position = hold_point.global_position + look_offset + move_offset + pullback
	held_item.global_basis = hold_point.global_basis


func try_grab() -> void:
	var target: Object = interact_ray.get_collider()
	if target is Throwable:
		held_item = target as Throwable
		held_item.pick_up(player)
		aim_ray.add_exception(held_item)


func throw() -> void:
	var target_point: Vector3
	if aim_ray.is_colliding():
		target_point = aim_ray.get_collision_point()
	else:
		target_point = aim_ray.to_global(aim_ray.target_position)

	var direction: Vector3 = (target_point - held_item.global_position).normalized()
	var charge_amount: float = charge_time / full_charge_time
	var force: float = lerpf(min_throw_force, max_throw_force, charge_amount)

	var item: Throwable = held_item
	clear_hand()
	item.release(direction * force, player, charge_amount)


func drop() -> void:
	var item: Throwable = held_item
	clear_hand()
	item.release(Vector3.ZERO, player, 0.0)


func clear_hand() -> void:
	aim_ray.remove_exception(held_item)
	held_item = null
	look_sway = Vector2.ZERO
	move_offset = Vector3.ZERO
	is_charging = false
	charge_time = 0.0
