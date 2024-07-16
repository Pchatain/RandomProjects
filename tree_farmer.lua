-- treeFarmer.lua

local args = {...}
local FARMLOOPS = tonumber(args[1]) or 1

local function refuel()
    if turtle.getFuelLevel() < 20 then
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(1) then break end
        end
    end
end

local function plantSapling()
    print("Planting sappling")
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and item.name:find("sapling") then
            placedWell = turtle.place()
            print("Tried placing it")
            return placedWell
        end
    end
    return false
end

local function collectDrops()
    for i = 1, 4 do
        turtle.suck()
        turtle.turnRight()
    end
end

local function harvestTree()
    turtle.dig()
    turtle.forward()
    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
    end
    while not turtle.detectDown() do turtle.down() end
    collectDrops()
    turtle.back()
    collectDrops()
end

local function isSapling()
    local success, data = turtle.inspect()
    if success then return data.name:find("sapling") end
    return false
end

local function isTree()
    local success, data = turtle.inspect()
    if success then return data.name:find("log") end
    return false
end

function main_loop(farmLoops)
    nTrees = 0
    nLoops = 0
    while nTrees < farmLoops do
        refuel()
        if isTree() then
            harvestTree()
            nTrees = nTrees + 1
            if nTrees < farmLoops then
                plantSapling()
            end
        elseif isSapling() then
            if nLoops % 30 == 0 then
                print("Waiting for tree to grow " .. nLoops)
            end
            os.sleep(2) -- Wait 1 minute
        else
            print("No tree or sapling found. Somting wong")
            break
        end
        nLoops = nLoops + 1
    end
end

function main(farmLoops)
    if isSapling() then
        print("Starting tree farm")
    elseif plantSapling() then
        print("Sapling placed. Starting tree farm")
    else
        print("Sapling placement didn't work")
        return false
    end
    main_loop(farmLoops)
end
main(FARMLOOPS)
print("Tree farmer done")
