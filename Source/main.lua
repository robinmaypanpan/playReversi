import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/pulp-audio"

import 'board'
import 'player-display'
import 'players/human-player'
import 'players/random-ai-player'
import 'game-controller'

-- Save typing!
local gfx = playdate.graphics
local vector2D = playdate.geometry.vector2D
local audio = pulp.audio

-- UI elements we construct here and give control to the game controller
local board
local whiteDisplay
local blackDisplay

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

-- Get the party started
audio.init('assets/audio/pulp-songs.json', 'assets/audio/pulp-sounds.json')
setupGame()

local gameController = GameController(board, whiteDisplay, blackDisplay)
gameController.whitePlayer = HumanPlayer(gameController)
gameController.blackPlayer = AiRandy(gameController)

gameController:startGame()

-- Update the system menu with our options
local menuItem,error = playdate:getSystemMenu():addMenuItem("Restart Game", restartGame)

-- Standard main game loop
function playdate.update()
	gfx.sprite.update()
	playdate.timer.updateTimers()
	audio.update() 
end