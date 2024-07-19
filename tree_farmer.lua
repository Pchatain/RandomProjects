-- treeFarmer.lua
local args = {...}
local FARMLOOPS = tonumber(args[1]) or 2

local SAPPLING_DISTANCE = 2
local SLEEP_TIME = 60
local MIN_FUEL = 80

local BONE_HEIGHT = 1
local FUEL_HEIGHT = 2
local SAPPLING_HEIGHT = 3

function forward(n) for i = 1, n do turtle.forward() end end

function back(n) for i = 1, n do turtle.back() end end

function up(n) for i = 1, n do turtle.up() end end

function down(n) for i = 1, n do turtle.down() end end

function turnaround()
    assert(turtle.turnRight())
    assert(turtle.turnRight())
end

function isChest()
    local success, data = turtle.inspect()
    if success then return data.name:find("chest") end
    return false
end

function returnToStart()
    print("Returning to start")
    refuel()
    down(SAPPLING_HEIGHT)
    assert(turtle.detectDown())
    for i = 1, 50 do
        if isTree() or isSapling() then
            print("Found tree or sapling, turning around")
            turnaround()
        end
        moved = turtle.forward()
        if isChest() then
            print("Found chest, turning around")
            turnaround()
            return true
        end
        if moved and not turtle.detectDown() then
            print("Moved forward, but no ground detected so backing up and turning around")
            turtle.back()
            turtle.turnRight()
        elseif not moved then
            print("Move failed, turning right")
            turtle.turnRight()
        end
    end
    print("Returning to Start failed!")
    if turtle.getFuelLevel() < MIN_FUEL then
        print("Out of Fuel!")
    end
    return false
end

function getItemFromChest(height)
    -- assumes we are at tree pos
    back(SAPPLING_DISTANCE)
    up(height)
    local found = false
    turnaround()
    selectEmptySlot()
    found = turtle.suck(64)
    turnaround()
    down(height)
    forward(SAPPLING_DISTANCE)
    return found
end

function refuel()
    -- Assumes we are at tree planting position
    if turtle.getFuelLevel() < MIN_FUEL then
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(1) then break end
        end
    end
    return turtle.getFuelLevel() >= MIN_FUEL
end

function findBonemeal()
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and
            (item.name == "minecraft:bone_meal" or item.name:find("bonemeal") or
                (item.name == "minecraft:dye" and item.damage == 15)) then
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

function getSapplingId()
    local sappling_id = 0
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and item.name:find("sapling") then
            sappling_id = i
        end
    end
    return sappling_id
end

function plantSapling()
    -- assumes we are next to tree.
    print("Planting sappling")
    local sappling_id = 0
    sappling_id = getSapplingId()
    if sappling_id == 0 then
        print("No sappling found, getting from chest")
        getItemFromChest(SAPPLING_HEIGHT)
    end
    sappling_id = getSapplingId()
    if sappling_id ~= 0 then
        turtle.select(sappling_id)
        return turtle.place()
    end
    return false
end

function collectDrops()
    turtle.suck()
end

function harvestTree()
    turtle.dig()
    forward(1)
    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
    end
    while not turtle.detectDown() do turtle.down() end
    collectDrops()
    back(1)
end

function isSapling()
    local success, data = turtle.inspect()
    if success then return data.name:find("sapling") end
    return false
end

function isTree()
    local success, data = turtle.inspect()
    if success then return data.name:find("log") end
    return false
end

function feedBoneMealUntilTree()
    local boneMealSlot = findBonemeal()
    if boneMealSlot == 0 then
        print("No bonemeal found")
        return getItemFromChest(BONE_HEIGHT)
    end
    turtle.select(boneMealSlot)
    for i = 1, 10 do
        turtle.place()
        if isTree() then return true end
    end
    return false
end

function placeWoodInChest()
    -- Assumes facing the chest at start pos
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
        if not refuel() then
            print("Out of fuel, getting some from chest")
            getItemFromChest(FUEL_HEIGHT)
        end
        if isTree() then
            harvestTree()
            nTrees = nTrees + 1
            turnaround()
            collectDrops()
            forward(SAPPLING_DISTANCE)
            placeWoodInChest()
            turnaround()
            forward(SAPPLING_DISTANCE)
            if nTrees < farmLoops then plantSapling() end
        elseif isSapling() then
            if nLoops % 30 == 0 then
                print("Waiting for tree to grow " .. nLoops)
            end
            if feedBoneMealUntilTree() then
                print("Tree was fed bonemeal")
            else
                print("Tree didn't grow and/or no bonemeal, sleeping " ..
                          SLEEP_TIME .. "s")
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
    -- Assumes we are at sappling position
    if isSapling() or isTree() then
        print("Starting tree farm")
    elseif plantSapling() then
        print("Sapling placed. Starting tree farm")
    else
        print("Sapling placement didn't work")
        return false
    end
    main_loop(farmLoops)
end

assert(returnToStart())
forward(SAPPLING_DISTANCE)
main(FARMLOOPS)
back(SAPPLING_DISTANCE)
print("Tree farmer done")

-- Turtle Code
local modem = peripheral.find("modem")
local channel = 42
modem.open(channel)

-- Function to listen for code
function listenForCode()
    print("Listening for code...")
    while true do
        local event, side, freq, replyChannel, message, distance = os.pullEvent("modem_message")
        
        if freq == channel then
            print("Received code: " .. message)
            modem.transmit(channel, channel, "Code received", distance)
            return message
        end
    end
end

-- Function to execute received code
function executeCode(code)
    local func, err = load(code)
    if func then
        func()
    else
        print("Error in received code: " .. err)
    end
end

-- Main program
local code = listenForCode()
executeCode(code)