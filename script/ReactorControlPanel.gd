extends CanvasLayer

const DisplayUtils = preload("DisplayUtils.gd")

onready var pdu := $PowerDistributor
onready var apu := $APU
onready var reactor := $Reactor

onready var control_mode_button := $ReactorPanel/ControlModeButton
onready var cr_states := $ReactorPanel/CRStates
onready var setpoint := $ReactorPanel/Setpoint
onready var setpoint_label := $ReactorPanel/Setpoint/Label
onready var core_temp_label := $ReactorPanel/CoreTempLabel
onready var core_power_label := $ReactorPanel/CorePowerLabel
onready var pdu_power_label := $ReactorPanel/PDUPowerLabel

onready var flow_rate := $CoolantPanel/FlowRate
onready var flow_rate_label := $CoolantPanel/FlowRate/Label
onready var temp_out_label := $CoolantPanel/TempOutLabel
onready var pump_power_label := $CoolantPanel/PowerDrawLabel

onready var apu_rpm_label := $APUPanel/RPMLabel
onready var apu_power_label := $APUPanel/PowerLabel

func _init_control_modes():
    for control_mode in reactor.ControlMode:
        control_mode_button.add_item(control_mode, reactor.ControlMode[control_mode])

func _init_cr_bars():
    for i in reactor.channel_count:
        var cr_bar := ProgressBar.new()
        cr_bar.min_value = 0
        cr_bar.max_value = reactor.channel_length
        cr_states.add_child(cr_bar)

func _init_setpoint():
    setpoint.min_value = 0
    setpoint.max_value = reactor.channel_length
    setpoint.value = 2 * reactor.channel_length / 3
    reactor.set_manual_setpoint(setpoint.value)
    _update_setpoint_label()
    
    setpoint.connect("value_changed", self, "_on_Setpoint_value_changed")
    
func _init_flow_rate_bar():
    flow_rate.min_value = 0
    flow_rate.max_value = reactor.max_flow_rate

func _update_cr_bar(index: int):
    var depth: float = reactor.get_rod_depth(index)
    var bar: ProgressBar = cr_states.get_child(index)
    bar.value = depth

func _update_setpoint():
    match reactor.get_control_mode():
        reactor.ControlMode.MANUAL:
            setpoint.editable = true
        _:
            setpoint.editable = false
            setpoint.value = reactor.get_setpoint()
    _update_setpoint_label()

func _update_setpoint_label():
    var pc := int(100 * setpoint.value / reactor.channel_length)
    setpoint_label.text = "%s m\n%s%%" % [setpoint.value, pc]
    
func _update_flow_rate():
    var rate: float = reactor.get_flow_rate()
    flow_rate.value = rate
    flow_rate_label.text = "%s l/s" % int(rate)

func _update_core_power():
    core_power_label.text = DisplayUtils.format_power(reactor.calculate_core_power())

func _update_coolant_temp():
    temp_out_label.text = "OUT %s °C" % int(reactor.calculate_coolant_temp())
    
func _update_pump_power():
    if pdu.capacity() >= reactor.pump_power_usage:
        pump_power_label.text = DisplayUtils.format_power(reactor.pump_power_usage)
    else:
        pump_power_label.text = "INSUF. PWR"

func _update_reactor():
    for i in reactor.channel_count:
        _update_cr_bar(i)
    _update_setpoint()
    _update_flow_rate()
    _update_core_power()
    _update_coolant_temp()
    _update_pump_power()

func _update_apu_rpm():
    apu_rpm_label.text = "%s RPM" % int(apu.get_rpm())
    
func _update_apu_power():
    apu_power_label.text = DisplayUtils.format_power(apu.calculate_power())

func _update_apu():
    _update_apu_rpm()
    _update_apu_power()
    
func _update_pdu():
    var watt_in: float = pdu.input_power()
    var watt_out: float = pdu.output_power()
    var exc: float = watt_in - watt_out
    pdu_power_label.text = "%s IN\n%s OUT\n%s EXC" % [
        DisplayUtils.format_power(watt_in),
        DisplayUtils.format_power(watt_out),
        DisplayUtils.format_power(exc)
    ]

func _ready():
    _init_control_modes()
    _init_cr_bars()
    _init_setpoint()
    _init_flow_rate_bar()

func _process(dt: float):
    _update_reactor()
    _update_apu()
    _update_pdu()

func _on_RodModeButton_item_selected(index: int):
    reactor.set_control_mode(index)

func _on_Setpoint_value_changed(value):
    reactor.set_manual_setpoint(value)

func _on_FlowEnable_toggled(button_pressed: bool):
    reactor.set_flow_enabled(button_pressed)

func _on_APUEnable_toggled(button_pressed: bool):
    apu.set_enabled(button_pressed)

func _on_MagEngage_toggled(button_pressed: bool):
    apu.set_mag_engaged(button_pressed)
