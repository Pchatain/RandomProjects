-- simpleDefense.lua

local function attack()
    for i = 1, 4 do
      if turtle.attack() then
          print("Entity attacked!")
          return true
      end
      turtle.turnRight()
    end
    return false
end

local function patrol()
    for i = 1, 4 do
    for j = 1, 5 do
    attack()
    if not turtle.forward() then
    turtle.turnRight()
    break
    end
    end
    turtle.turnRight()
    end
end

print("Starting simple defense patrol")
while true do
    patrol()
    print("Patrol complete, restarting...")
    os.sleep(5)
end