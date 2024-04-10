local utils = require "graph.utils"
local Dqueue = require "graph.dqueue"

local State = {}

function State.setup(monitor)
    monitor.setTextScale(3)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    State.width, State.height = monitor.getSize()
    State.monitor = monitor
end

function State.update(data, config)
    local monitor = State.monitor
    local width = State.width; local height = State.height

    data = Dqueue.peekright(data)

    monitor.clear()

    local line = "Base Battery"
    monitor.setTextColor(colors.white)
    monitor.setCursorPos(width/2 - string.len(line)/2 + 1, 1)
    monitor.write(line)

    line = "IN: " .. utils.format_si(data.in_fe) .. "RF/t"
    monitor.setTextColor(colors.green)
    monitor.setCursorPos(width/2 - string.len(line)/2 + 1, 2)
    monitor.write(line)

    line = "OUT: " .. utils.format_si(data.out_fe) .. "RF/t"
    monitor.setTextColor(colors.red)
    monitor.setCursorPos(width/2 - string.len(line)/2 + 1, 3)
    monitor.write(line)

    line = "STORED: " .. utils.format_si(data.stored) .. "RF"
    monitor.setTextColor(colors.blue)
    monitor.setCursorPos(width/2 - string.len(line)/2 + 1, 4)
    monitor.write(line)

    line = "(".. string.format("%.3g", (data.stored/config.storageCap)*100) .. "% FULL)"
    monitor.setTextColor(colors.lightBlue)
    monitor.setCursorPos(width/2 - string.len(line)/2 + 1, 5)
    monitor.write(line)
end

return {State = State}