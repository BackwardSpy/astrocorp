extends Node

class_name PowerDistributor

var _power_pool := 0.0
var _input := 0.0
var _output := 0.0

func add_power(amount: float):
    _power_pool += amount
    _input += amount

func try_draw_power(amount: float) -> bool:
    if _power_pool >= amount:
        _power_pool -= amount
        _output += amount
        return true
    else:
        _output += _power_pool
        _power_pool = 0.0
        return false
        
func capacity() -> float:
    return _power_pool
    
func input_power() -> float:
    return _input
    
func output_power() -> float:
    return _output

func _process(dt: float):
    _power_pool = min(_power_pool, _input)
    _input = 0.0
    _output = 0.0
