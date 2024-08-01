USE_BONEMEAL = true
CHANNEL = 42

SAPPLING_DISTANCE = 3
SLEEP_TIME = 60
MIN_FUEL = 80
TREE_HEIGHT = 7
MAX_FORWARD = 64

BONE_HEIGHT = 1
FUEL_HEIGHT = 2
SAPPLING_HEIGHT = 3

-- Function to listen for code
function listenForCode(nonBlocking)
    local modem = peripheral.find("modem")
    modem.open(CHANNEL)
    print("Waiting for modem_message with code to run...")
    print("NonBlocking = " .. tostring(nonBlocking))
    if nonBlocking == nil then nonBlocking = false end
    local timeout = os.startTimer(SLEEP_TIME)
    while true do
        local event, side, freq, replyChannel, message, distance = os.pullEvent()
        if event == "modem_message" and freq == CHANNEL then
            print("Received code")
            modem.transmit(CHANNEL, CHANNEL, "Code received", distance)
            return message
        elseif event == "timer" then
            if nonBlocking then
                print("No code received, continuing scheduled program")
                return nil
            end
        end
    end
end

-- Function to execute received code
function executeCode(code)
    local func, err = load(code)
    if func then
        func()
    else
        print("Error in received code, func didn't work. Error msg = " .. err)
    end
end

function becomeReceiver()
    -- Use the equiped modem
    local modem = peripheral.find("modem")
    modem.open(CHANNEL)

    -- Wait until we get broadcasted code and then run the code.
    local code = listenForCode()
    executeCode(code)
end

function customAssert(condition, message)
    if not condition then
        print(message)
        becomeReceiver()
    end
end

function forwardUntilObstructed(max_steps)
    -- goes forward until it can't or no more path left, or reach max steps
    -- returns number of steps moved
    local steps = 0
    if max_steps == nil then max_steps = MAX_FORWARD end
    while steps < max_steps do
        if not turtle.forward() then break end
        if not turtle.detectDown() then
            turtle.back()
            break
        end
        turtle.suck()
        steps = steps + 1
    end
    return steps
end

function up(n) for i = 1, n do turtle.up() end end

function down(n) for i = 1, n do turtle.down() end end

function turnaround()
    customAssert(turtle.turnRight(), "failed to turn right")
    customAssert(turtle.turnRight(), "failed to turn right")
end

function isChest()
    local success, data = turtle.inspect()
    if success then return data.name:find("chest") end
    return false
end

function returnToStart()
    print("Returning to start")
    customAssert(refuel(), "User error: not enough fuel provided.")
    down(TREE_HEIGHT)
    customAssert(turtle.detectDown(), "No ground detected despite going down.")
    for i = 1, 150 do
        if itemInFrontHasName("log") or itemInFrontHasName("sapling") then
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
    if turtle.getFuelLevel() == 0 then
        print("Out of Fuel!")
    end
    return false
end

function getItemFromChest(height)
    -- assumes we are facing the sappling/tree farm position
    -- returns whether or not we found the item in a chest
    customAssert(turtle.turnLeft(), "failed to turn left!")
    distance = forwardUntilObstructed()
    up(height)
    local found = false
    emptySlotFound = selectEmptySlot()
    customAssert(emptySlotFound ~= 0, "No empty slot found! Clear turtle inventory please.")
    found = turtle.suck(64)
    turnaround()
    down(height)
    returnDist = forwardUntilObstructed(distance)
    customAssert(returnDist == distance, "failed to return to position we were working on. Went " .. returnDist .. " when we needed to go " .. distance)
    customAssert(turtle.turnLeft(), "failed to turn left!")
    return found
end

function refuel()
    -- Assumes we are at tree planting position
    if turtle.getFuelLevel() < MIN_FUEL then
        for i = 1, 16 do
            turtle.select(i)
            turtle.refuel()
        end
    end
    return turtle.getFuelLevel() >= MIN_FUEL
end

function findBonemealSlot()
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

