extends Resource


@export var list: Array[Tint]


func get_random_tint() -> Tint:
	randomize()
	var rn = randi() % len(list)
	return list[rn]
