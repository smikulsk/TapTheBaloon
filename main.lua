-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local tapCount = 0
local died = false

local background = display.newImageRect( "sky.png", 360, 570 )
background.x = display.contentCenterX
background.y = display.contentCenterY

-----------------------------------------------------------------------------------------

local tapText = display.newText( tapCount, display.contentCenterX, 20, "pricedow.ttf", 52 )
tapText:setFillColor( 1, 0, 0)

-----------------------------------------------------------------------------------------

local platform = display.newImageRect( "platform.png", 300, 50 )
platform.x = display.contentCenterX
platform.y = display.contentHeight - 25
platform.myName = "platform"

-----------------------------------------------------------------------------------------

local balloon = display.newImageRect( "balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.myName = "balloon"

local function pushBalloon()
    balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
    tapCount = tapCount + 1
    tapText.text = tapCount
end

balloon:addEventListener( "tap", pushBalloon )

local function restoreBalloon()
    balloon.isBodyActive = false
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY
    
    transition.to( balloon, { alpha=0.8, time=1000,
        onComplete = function()
            balloon.isBodyActive = true
            died = false
        end
    } )
    
    tapCount = 0
    tapText.text = tapCount
end

-----------------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()

physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.3 } )

-----------------------------------------------------------------------------------------

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "balloon" and obj2.myName == "platform" ) or
              ( obj1.myName == "platform" and obj2.myName == "balloon" ) )
        then
            if (died == false ) then
                died = true
                balloon.alpha = 0
                timer.performWithDelay( 1000, restoreBalloon )
            end
        end
    end
end

Runtime:addEventListener( "collision", onCollision )