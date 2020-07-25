extends Node

class_name WarpDrive

signal jumped(destination)

export var power_per_au := 100.0  # W/AU

onready var _pdu := $"../PowerDistributor"

enum Destination { NONE, HOME, BELT }
var _locked_desto: int = Destination.NONE

func lock_destination(destination: int):
    # TODO: check if jump is possible with current power
    _locked_desto = destination
    
    if _locked_desto == Destination.NONE:
        print("destination unlocked")
    else:
        print("destination locked to ", _locked_desto)

func jump():
    if _locked_desto == Destination.NONE:
        print("can't jump - desto not locked")
        return
    
    # TODO: use actual distance to desto
    var power = power_per_au * 120.0
    
    if _pdu.try_draw_power(power):
        emit_signal("jumped", _locked_desto)
    else:
        print("jump failed - not enough power")