function getSapplingSlot()
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
    local sappling_slot = getSapplingSlot()
    if sappling_slot == 0 then
        print("No sappling found, getting from chest")
        customAssert(getItemFromChest(SAPPLING_HEIGHT))
    end
    sappling_slot = getSapplingSlot()
    if sappling_slot ~= 0 then
        turtle.select(sappling_slot)
        return turtle.place()
    end
    return false
end

function collectDrops()
    turtle.suck()
end

function harvestTree(minHeight)
    -- Assumes we are facing tree
    if minHeight == nil then minHeight = 0 end
    turtle.dig()
    turtle.suck()
    customAssert(turtle.forward(), "failed to move underneath tree after digging")
    nDigs = 0
    while turtle.detectUp() or nDigs < minHeight do
        turtle.digUp()
        turtle.up()
        nDigs = nDigs + 1
    end
    while not turtle.detectDown() do turtle.down() end
    collectDrops()
    customAssert(turtle.back(), "failed to move back after harvesting tree")
end

function itemInFrontHasName(name)
    local success, data = turtle.inspect()
    if success then return data.name:find(name) end
    return false
end

function feedBoneMealUntilTree()
    if not USE_BONEMEAL then return 0 end
    local boneMealSlot = findBonemealSlot()
    local boneFed = 0
    if boneMealSlot == 0 then
        print("No bonemeal found")
        if not getItemFromChest(BONE_HEIGHT) then
            print("No bonemeal in chest")
            return 0
        else
            boneMealSlot = findBonemealSlot()
        end
    end
    turtle.select(boneMealSlot)
    for i = 1, 10 do
        fed = turtle.place()
        if fed then
            boneFed = boneFed + 1
        end
        if itemInFrontHasName("log") then break end
        os.sleep(0.1)
    end
    return boneFed
end

function findWoodSlot()
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and (item.name:find("log") or item.name:find("wood")) then
            return slot
        end
    end
    return 0
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

    -- Loop through all inventory slots and place wood in chest
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

function processFarm()
    -- assumes we are facing the tree farm position
    -- returns true if we harvested a tree
    local nTrees = 0
    local nLoops = 0
    local treeHarvested = false
    if not refuel() then
        print("Out of fuel, getting some from chest")
        customAssert(getItemFromChest(FUEL_HEIGHT), "failed to get fuel")
    end
    if itemInFrontHasName("log") then
        harvestTree()
        treeHarvested = true
        nTrees = nTrees + 1
        plantSapling()
    elseif itemInFrontHasName("sapling") then
        if nLoops % 30 == 0 then
            print("Waiting for tree to grow " .. nLoops)
        end
        local nBoneMealFed = feedBoneMealUntilTree()
        if itemInFrontHasName("log") then
            print("Tree grew!")
        elseif USE_BONEMEAL and nBoneMealFed < 5 then
            print("Less than 5 bonemeal fed and tree didn't grow.")
            print("Since no bonemeal, turning bonemeal functionality off")
            USE_BONEMEAL = false
        elseif USE_BONEMEAL then
            print("Tree didn't grow after feeding > 4 bonemeal. Clearing obstructions")
            harvestTree(TREE_HEIGHT)
        end
    else
        customAssert(plantSapling(), "failed to plant sapling, please fix.")
    end
    return treeHarvested
end

function main()
    -- Assumes we are at start position
    while true do
        local steps = 1
        treeHarvested = false
        while steps > 0 do
            steps = forwardUntilObstructed(SAPPLING_DISTANCE)
            print("Steps: " .. steps)
            if steps == SAPPLING_DISTANCE then
                turtle.turnLeft()
                if processFarm() then treeHarvested = true end
                turtle.turnRight()
            else
                break
            end
        end
        turnaround()
        forwardUntilObstructed()
        if treeHarvested then placeWoodInChest() end
        turnaround()
        listenForCode(true)
    end
end

customAssert(returnToStart(), "failed to return to start")
main()
print("Finished Successfully")
becomeReceiver()