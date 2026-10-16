class_name ElementData
extends Resource

@export var element_name: String = ""
@export var colour: Color = Color.WHITE
@export var effects: Array[EffectData] = []
@export var supported_methods: Array[InfusionMethod] = []


func supports(method: InfusionMethod) -> bool:
	for m: InfusionMethod in supported_methods:
		if m.get_script() == method.get_script():
			return true
	return false
