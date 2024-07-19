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
