-- Computer Code
local modem = peripheral.find("modem")
local channel = 42
modem.open(channel)

-- Function to broadcast code to all turtles
function broadcastCode(code)
    modem.transmit(channel, channel, code)
    print("Code broadcasted")
end

-- Function to listen for responses
function listenForResponses()
    local responses = {}
    local timeout = os.startTimer(5) -- Set a timeout of 5 seconds
    
    while true do
        local event, side, freq, replyChannel, message, distance = os.pullEvent()
        
        if event == "modem_message" and freq == channel then
            table.insert(responses, {message = message, distance = distance})
            print("Received response from turtle at distance: " .. distance)
        elseif event == "timer" and side == timeout then
            break
        end
    end
    
    return responses
end

-- Main program
print("Enter the file path to broadcast:")
local filePath = io.read()
local file = fs.open(filePath, "r")
if file then
    local code = file.readAll()
    file.close()

    broadcastCode(code)
    local responses = listenForResponses()

    print("Responses received:")
    for _, response in ipairs(responses) do
        print("Turtle at distance " .. response.distance .. " responded: " .. response.message)
    end
else
    print("File not found!")
end
