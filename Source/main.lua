import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/pulp-audio"

import 'board'
import 'player-display'
import 'players/human-player'
import 'players/random-ai'
import 'players/minimax-ai'
import 'game-controller'
import 'state-generator'

-- Save typing!
local gfx = playdate.graphics
local audio = pulp.audio

-- UI elements we construct here and give control to the game controller
local board
local whiteDisplay
local blackDisplay

-- Game state inputHandlers
local gameController

local showDebugElements = true

-- Sets up the game board display
function setupBoard()
	board = Board()
	
	local screenWidth = playdate.display.getWidth()
	local screenHeight = playdate.display.getHeight()
	board:moveTo(screenWidth / 2, screenHeight / 2)
	
	board:add()
end

-- Sets up the display of the game
function setupGame()
	-- Setup the player displays first	
	local pieceTable = gfx.imagetable.new('assets/images/piece')
	local whitePieceImage = pieceTable[1]
	local blackPieceImage = pieceTable[7]
	
	whiteDisplay = PlayerDisplay('LIGHT', whitePieceImage)
	whiteDisplay:add()
	whiteDisplay:moveTo(10,15)
	
	blackDisplay = PlayerDisplay('DARK', blackPieceImage)
	blackDisplay:add()
	blackDisplay:moveTo(320,15)
	
	setupBoard()
	board:addCursor()
	
	math.randomseed(playdate.getSecondsSinceEpoch())
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

-- Change the white player and restart
function changeWhitePlayer(newPlayerString)
	gameController.whitePlayer:shutDown()
	
	local newPlayer
	if (newPlayerString == 'Human') then
		newPlayer = HumanPlayer(gameController, WHITE)
	elseif (newPlayerString == 'Easy AI') then
		newPlayer = RandomAi(gameController, WHITE)
	elseif (newPlayerString == 'Hard AI') then
		newPlayer = MinimaxAi(gameController, WHITE)
	else
		error('No Player returned')
	end
	
	gameController.whitePlayer = newPlayer
	gameController:restartGame()
end

-- Change the black player and restart
function changeBlackPlayer(newPlayerString)
	gameController.blackPlayer:shutDown()
	
	local newPlayer
	if (newPlayerString == 'Human') then
		newPlayer = HumanPlayer(gameController, BLACK)
	elseif (newPlayerString == 'Easy AI') then
		newPlayer = RandomAi(gameController, BLACK)
	elseif (newPlayerString == 'Hard AI') then
		newPlayer = MinimaxAi(gameController, BLACK)
	else
		error('No Player returned')	
	end
	
	gameController.blackPlayer = newPlayer
	gameController:restartGame()
end

-- Runs the game
function runGame()
	audio.init('assets/audio/pulp-songs.json', 'assets/audio/pulp-sounds.json')
	
	playdate.setMinimumGCTime(5)
	
	setupGame()
	
	gameController = GameController(board, whiteDisplay, blackDisplay)
	gameController.whitePlayer = HumanPlayer(gameController, WHITE)
	gameController.blackPlayer = MinimaxAi(gameController, BLACK)
	
	stateGenerator = StateGenerator(gameController.gameState)
	
	-- Update the system menu with our options
	playdate:getSystemMenu():addMenuItem('Restart Game', restartGame)
	playdate:getSystemMenu():addOptionsMenuItem('White', playerOptions,'Human', changeWhitePlayer)
	playdate:getSystemMenu():addOptionsMenuItem('Black', playerOptions, 'Hard AI', changeBlackPlayer)
	
	-- Standard main game loop
	function playdate.update()
		frameStartTime = playdate.getCurrentTimeMilliseconds()
		gfx.sprite.update()
		audio.update() 
		playdate.timer.updateTimers()
		stateGenerator:update()
		
		if (showDebugElements) then
			playdate.drawFPS(10, 220)
			playdate.graphics.drawTextAligned(stateGenerator.depth .. '-' .. stateGenerator.treeSize, playdate.display.getWidth() - 20, 220, kTextAlignment.right)
		end
	end
		
	gameController:startGame()
end

runGame()