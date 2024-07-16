-- Actual function is named utils.lua
local utils = {}

function utils.selectAndSuck(positions)
    print("Running Select and Suck")
    for i, pos in ipairs(positions) do
        print(pos)
        turtle.select(pos)
        turtle.suckDown(1)
    end
end

function utils.selectAndSuckUp(positions)
    for i, pos in ipairs(positions) do
        turtle.select(pos)
        turtle.suckUp(1)
    end
end


function utils.back(n)
    for i = 1, n do
        turtle.back()
    end
end

function utils.forward(n)
    for i = 1, n do
        turtle.forward()
    end
end

return utils