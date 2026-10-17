class_name Infusable
extends Node

signal infused(element: ElementData)
signal cleared

@export var mesh: MeshInstance3D

var element: ElementData = null
var time_left: float = 0.0
var timer_paused: bool = false

func infuse(new_element: ElementData, duration: float) -> void:
	element = new_element
	time_left = duration
	timer_paused = false
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = element.color
	mesh.material_override = material
	infused.emit(element)


func clear() -> void:
	if element == null:
		return
	element = null
	time_left = 0.0
	timer_paused = false
	mesh.material_override = null
	cleared.emit()


func _process(delta: float) -> void:
	if element == null or timer_paused:
		return
	time_left -= delta
	if time_left <= 0.0:
		clear()

func pause_timer() -> void:
	timer_paused = true

func resume_timer() -> void:
	timer_paused = false

func on_impact(target: Node) -> void:
	if element == null:
		return
	var health: Health = Health.find_on(target)
	if health != null and element.impact_damage_bonus > 0.0:
		health.take_damage(element.impact_damage_bonus, element.damage_type)
	# Later: gather impact rules here; ongoing effects go to StatusEffects (1.7)
	for effect: EffectData in element.effects:
		print("%s hit %s: %s" % [element.element_name, target.name, effect.get_script().get_global_name()])
	clear()
