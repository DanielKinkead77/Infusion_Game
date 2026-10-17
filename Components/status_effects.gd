class_name StatusEffects
extends Node

signal effect_started(effect: EffectData)
signal effect_ended(effect: EffectData)

class ActiveEffect:
	var data: EffectData
	var time_left: float = 0.0
	var tick_timer: float = 0.0
	
	func _init(effect: EffectData) -> void:
		data = effect
		time_left = effect.duration
var active: Dictionary[Script, ActiveEffect]
var health: Health = null

func _ready() -> void:
	health = Health.find_on(get_parent())
	if health != null:
		health.died.connect(clear_all)


static func find_on(node: Node) -> StatusEffects:
	for child: Node in node.get_children():
		if child is StatusEffects:
			return child as StatusEffects
	return null

func apply(effect: EffectData) -> void:
	if health != null and health.is_dead():
		return
	_handle_reactions(effect)
	var key: Script = effect.get_script()
	var is_new: bool = not active.has(key)
	active[key] = ActiveEffect.new(effect)
	if is_new:
		effect_started.emit(effect)


func remove(key: Script) -> void:
	if not active.has(key):
		return
	var ended: ActiveEffect = active[key]
	active.erase(key)
	effect_ended.emit(ended.data)


func has_effect(key: Script) -> bool:
	return active.has(key)


func get_effect(key: Script) -> EffectData:
	if active.has(key):
		return active[key].data
	return null


func clear_all() -> void:
	for key: Script in active.keys():
		remove(key)

func _process(delta: float) -> void:
	for key: Script in active.keys():
		if not active.has(key):
			continue
		var a: ActiveEffect = active[key]
		a.data.on_process(self, a, delta)
		a.time_left -= delta
		if a.time_left <= 0.0:
			remove(key)


func _handle_reactions(incoming: EffectData) -> void:
	if incoming is BurnEffect:
		remove(SlowEffect)
		remove(FreezeEffect)
