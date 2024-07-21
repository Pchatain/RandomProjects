MIN_FUEL = 160

function turnaround()
    turtle.turnRight()
    turtle.turnRight()
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

while true do
    refuel()
    if not turtle.forward() then 
        turtle.suck()
        turnaround() 
    end
    if turtle.attack() then
        turtle.attack()
    end
end