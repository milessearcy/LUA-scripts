local pokemon1 = 0x02024284

local TID_MEM = pokemon1 + 0x04
local SID_MEM = TID_MEM + 0x02
local PID_MEM = pokemon1 + 0x00
local XPTR_MEM = 0x03005008

local offset = { x = 0x0000, y = 0x0002 }
local location = { x = 10, y = 5 }

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

function check_movement()
    if emu:read8(0x0203707E) == 0x01 then return true end
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
local box2
local box1
local openedText = false


local before = snap_shot()
local last = snap_shot()
local current
local change = false
local changeCounter = 0

-- 02020880 has a value that is H at important moments
emu:addKey(0)

local function on_frame()
    -- box1 = emu:read32(0x020204C0)
    -- box2 = emu:read32(0x020204D0)
    -- box1 == 134482688 
    -- box2 == 19205892

    
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



    if before == current and changeCounter >= 5 and emu:read8(0x02020888) == 72 then
        if isShiny(read_data()) then
            SHINYYYY = true
            callbacks:remove(callID)
        else
            said_yes = false
            SHINYYYY = false
            press = true
            openedText = false
            last = before
            changeCounter = 0
            change = false
            emu:addKey(0)
            emu:loadStateSlot(1)
        end
    end
end




callID = callbacks:add("frame", function()
        local ok, err = pcall(function()
            on_frame()
        end)
if not ok then
    console:log("Error: " .. tostring(err))
end
end
)