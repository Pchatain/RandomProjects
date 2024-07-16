-- treeFarmer.lua
local args = {...}
local FARMLOOPS = tonumber(args[1]) or 1

local SAPPLING_DISTANCE = 2
local SLEEP_TIME = 5

function forward(n) for i = 1, n do turtle.forward() end end

function back(n) for i = 1, n do turtle.back() end end

function turnaround()
    assert(turtle.turnRight())
    assert(turtle.turnRight())
end

local function refuel()
    if turtle.getFuelLevel() < 20 then
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(1) then break end
        end
    end
end

function findBonemeal()
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and
            (item.name == "minecraft:bone_meal" or item.name:find("bonemeal")) then
            return slot
        end
    end
    return 0
end

function selectEmptySlot()
    for slot = 1, 16 do
        if turtle.getItemCount(slot) == 0 then
            turtle.select(slot)
            return slot
        end
    end
    return 0 -- Return 0 if no empty slot is found
end

function fetchBonemealFromChest()
    -- assumes we are at start pos
    assert(turtle.up())
    local chest = peripheral.wrap("behind")
    if not chest then
        print("No Chest Found")
        assert(turtle.down())
        return false
    end
    turnaround()
    selectEmptySlot()
    got_item = turtle.suck(64)
    assert(turtle.down())
    turnaround()
    return got_item
end

local function plantSapling()
    print("Planting sappling")
    forward(SAPPLING_DISTANCE)
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
    forward(1)
    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
    end
    while not turtle.detectDown() do turtle.down() end
    back(1)
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

local function feedBoneMealUntilTree()
    local boneMealSlot = findBonemeal()
    if boneMealSlot == 0 then
        print("No bonemeal found")
        return fetchBonemealFromChest()
    end
    turtle.select(boneMealSlot)
    for i = 1, 10 do
        turtle.place()
        if isTree() then return true end
    end
    return false
end

function placeWoodInChest()
    local woodCount = 0
    local originalSlot = turtle.getSelectedSlot()

    -- Check if there's a chest in front
    local success, data = turtle.inspect()
    if not success or not data.name:find("chest") then
        print("No chest found in front of the turtle")
        return 0
    end

    -- Loop through all inventory slots
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and (item.name:find("log") or item.name:find("wood")) then
            -- Found wood, try to place it in the chest
            local count = turtle.getItemCount()
            turtle.drop()
            woodCount = woodCount + count - turtle.getItemCount()
        end
    end

    -- Restore original selected slot
    turtle.select(originalSlot)

    print("Placed " .. woodCount .. " wood items in the chest")
    return woodCount
end

function main_loop(farmLoops)
    nTrees = 0
    nLoops = 0
    while nTrees < farmLoops do
        refuel()
        if isTree() then
            harvestTree()
            nTrees = nTrees + 1
            collectDrops()
            back(SAPPLING_DISTANCE)
            collectDrops()
            turnaround()
            placeWoodInChest()
            turnaround()
            if nTrees < farmLoops then plantSapling() end
        elseif isSapling() then
            if nLoops % 30 == 0 then
                print("Waiting for tree to grow " .. nLoops)
            end
            if feedBoneMealUntilTree() then
                print("Tree has grown")
            else
                print("Tree didn't grow and no bonemeal, sleeping " .. SLEEP_TIME .. "s")
                os.sleep(SLEEP_TIME)
            end
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
