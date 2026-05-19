local pokemon1 = 0x02024284

local TID_MEM = pokemon1 + 0x04
local SID_MEM = TID_MEM + 0x02
local PID_MEM = pokemon1 + 0x00

function read_data()
    local TID = emu:read16(TID_MEM)
    local SID = emu:read16(SID_MEM)
    local PID1 = emu:read16(PID_MEM)
    local PID2 = emu:read16(PID_MEM + 0x02)
    return {TID, SID, PID1, PID2}
end
function print_data()
    local data = read_data()
    for i = 1, #data do
        console:log(tostring(data[i]))
    end
end
local function shinyFrame()
    local TID = 362
    local SID = 25656
    emu:loadStateSlot(1)
    local seed = emu:read32(0x03005000)
    local PID1, PID2

    local function RNG()
        seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
        PID1 = seed >> 16
        seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
        PID2 = seed >> 16
    end

    for frame = 1, 100000 do
        RNG()
        local xor = TID ~ SID ~ PID1 ~ PID2
        if xor < 8 then
            console:log("Shiny on frame: " .. frame)
        end
    end
end
-- shinyFrame()

local function findOffset(startSeed, targetPID1, targetPID2)
    local seed = startSeed
    local PID1, PID2

    for i = 1, 100000 do
            seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
            seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
            PID1 = seed >> 16
            seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
            seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
            PID2 = seed >> 16

        if PID1 == targetPID1 and PID2 == targetPID2 then
            console:log("Offset found: " .. i)
            return i
        end
    end

    console:log("No match found")
end


local seed = 0x50352128

seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
console:log("step 1 upper 16: " .. (seed >> 16))

seed = (seed * 0x41C64E6D + 0x6073) & 0xFFFFFFFF
console:log("step 2 upper 16: " .. (seed >> 16))

console:log("Target PID1: 14350")
console:log("Target PID2: 23901")