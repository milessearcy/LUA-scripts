local pokemon1 = 0x02024284

local TID_MEM = pokemon1 + 0x04
local SID_MEM = TID_MEM + 0x02
local PID_MEM = pokemon1 + 0x00
local XPTR_MEM = 0x03005008

function isShiny(data)
    return (data[1] ~ data[2] ~ data[3] ~ data[4]) < 8
end
function read_data()
    local TID = emu:read16(TID_MEM)
    local SID = emu:read16(SID_MEM)
    local PID1 = emu:read16(PID_MEM)
    local PID2 = emu:read16(PID_MEM + 0x02)
    return {TID, SID, PID1, PID2}
end
function snap_shot()
    local snapShot = ""
    local data = emu:readRange(0x020204B0,48)

    for i = 0,47 do
        snapShot = snapShot .. string.format("%02X ", data:byte(i+1))
    end
    return snapShot
end

local said_yes = false
local SHINYYYY = false
local callID
local press = true
local openedText = false


local before = snap_shot()
local last = snap_shot()
local current
local change = false
local changeCounter = 0
local shinyCounter = 0
local resetCounter = 1319
local delayCounter = resetCounter
local seed
local frames = 0


local function on_frame()
    frames = frames + 1
    if delayCounter > 0 then
        delayCounter = delayCounter - 1
        return
    end
    

    

    current = snap_shot()

    if current ~= last then
        change = true
        changeCounter = changeCounter + 1
        last = current
    end
    


    if not press then
        if changeCounter >= 3 and (before == current or said_yes) then 
            emu:addKey(1)
            said_yes = true
        else 
            emu:addKey(0)
        end
    else 
        emu:clearKey(0)
        emu:clearKey(1)
    end

    press = not press

    if emu:read16(PID_MEM + 0x02) ~= 0 and emu:read16(PID_MEM) ~=0 then
        if isShiny(read_data()) then
                shinyCounter = shinyCounter + 1
                resetCounter = resetCounter + 1
                SHINYYYY = true
                console:log(tostring(shinyCounter) .. " shinies encountered \n" .. tostring(resetCounter) .. " attempt(s)" .. tostring(frames) .. "frame(s)")
                callbacks:remove(callID)
        end
    end

    if before == current and changeCounter >= 5 and emu:read8(0x02020888) == 72 then
        if not isShiny(read_data()) then
            resetCounter = resetCounter + 1
            said_yes = false
            SHINYYYY = false
            press = true
            openedText = false
            last = before
            changeCounter = 0
            change = false
            frames = 0
            delayCounter = resetCounter


            local d = read_data()
            local xor = d[1] ~ d[2] ~ d[3] ~ d[4]
            console:log("TID:" .. d[1] .. " SID:" .. d[2] .. " PID1:" .. d[3] .. " PID2:" .. d[4] .. " XOR:" .. xor)
            console:log(tostring(shinyCounter) .. " shinies encountered \n" .. tostring(resetCounter) .. " attempt(s)")

            console:log("Seed: " .. tostring(seed))


            emu:addKey(0)
            emu:loadStateSlot(1)
            
        end
    end
end

emu:loadStateSlot(1)
emu:addKey(0)
callID = callbacks:add("frame", on_frame)