class_name ElementData
extends Resource

@export var element_name: String = ""
@export var color: Color = Color.WHITE
@export var damage_type: Damage.Type = Damage.Type.PHYSICAL
@export var impact_damage_bonus: float = 0.0
@export var effects: Array[EffectData] = []
@export var supported_methods: Array[InfusionMethod] = []


func supports(method: InfusionMethod) -> bool:
	for m: InfusionMethod in supported_methods:
		if m.get_script() == method.get_script():
			return true
	return false
