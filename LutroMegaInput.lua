-- Lutro Mega Input Library
-- Written by Juno Nguyen
-- For Libretro Lutro
-- Version 0.1

lmi = {
    _version = 0.1,
    -- The full reference of list of supported buttons on a gamepad and their corresponding keycodes
    KEYS = {
        up = 5,
        down = 6,
        left = 7,
        right = 8,
        a = 9,
        b = 1,
        x = 10,
        y = 2,
        select = 3,
        start = 4,
        l1 = 11,
        r1 = 12,
        l2 = 13,
        r2 = 14,
        l3 = 15,
        r3 = 16,
    },
    keyData = {},
    padCount = 1, -- The number of controllers currently being updated
}
lmi.__index = lmi

-- Initialise the configuration
-- configs: (table, optional) indicate the settings of the should contain the following keys:
--  keys: (an array of strings, optional), containing that keys to the buttons that the game would use, corresponding to the reference listed above. If omitted, will use all the available keys the list.
--  padCount: (number, optional) the number of controllers. Can be changed mid-game. If omitted, will be 1 by default.
-- A lower of number of keys and controllers will expectedly improve performance.
function lmi:init(configs)

    local default_keys = {
        'up', 'down', 'left', 'right',
        'a', 'b', 'x', 'y',
        'select', 'start',
        'l1', 'r1', 'l2', 'r2', 'l3', 'r3',
    }
    -- Handling default values
    if not configs then configs = {keys = default_keys, padCount = 1} end
    if not configs.keys then configs.keys = default_keys end
    if not configs.padCount then configs.padCount = 1 end

    -- Set the number of controllers
    self:setPadCount(configs.padCount)

    -- Create the table of keys and their state data for each controller
    for pid = 1, self.padCount do

        self.keyData[pid] = {}

        for _, keycode in pairs(configs.keys) do

            if self.KEYS[keycode] == nil then
                error(keycode..' is not a valid button keycode', 2)
            end

            self.keyData[pid][keycode] = {
                isDown = false,
                justPressed = false,
                justReleased = false,
                isWiping = false
            }
        end
    end
end

function lmi:update()
    for pid = 1, self.padCount do
        for keycode, keyStateData in pairs(self.keyData[pid]) do

            if keyStateData.isWiping then
                -- Disable input while wiping

                keyStateData.isDown = false
                keyStateData.justPressed = false
                keyStateData.justReleased = false

                -- Wiping is completed when key is released
                if not lutro.joystick.isDown(pid, self.KEYS[keycode]) then
                    keyStateData.isWiping = false
                end

            else
                -- Regular updates occur here

                -- The mismatched states of keyState.isDown and lutro.joystick.isDown indicate a new change, a button is just pressed or released
                -- justPresesd or justReleased value will be changed for the rest of this frame and the early portion of the next frame
                if not keyStateData.isDown and lutro.joystick.isDown(pid, self.KEYS[keycode]) then
                    keyStateData.justPressed = true
                elseif keyStateData.isDown and not lutro.joystick.isDown(pid, self.KEYS[keycode]) then
                    keyStateData.justReleased = true
                -- Otherwise matching states indicate that the button is already stabilised in this frame, meaing that justPressed and justReleased are no longer valid
                elseif keyStateData.isDown == lutro.joystick.isDown(pid, self.KEYS[keycode]) then
                    keyStateData.justPressed = false
                    keyStateData.justReleased = false
                end
                
                keyStateData.isDown = lutro.joystick.isDown(pid, self.KEYS[keycode])
            end

        end
    end
end

-- Change the pad count mid game
-- Useful when the number of players changes
-- newPadCount: (number) the new number of controllers. Cannot be lower than 1.
function lmi:setPadCount(newPadCount)
    if newPadCount < 1 then error("ERROR: padCount for LMI cannot be lower than 1", 3) end
    self.padCount = newPadCount;
end

-- keycode: (string) the keycode of button as a string.
-- pid: (number, optional) the id of the controller. If omitted, any keypress event from any active controller (subjected to self.padCount) will register. This is intentionally useful in some scenarios, such as configuring the settings of a match, where all players should participate.

-- Whether the button is being held down in the current frame.
function lmi:isDown(keycode, pid)
    if pid then
        return self.keyData[pid][keycode].isDown
    else
        for ipid = 1, self.padCount do
            if self.keyData[ipid][keycode].isDown then return true end
        end

        return false
    end
end

-- Whether this button has just been pressed. The will return true for only one frame.
function lmi:justPressed(keycode, pid)
    if pid then
        return self.keyData[pid][keycode].justPressed
    else
        for ipid = 1, self.padCount do
            if self.keyData[ipid][keycode].justPressed then return true end
        end

        return false
    end
end

-- Whether this button has just been released. The will return true for only one frame.
function lmi:justReleased(keycode, pid)
    if pid then
        return self.keyData[pid][keycode].justReleased
    else
        for ipid = 1, self.padCount do
            if self.keyData[ipid][keycode].justReleased then return true end
        end
 
        return false
    end
end

-- Initiate ignoring all keypress event until each button is released and repressed. This is particular useful for avoiding accidental triggers during state transitions.
function lmi:wipeStates()
    for pid = 1, self.padCount do
        for _, keyStateData in pairs(self.keyData[pid]) do
            keyStateData.isWiping = true
        end
    end
end

return lmi