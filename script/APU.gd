extends Node

class_name APU

export var motor_power := 95.0
export var passive_resist := 0.0001
export var mag_resist := 0.00012
export var watt_per_rpm := 300.0

onready var pdu := $"../PowerDistributor"

var _enabled := false
var _mag_engaged := false
var _rpm := 0.0

func set_enabled(enabled: bool):
    _enabled = enabled
    print("APU enabled: %s" % _enabled)

func set_mag_engaged(engaged: bool):
    _mag_engaged = engaged
    print("APU mag engaged: %s" % _mag_engaged)

func get_rpm() -> float:
    return _rpm
    
func calculate_power() -> float:
    if _mag_engaged:
        return _rpm * watt_per_rpm
    else:
        return 0.0

func _update_rpm(dt: float):
    var resist := passive_resist
    if _mag_engaged:
        resist += mag_resist
        
    var drag := _rpm * _rpm * resist
    
    if _enabled:
        _rpm += (motor_power - drag) * dt
    else:
        _rpm -= drag * dt
        
    pdu.add_power(calculate_power())

func _process(dt: float):
    _update_rpm(dt)
