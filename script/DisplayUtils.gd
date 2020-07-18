const POWER_UNITS = ["W", "kW", "MW"]

static func format_power(amount: float) -> String:
    var units := 0
    while amount > 1000.0 and units < POWER_UNITS.size() - 1:
        amount /= 1000.0
        units += 1
    return "%s %s" % [int(amount), POWER_UNITS[units]]
