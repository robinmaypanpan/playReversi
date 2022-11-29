import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/pulp-audio"

import 'ui/board'
import 'ui/player-display'

import 'players/human-player'
import 'players/random-ai'
import 'players/minimax-ai'

import 'game-controller'
import 'state-generator'

-- Save typing!
local gfx = playdate.graphics
local audio = pulp.audio

-- Game state inputHandlers
local gameController

local showDebugElements = fals

-- Sets up the display of the game
function setupUI()
	-- Setup the player displays first	
	local pieceTable = gfx.imagetable.new('assets/images/piece')
	local whitePieceImage = pieceTable[1]
	local blackPieceImage = pieceTable[7]
	
	local whiteDisplay = PlayerDisplay('LIGHT', whitePieceImage)
	whiteDisplay:add()
	whiteDisplay:moveTo(10,15)
	
	local blackDisplay = PlayerDisplay('DARK', blackPieceImage)
	blackDisplay:add()
	blackDisplay:moveTo(320,15)
	
	local screenWidth = playdate.display.getWidth()
	local screenHeight = playdate.display.getHeight()
	
	board = Board()
		
	local backgroundImage = gfx.image.new(screenWidth, screenHeight)
	gfx.pushContext(backgroundImage)
		gfx.setDitherPattern(0.5)
		gfx.fillRect(0, 0, screenWidth, screenHeight)
	gfx.popContext()		
	
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			-- x,y,width,height is the updated area in sprite-local coordinates
			-- The clip rect is already set to this area, so we don't need to set it ourselves
			backgroundImage:draw( 0, 0 )
		end
	)
	-- Create background
	
	
	board:moveTo(screenWidth / 2, screenHeight / 2)	
	board:add()	
	
	return board, whiteDisplay, blackDisplay
end

-- Resets the game internals
function restartGame()
	gameController:restartGame()
end

-- Toggles the debug mode
function toggleDebug(newValue)
	showDebugElements = newValue
end

local playerOptions = {
	'Human',
	'Easy AI',
	'Hard AI'
}

-- Returns a created player object for the indicated color
function getPlayer(playerString, gameController, color)
	if (playerString == 'Human') then
		return HumanPlayer(gameController, color)
	elseif (playerString == 'Easy AI') then
		return RandomAi(gameController, color)
	elseif (playerString == 'Hard AI') then
		return MinimaxAi(gameController, color)
	else
		error('No Player returned')
	end
end

-- Change the white player and restart
function changeWhitePlayer(newPlayerString)
	gameController.whitePlayer:shutDown()
	
	local newPlayer = getPlayer(newPlayerString, gameController, WHITE)	
	gameController.whitePlayer = newPlayer
	gameController:restartGame()
end

-- Change the black player and restart
function changeBlackPlayer(newPlayerString)
	gameController.blackPlayer:shutDown()
	
	local newPlayer = getPlayer(newPlayerString, gameController, BLACK)	
	gameController.blackPlayer = newPlayer
	gameController:restartGame()
end

-- Runs the game
function runGame()
	audio.init('assets/audio/pulp-songs.json', 'assets/audio/pulp-sounds.json')
	
	playdate.setMinimumGCTime(5)		
	math.randomseed(playdate.getSecondsSinceEpoch())
	
	local board, whiteDisplay, blackDisplay = setupUI()
	
	gameController = GameController(board, whiteDisplay, blackDisplay)
	
	local loadedData = playdate.datastore.read()
	if (loadedData) then
		-- Load state from disk		
		gameController.whitePlayer = getPlayer(loadedData.whitePlayer, gameController, WHITE)
		gameController.blackPlayer = getPlayer(loadedData.blackPlayer, gameController, BLACK)
		
		gameController:loadState(loadedData.gameState)
	else
		gameController.whitePlayer = HumanPlayer(gameController, WHITE)
		gameController.blackPlayer = MinimaxAi(gameController, BLACK)
	end
	
	stateGenerator = StateGenerator(gameController.gameState)
	
	-- Update the system menu with our options
	local systemMenu = playdate:getSystemMenu()
	systemMenu:addMenuItem('Restart Game', restartGame)
	systemMenu:addOptionsMenuItem('White', playerOptions,gameController.whitePlayer.name, changeWhitePlayer)
	systemMenu:addOptionsMenuItem('Black', playerOptions, gameController.blackPlayer.name, changeBlackPlayer)
	
	-- Standard main game loop
	function playdate.update()
		frameStartTime = playdate.getCurrentTimeMilliseconds()
		gfx.sprite.update()
		audio.update() 
		playdate.timer.updateTimers()
		gameController:update()
		stateGenerator:update()
		
		if (showDebugElements) then
			playdate.drawFPS(10, 220)
			playdate.graphics.drawTextAligned(stateGenerator.depth .. '-' .. stateGenerator.treeSize, playdate.display.getWidth() - 20, 220, kTextAlignment.right)
		end
	end
	
	function playdate.gameWillTerminate()
		gameController:saveGame()
	end
	
	function playdate.deviceWillSleep()
		gameController:saveGame()
	end
		
	gameController:startGame()
end

runGame()