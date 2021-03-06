-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
-- Roaming Gamer Particle Editor 2 (a free SSK2 co-product)
-- =============================================================
-- See README.md for full license details.
-- =============================================================
local menuBar = {}

-- =============================================================
-- =============================================================
-- =============================================================
-- Useful Localizations
local getInfo           = system.getInfo
local getTimer          = system.getTimer
local mRand				= math.random
--
-- Common SSK Display Object Builders
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
--
-- Common SSK Helper Modules
local easyIFC = ssk.easyIFC;local persist = ssk.persist
--
-- Common SSK Helper Functions
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert
local tpd = timer.performWithDelay
-- =============================================================
-- =============================================================
local common 	= require "scripts.common"
local layersMgr = require "scripts.layersMgr"
local skel 		= require "scripts.skel"

local barHeight = 32
local buttonW 	= 140
local buttonH 	= barHeight - 6

--local mainPaneLoad 	= require "scripts.mainPanes.load"

-- ==
--
-- ==
local function onLoadEmitter( event )
	--local layers = layersMgr.get()
	--layers.curEmitter.isVisible = false
	--mainPaneLoad.render()
end

local function onProject( event )
	print("Project")
end

local function onHelp( event )	
	system.openURL( common.helpURL )
end

local function onVersion()
	easyAlert( "Version " .. _G.RGPEVer, "Last Updated on: " .. _G.lastUpdate, {{ "OK" } })
end

-- ==
--
-- ==
local function onMenuButton( event )
	local target 	= event.target
	local text   	= target.text
	local children 	= target.children

	if( children ) then
		local subMenuGroup = display.newGroup()
		--target.parent:insert( subMenuGroup )
		local function backTouch( self, event )
			if( event.phase == "ended" ) then
				display.remove(subMenuGroup)				
			end
			return true
		end
		local back = newImageRect( subMenuGroup, centerX, centerY, "images/fillW.png", 
			                       { w = fullw, h = fullh, touch = backTouch, alpha = 0, fill = _K_ } )
		transition.to( back, { alpha = 0.4, time = 250 } )

		post("onClearSelection")

		local bx = event.target.x
		local by = event.target.y + buttonH
		for i = 1, #children do
			local function cb( target )				
				if( children[i][2] ) then children[i][2](target) end
				--post("onMenuButton", {button = children[i][1] })
				display.remove(subMenuGroup)
				return true
			end
			local tmp = easyIFC:presetPush( subMenuGroup, "menu", bx, by, buttonW, buttonH, children[i][1], cb, { labelHorizAlign = "left", labelOffset = { 4, 0 } } )	
			by = by + buttonH
		end
	end
	return true
end

-- ==
--
-- ==
local function newMenuButton( x, y, label, cbChildren )
	local layers = layersMgr.get()
	local tmp
	if( cbChildren and type(cbChildren) == "function" ) then
		tmp = easyIFC:presetPush( layers.tbar, "edgeless2", x, y, buttonW, buttonH, label, cbChildren, { labelHorizAlign = "left", labelOffset = { 4, 0 } } )	
	else
		tmp = easyIFC:presetPush( layers.tbar, "edgeless2", x, y, buttonW, buttonH, label, onMenuButton, { labelHorizAlign = "left", labelOffset = { 4, 0 } } )	
		tmp.children = cbChildren
	end
	return tmp
end

-- ==
--
-- ==
function menuBar.create()
	local layers = layersMgr.get()
	--layers:purge("rightPane")
	local bar = newRect( layers.tbar, skel.tbar.x, skel.tbar.y, { w = fullw, h = barHeight, fill = common.barColor } )

	-- Primary Menu Buttons
	local curX = bar.x - bar.contentWidth/2 + buttonW/2 + 4

	local function onExploreOutput()
		local RGFiles = ssk.files
		local saveFolder = RGFiles.desktop.getDesktopPath( "RGPE2_out" )
		RGFiles.util.mkFolder( saveFolder )
		RGFiles.desktop.explore( saveFolder )
	end

	local function onExploreDB()
		local RGFiles = ssk.files
		RGFiles.desktop.explore( RGFiles.documentsRoot )
	end

	local function manageEmitters()
		local emitterSelector 	= require "scripts.emitterSelector"
		emitterSelector.run( nil, true )
	end

	local function onMakeRequest1()
		easyAlert( "Import Emitter: Ask For This Feature", 
			      	"If this is a feature you really need, please request in the the Corona forums.\n\n" ..
			      	"This feature would allow you to load a previously exported emitter definition into your library of emitters.",
			      	{ 
			        		{"OK", function() system.openURL( common.helpURL )  end },
			         	{"Nevermind", nil } 
			         } ) 		
	end

	local function onMakeRequest2()
		easyAlert( "Export Emitter: Ask For This Feature", 
			      	"If this is a feature you really need, please request in the the Corona forums.\n\n" ..
			      	"This feature would allow you to save (export) an emitter definition to back up or send to a friend/teammate.",
			      	{ 
			        		{"OK", function() system.openURL( common.helpURL )  end },
			         	{"Nevermind", nil } 
			         } ) 		
	end

	newMenuButton( curX, bar.y, "Explore",
	{ 
		{ "Output", 	onExploreOutput },
		{ "DB Files", 	onExploreDB },
	} )

	curX = curX + buttonW + 4
	newMenuButton( curX, bar.y, "Manage",
	{ 
		{ "Emitter Library", 		manageEmitters },
		{ "Import Emitter", 	onMakeRequest1 },
		{ "Export Emitter", 	onMakeRequest2 },
	} )


	--newMenuButton( curX, bar.y, "Project", onProject )
	curX = curX + buttonW + 4

	newMenuButton( curX, bar.y, "Help",
	{ 
		{ "Documentation", 		onHelp },
		{ "Version", 	onVersion },
	} )


	-- RG Link
	local function onLink( event )
		system.openURL( "http://www.roaminggamer.com")
		return false 
	end
	local function onRG( self, event )
		if( event.phase ~= "ended") then return false end
		onLink()
	end
	local size = bar.contentHeight - 4
	local rg = newImageRect( layers.tbar, bar.x + bar.contentWidth/2 - size/2 - 4, bar.y, "images/commonIcons/rgsmall.png", { size = size, touch = onRG } )
	curX = rg.x - size - buttonW/2
	local tmp = easyIFC:presetPush( layers.tbar, "edgeless2", curX, bar.y, buttonW, buttonH, "roaminggamer.com", onLink, 
		                             { labelFont = native.systemFont, labelSize = 16, labelOffset = { 0, 2 } }  )
	--nextFrame( onLoadEmitter, 100 )
end

return menuBar
