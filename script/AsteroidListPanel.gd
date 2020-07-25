extends CanvasLayer

onready var _asteroid_list: ItemList = $Panel/AsteroidList

var _asteroids: Array = []

func _update_ui():
    _asteroid_list.clear()
    for asteroid in _asteroids:
        _asteroid_list.add_item("asteroid")

func _find_asteroids():
    _asteroids = get_tree().get_nodes_in_group("asteroids")
    print("updated asteroids list, found %s asteroids" % _asteroids.size())

func refresh():
    _find_asteroids()
    _update_ui()

func _ready():
    refresh()
