# Lutro Mega Input

An input library for Lutro (a subset of love2d port for LibRetro/RetroArch), which simplifies the usage of input.

While Lutro does offer `love.keypressed( key, scancode, isrepeat )` and `love.keyreleased( key, scancode )`, these functions exist as separated callbacks, making it clunky and un-intuitive to integrate them into the codebase. This library offers an alternative with similar functionalities, in addition to multiple controllers management.

*Contextual note*: as Lutro interprets both the `love` and `lutro` objects the same, this document will refer to the APIs as `love.*`. Due to the divergence of the APIs between Lutro and love2d, this library will require minor modification to work in love2d.

## Usage and quick example
```
    -- Load and provide a variable name for the library
    lmi = require 'libs/LutroMegaInput'

    love.load()
        -- Initiatialise the configurations
        lmi:init({
            keys = {'u', 'd', 'l', 'r', 'A', 'B', 'start'},
            padCount = 2
        })
        -- // Other codes of the game here
    end

    love.update(dt)

        -- Using the basic functions
        if lmi:justPressed('A', 1) then
            player1:jump()
        end

        if lmi:isDown('B', 1) then
            player1.chargePower = player1.chargePower + 1
        elseif lmi:justReleased('B', 1) then
            player1:shoot()
        end

        -- The keycode does not have to be the same as the declared keycodes
        -- but will need to point to the same keyId
        -- Also note the omission of padId, as both players can pause the game
        if lmi:justPressed('START') then pauseGame() end

        -- // More codes of the game here
    end
```

### Initialisation

Upon starting the game, initialise the library with

```
    lmi:init(configs)
```

`configs` is an object containing the following keys and values:
* `keys` (object, optional): A list of keycodes that the library is going to update and keep track of. Refer to the keycode and keyId list below. If omitted, the library will use the standard keys on a gamepad: `default_keys = {
    'up', 'down', 'left', 'right', 'a', 'b', 'x', 'y', 'select', 'start', 'l1', 'r1', 'l2', 'r2', 'l3', 'r3'}`
* `padCount` (number, optional): The number of controllers that the game will keep track of. If omitted, will be `1`. The number of controllers can be changed mid-game later on (see below). The value cannot be lower than 1.

### Getting input data

Remember to add `lmi:update()` to `love.update(dt)`.

The state of a button on a controller can be accessed from one of three functions:

* `lmi:justPressed(keycode, padId)`
* `lmi:isDown(keycode, padId)`
* `lmi:justReleased(keycode, padId)`

Which represent the lifecycle of a button press event, and will not return true at the same time. The parameters used for each of these functions are the same:
* `keycode` (string): the keycode of the button being pressed. This keycode does not have to be identical to what was declared in `lmi:init()`, as there are multiple keycodes referring the same button for more flexibility in styling. To refer to below for a more comprehensive chart.
* `padId` (number, optional): the id of controller that being queried. This parameter is optional and if omitted, any activity from any controller will be registered and activated. This is intenionally useful for actions that multiple players may take part in, such as choosing a map or pausing the game.

### Change the number of controllers

The number of the controllers being used can be changed at runtime by calling:

```
    lmi:setPadCount(newPadCount)
```

with `newPadCount` being a round number equal to or higher than 1.

The current number of padCount can also be accessed by calling `lmi:getPadCount()`.

Example:
```
    if hasNewPlayerJoined() then
        padCount = lmi:getPadCount()
        lmi:setPadCount(padCount + 1)
    end
```

### Input wiping

Input wiping can performed on a full scale basis for all buttons and all controllers by calling:

```
    lmi:wipeStates()
```

When a button is being wiped, it will not return true for any of the three function attempting to access its current state. A button wiping is completed when the button is fully released.

This is useful for "resetting" the input when the game transits from one screen to another with input that might affect the next screen.

```
    -- Switch state after A has been held for more than 5 seconds
    if lmi:isDown('A') then
        confirmationTimer = confirmationTimer + dt
        if confirmationTimer > 5 then 
            lmi:wipeStates()
            switchState()
        end
    end
```

### Keycodes and keyId

It is possible to use multiple keycodes to refer to the same button on a controller. While there are actual numbers of `keyId` assigned to each keycode, the detail is unimportant, and as long as the keycodes being used all refer to the same key, they can be used interchangeably.

The table below provide a list of valid keycodes. Keycodes on the same row refer to the same button. Do be mindful of the capitalisation.

`up` `UP` `u` `U`
`down` `DOWN` `d` `D`
`left` `LEFT` `l` `L`
`right` `RIGHT` `r` `R`
`a` `A`
`b` `B`
`x` `X`
`y` `Y`
`select` `SELECT`
`start` `START`
`l1` `L1` `lb` `LB`
`r1` `R1` `rb` `RB`
`l2` `L2` `lt` `LT`
`r2` `R2` `rt` `RT`
`l3` `L3` `ls` `LS`
`r3` `R3` `rs` `RS`

## Feedback

Please feel free to open issues and pull requests for this repository.