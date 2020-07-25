extends Node

class_name GridController

signal grid_changed

var _asteroid_belt := preload("res://AsteroidBelt.tscn")
var _loaded_belt: Node = null

func warp_to_belt():
    if _loaded_belt != null:
        print("not loading a new belt since we're already at one")
        return

    # in future this should take some params describing the belt we're warping to    
    _loaded_belt = _asteroid_belt.instance()
    get_node("/root").add_child(_loaded_belt)
    
    emit_signal("grid_changed")

func leave_belt():
    if _loaded_belt == null:
        print("can't leave belt since we're not at one")
        return

    get_node("/root").remove_child(_loaded_belt)
    _loaded_belt.queue_free()
    _loaded_belt = null
    
    emit_signal("grid_changed")

func _on_jumped(destination: int):
    assert(destination != WarpDrive.Destination.NONE)

    if _loaded_belt and destination == WarpDrive.Destination.HOME:
        leave_belt()
    elif destination == WarpDrive.Destination.BELT:
        warp_to_belt()
