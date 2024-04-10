local utils = require "graph.utils"
local Dqueue = require "graph.dqueue"

local State = {}

function drawBar(monitor, value, y, color)
local width, height = monitor.getSize()

local barWidth = math.ceil(value*width)
monitor.setCursorPos(1, y)
monitor.setTextColor(colors.white)
monitor.setBackgroundColor(color)
monitor.write(string.rep(" ", barWidth))

monitor.setCursorPos(1, y+1)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.write(string.rep(string.char(131), width))

end

function State.setup(monitor)
    monitor.setTextScale(2)
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

    monitor.setCursorPos(1, 1)
    monitor.write("IN: " .. utils.format_si(data.in_fe) .. "RF/t ")
    drawBar(monitor, data.in_fe / config.transferCap, 2, colors.green)

    monitor.setCursorPos(1, 4)
    monitor.write("OUT: " .. utils.format_si(data.out_fe) .. "RF/t ")
    drawBar(monitor, data.out_fe / config.transferCap, 5, colors.red)
    
    monitor.setCursorPos(1, 7)
    monitor.write("STORED: " .. utils.format_si(data.stored) .. "RF ")
    drawBar(monitor, data.stored / config.storageCap, 8, colors.blue)
    
end

return {State = State}