class_name Infusable
extends Node

signal infused(element: ElementData)
signal cleared

@export var mesh: MeshInstance3D

var element: ElementData = null
var time_left: float = 0.0


func infuse(new_element: ElementData, duration: float) -> void:
	element = new_element
	time_left = duration
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = element.color
	mesh.material_override = material
	infused.emit(element)


func clear() -> void:
	if element == null:
		return
	element = null
	time_left = 0.0
	mesh.material_override = null
	cleared.emit()


func _process(delta: float) -> void:
	if element == null:
		return
	time_left -= delta
	if time_left <= 0.0:
		clear()
