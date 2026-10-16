class_name Throwable
extends RigidBody3D

func pick_up(holder: PhysicsBody3D) -> void:
	freeze = true
	add_collision_exception_with(holder)
func release(launch_velcity: Vector3, holder: PhysicsBody3D) -> void:
	freeze = false
	linear_velocity = launch_velcity
	angular_velocity = Vector3.ZERO
	await get_tree().create_timer(0.2).timeout
	remove_collision_exception_with(holder)
