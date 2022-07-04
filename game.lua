
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()

local tapCount = 0
local died = false

local backGroup
local mainGroup
local uiGroup

local platform
local platformTop
local balloon
local tapText

local function pushBalloon()
    balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
    tapCount = tapCount + 1
    tapText.text = tapCount
end

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

local function endGame()
    composer.setVariable( "finalScore", tapCount )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "balloon" and obj2.myName == "platform" ) or
              ( obj1.myName == "platform" and obj2.myName == "balloon" ) or 
			  ( obj1.myName == "balloon" and obj2.myName == "platformTop" ) or
              ( obj1.myName == "platformTop" and obj2.myName == "balloon" ))
        then
            if (died == false ) then
                died = true
                balloon.alpha = 0
                timer.performWithDelay( 1000, endGame )
            end
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()

	backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
 
	local background = display.newImageRect( backGroup, "sky.png", 360, 570 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	platform = display.newImageRect( mainGroup, "platform.png", 300, 50 )
	platform.x = display.contentCenterX
	platform.y = display.contentHeight - 25
	physics.addBody( platform, "static" )
	platform.myName = "platform"

	platformTop = display.newImageRect( mainGroup, "platform.png", display.contentWidth, 10 )
	platformTop.x = display.contentCenterX
	platformTop.y = -50
	physics.addBody( platformTop, "static" )
	platformTop.myName = "platformTop"

	balloon = display.newImageRect( mainGroup, "balloon.png", 112, 112 )
	balloon.x = display.contentCenterX
	balloon.y = display.contentCenterY
	physics.addBody( balloon, "dynamic", { radius=50, bounce=0.3 } )
	balloon.myName = "balloon"

	tapText = display.newText( uiGroup, tapCount, display.contentCenterX, 20, "pricedow.ttf", 52 )
	tapText:setFillColor( 1, 0, 0)

	balloon:addEventListener( "tap", pushBalloon )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
		composer.removeScene( "game" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
