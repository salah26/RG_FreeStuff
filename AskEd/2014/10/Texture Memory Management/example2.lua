local onScreen = require "onScreen"

-- 1. Load list of textures to use in our example (randomly generated by init.lua)
--
local textureList = table.load("textureList.txt") or {}

-- 2. Create a group to put our new images in.  We'll use this later to move via transitions.
--
local pictureTray = display.newGroup()

if( #textureList >= _G.numTextures ) then
	local y = 0
	for i = 1, _G.numTextures do
		local curImage = textureList[i]
		local pic 
		--print(curImage[1],curImage[2])		
		if( curImage[1] == 1 ) then 			
			pic = display.newRect( pictureTray, centerX, y, 1024/6, 1024/6)
			pic.anchorY = 0
			y = y + 1024/6 + 5
		else
			pic = display.newRect( pictureTray, centerX, y, 1024/6, 768/6 )
			pic.anchorY = 0
			y = y + 768/6 + 5
		end
		onScreen.frameFiller( pic, curImage[2], "images/fillW.png", nil, system.TemporaryDirectory, system.ResourceDirectory )

		-- Uncomment following to test 'self-cleaning'
		--timer.performWithDelay( 1000, function() display.remove( pic ); end )
	end
else
	print("You did not initialize the example correctly.")
	print("Set _G.numTextures to 1000 the first time you run this project.")
end

-- 3. Create Simple HUD to track Memory and Texture Usage
--
local hudFrame = display.newRect( centerX, h + unusedHeight/2 - 42, fullw-4, 80)
hudFrame:setFillColor(0.2,0.2,0.2)
hudFrame:setStrokeColor(1,1,0)
hudFrame.strokeWidth = 1

local mMemLabel = display.newText( "Main Mem:", 40, hudFrame.y - 15, native.systemFont, 16 )
mMemLabel:setFillColor(1,0.4,0)
mMemLabel.anchorX = 0

local tMemLabel = display.newText( "Texture Mem:", 40, hudFrame.y + 15, native.systemFont, 16 )
tMemLabel:setFillColor(0.2,1,0)
tMemLabel.anchorX = 0

hudFrame.enterFrame = function( self )
	-- Fill in current main memory usage
	collectgarbage("collect") -- Collect garbage every frame to get 'true' current memory usage
	local mmem = collectgarbage( "count" ) 
	mMemLabel.text = "Main Mem: " .. round(mmem/(1024),4) .. " MB"

	-- Fill in current texture memory usage
	local tmem = system.getInfo( "textureMemoryUsed" )
	tMemLabel.text = "Texture Mem: " .. round(tmem/(1024 * 1024),4) .. " MB"
end; listen( "enterFrame", hudFrame )

-- 4. Some routines to move 'picture frame up and down over time'
--
local maxY = pictureTray.contentHeight
local moveTime = _G.numTextures * 500 -- 100 ms per texture
local moveDown
local moveUp
moveUp = function( self )
	transition.to( self, { y = -maxY, time = moveTime, onComplete = moveDown } )
end
moveDown = function( self )
	transition.to( self, { y = 0, time = moveTime, onComplete = moveUp } )
end
moveUp( pictureTray )