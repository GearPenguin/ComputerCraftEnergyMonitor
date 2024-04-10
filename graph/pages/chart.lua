local pretty = require "cc.pretty"
local utils = require "graph.utils"
local Dqueue = require "graph.dqueue"

local State = {}

function State.setup(monitor)
    monitor.setTextScale(0.5)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()

    State.width, State.height = monitor.getSize()
    State.monitor = monitor
    State.chart_window = window.create(monitor, 3, 2, State.width-3, State.height-4)

    State.chart_width, State.chart_height = State.chart_window.getSize()
    State.chart_window.setPaletteColor(colors.lime, 0x71d865)
    State.chart_window.setPaletteColor(colors.brown, 0xff5f5f)
    State.chart_window.setPaletteColor(colors.gray, 0x1f1f1f)

    State.chart_window.setBackgroundColor(colors.gray)
    State.chart_window.clear()

    local previous = term.redirect(monitor)
    paintutils.drawLine(2, 2, 2, State.height-2, colors.white)
    paintutils.drawLine(2, State.height-2, State.width-1 , State.height-2) 
    term.redirect(previous)
end

function State.update(data, config)
    local chart_window = State.chart_window
    local chart_height = State.chart_height
    local chart_width = State.chart_width
    local previous = term.redirect(chart_window)

    chart_window.setBackgroundColor(colors.gray)
    chart_window.clear()

    for i=data.first, data.last do
        local x = (i - data.first) + 1

        local inscaled = data[i].in_fe * chart_height / config.transferCap
        local outscaled = data[i].out_fe * chart_width / config.transferCap

        if inscaled > 0 and inscaled >= outscaled then
            paintutils.drawLine(x, chart_height, x, chart_height - inscaled + 1, colors.lime)

            if outscaled > 0 then
                paintutils.drawLine(x, chart_height, x, chart_height - outscaled + 1, colors.brown)
            end
        end

        if outscaled > 0 and outscaled > inscaled then
            paintutils.drawLine(x, chart_height, x, chart_height - outscaled + 1, colors.brown)

            if inscaled > 0 then
                paintutils.drawLine(x, chart_height, x, chart_height - inscaled + 1, colors.lime)
            end
        end

        if inscaled > 0 then
            paintutils.drawPixel(x, chart_height - inscaled + 1, colors.green)
        end

        if outscaled > 0 then
            paintutils.drawPixel(x, chart_height - outscaled + 1, colors.red)
        end
    end

    chart_window.setCursorPos(1, 1)
    chart_window.setBackgroundColor(colors.gray)
    chart_window.setTextColor(colors.white)
    chart_window.write(utils.format_si(config.transferCap) .. "RF/t")

    term.redirect(previous)

    local most_recent = Dqueue.peekright(data)
    local monitor = State.monitor
    
    monitor.setCursorPos(2, State.height)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.green)
    monitor.clearLine()
    monitor.write("IN: ")
    monitor.setTextColor(colors.white)
    monitor.write(utils.format_si(most_recent.in_fe) .. "RF/t\t\t")

    monitor.setTextColor(colors.red)
    monitor.write("OUT: ")
    monitor.setTextColor(colors.white)
    monitor.write(utils.format_si(most_recent.out_fe) .. "RF/t\t\t")

    monitor.setTextColor(colors.blue)
    monitor.write("STORED: ")
    monitor.setTextColor(colors.white)
    monitor.write(utils.format_si(most_recent.stored) .. "RF")

    monitor.write(" (".. string.format("%.3g", (most_recent.stored/config.storageCap)*100) .. "%)")
    
end

return {State = State}