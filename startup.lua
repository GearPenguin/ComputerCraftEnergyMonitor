-- Libraries
local pretty = require "cc.pretty"
local pages = require "graph.pages"
local Dqueue = require "graph.dqueue"
local j2fe = mekanismEnergyHelper.joulesToFE

-- Peripherals
local monitor = peripheral.find("monitor")
local cell = peripheral.find("inductionPort")

-- Setup
local config = require "graph.config"
config.transferCap = j2fe(cell.getTransferCap())
config.storageCap = j2fe(cell.getMaxEnergy())

-- Setup - calculate chart page width for queue trimming
monitor.setTextScale(0.5)
local max_queue_length = monitor.getSize() - 3 -- 2 chars spacing, 1 char for bar

local page = pages[config.launchPage]
local page_id = config.launchPage
page.setup(monitor)

local smoothed = Dqueue.new()
local samples = Dqueue.new()
os.startTimer(0.5) 

-- Event Loop
while true do
    local eventData = {os.pullEvent()}
    local event = eventData[1]
    
    if (event == "timer") then
        -- get current data
        local input = j2fe(cell.getLastInput())
        local output = j2fe(cell.getLastOutput())
        local full = j2fe(cell.getEnergy())
        
        -- if not using rolling average skip extra logic
        if (config.rollingAvgPeriod == 1) then
            Dqueue.pushright(smoothed, {in_fe = input, out_fe = output, stored = full})
        
        else

            Dqueue.pushright(samples, {in_fe = input, out_fe = output, stored = full})
            
            if Dqueue.length(samples) > config.rollingAvgPeriod then
                Dqueue.popleft(samples)
            end

            -- compute averages
            local average = {in_fe = 0, out_fe = 0, stored = 0}
            for i=samples.first, samples.last do
                average.in_fe = average.in_fe + samples[i].in_fe
                average.out_fe = average.out_fe + samples[i].out_fe
                average.stored = average.stored + samples[i].stored
            end

            average = {
                in_fe = average.in_fe / config.rollingAvgPeriod,
                out_fe = average.out_fe / config.rollingAvgPeriod,
                stored = average.stored / config.rollingAvgPeriod
            }

            -- add to display queue
            Dqueue.pushright(smoothed, average)
        end

        if Dqueue.length(smoothed) > max_queue_length then
            Dqueue.popleft(smoothed)
        end

        page.update(smoothed, config)
        os.startTimer(0.5)

    elseif (event == "monitor_touch") then
        page_id = (page_id % #pages) + 1

        print("Switch to page " .. page_id)
        page = pages[page_id]
        page.setup(monitor)
        page.update(smoothed, config)
    end

    
end 
