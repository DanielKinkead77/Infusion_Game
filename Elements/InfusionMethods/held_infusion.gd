class_name HeldInfusion
extends InfusionMethod


func find_target(infuser: Infuser) -> Infusable:
	var item: Throwable = infuser.throw_hand.held_item
	if item == null:
		return null
	return item.infusable
