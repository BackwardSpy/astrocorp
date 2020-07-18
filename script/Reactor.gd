extends Node

class_name Reactor

export var channel_count := 8
export var channel_length := 15.0 # m
export var rod_speed := 0.5 # m/s
export var min_power := 0.0 # MW
export var max_power := 2400000000.0 # W
export var max_flow_rate := 7580.0 # l/s
export var max_delta_flow_rate := 380.0 # l/s/s
export var passive_coolant_transit_time := 10.0 # s
export var active_coolant_transit_time := 0.5 # s
export var coolant_mass := 6308.0 # kg
export var coolant_heat_capacity := 4200.0 # J/kg°C
export var passive_coolant_temp := 275.0 # °C
export var pump_power_usage := 180000.0 # W

onready var pdu := $"../PowerDistributor"

enum ControlMode { QUENCH, AUTO, MANUAL }

var _mode: int = self.ControlMode.QUENCH
var _rod_depths: Array
var _rod_setpoint := 0.0
var _manual_rod_setpoint := 0.0
var _flow_enabled := false
var _flow_rate := 0.0

func get_rod_depth(index: int) -> float:
    return _rod_depths[index]
    
func get_setpoint() -> float:
    return _rod_setpoint
    
func get_control_mode() -> int:
    return _mode

func get_flow_rate() -> float:
    return _flow_rate
    
func apu_has_power() -> bool:
    return pdu.capacity() >= pump_power_usage

func calculate_core_power() -> float:
    var avg_rod_depth := 0.0
    for i in channel_count:
        avg_rod_depth += _rod_depths[i]
    avg_rod_depth /= channel_count
    return lerp(max_power, min_power, avg_rod_depth / channel_length)
    
func calculate_coolant_temp() -> float:
    var transit_time: float = lerp(passive_coolant_transit_time, active_coolant_transit_time, _flow_rate / max_flow_rate)
    var energy := calculate_core_power() * transit_time
    var sp_energy := energy / coolant_mass
    return passive_coolant_temp + sp_energy / coolant_heat_capacity

func set_control_mode(mode: int):
    print("reactor mode changed from %s to %s" % [_mode, mode])
    _mode = mode
    _set_rod_setpoint()
    
func set_manual_setpoint(setpoint: float):
    _manual_rod_setpoint = clamp(setpoint, 0.0, channel_length)
    print("manual setpoint changed to %s" % _manual_rod_setpoint)
    _set_rod_setpoint()
    
func set_flow_enabled(enabled: bool):
    _flow_enabled = enabled
    
func _set_rod_setpoint():
    match _mode:
        ControlMode.QUENCH: _rod_setpoint = channel_length
        ControlMode.AUTO: _rod_setpoint = channel_length / 2
        ControlMode.MANUAL: _rod_setpoint = _manual_rod_setpoint

func _update_rod(index: int, dt: float):
    var diff := clamp(_rod_setpoint - _rod_depths[index], -rod_speed, rod_speed)
    _rod_depths[index] += diff * dt
    
func _update_flow(dt: float):
    var can_draw_power: bool = false
    if _flow_enabled:
        can_draw_power = pdu.try_draw_power(pump_power_usage)
    var target := max_flow_rate if _flow_enabled and can_draw_power else 0.0
    var diff = clamp(target - _flow_rate, -max_delta_flow_rate, max_delta_flow_rate)
    _flow_rate += diff * dt

func _ready():
    for i in channel_count:
        _rod_depths.append(channel_length)

func _process(dt: float):
    for i in channel_count:
        _update_rod(i, dt)
    _update_flow(dt)
    pdu.add_power(calculate_core_power())
