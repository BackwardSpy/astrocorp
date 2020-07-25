extends Spatial

export var spacing := 0.1
export var variance := 0.08
export var y_variance := 1

export var asteroid: PackedScene

onready var path := $Path
onready var sampler := $Path/PathFollow

func _rdist() -> float:
    return rand_range(spacing - variance, spacing + variance)

func _ready():
    var progress := _rdist()
    
    while progress < 1.0:
        var ast: Spatial = asteroid.instance()
        add_child(ast)
        
        sampler.unit_offset = progress
        
        ast.global_transform.origin = sampler.global_transform.origin
        ast.translate(Vector3(0, rand_range(-y_variance, y_variance), 0))
        
        progress += _rdist()
        
    path.queue_free()
