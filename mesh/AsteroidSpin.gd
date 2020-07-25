extends Spatial

onready var _axis := Vector3(
    rand_range(-1, 1),
    rand_range(-1, 1),
    rand_range(-1, 1)
).normalized()

func _process(dt: float):
    rotate(_axis, dt * 0.1)
