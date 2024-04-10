local function get_max(q)
    local max = 0
    for i=q.first,q.last do
        local higher_side = math.max(q[i].infe, q[i].outfe)
        
        max = math.max(max, higher_side)
    end

    return max
end

local function format_si(n)
   local prefixes = {"", "k", "M", "G", "T", "P"}
   local selected_prefix = nil
   for i, prefix in ipairs(prefixes) do
    if n < 1000 then
        selected_prefix = prefix
        break
    end

    n = n / 1000
   end

--    return math.floor(n) .. " " .. selected_prefix
   return string.format("%.3g %s", n, selected_prefix)
end

return { get_max = get_max, format_si = format_si }
