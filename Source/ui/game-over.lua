import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

class('GameOver').extends(gfx.sprite)

local width = 350
local height = 150
local font = gfx.font.new('assets/fonts/Picory')
local numberFont = gfx.font.new('assets/fonts/Picory')

function GameOver:init(winnerName, winnerScore, loserScore)	
	GameOver.super.init(self)
	
	local image = gfx.image.new(width, height)
	
	self:setImage(image)
	
	gfx.pushContext(image)
		gfx.setColor(gfx.kColorWhite)
		
		-- Draw the background
		gfx.fillRect(0, 0, width, height)
				
		gfx.setColor(gfx.kColorBlack)
		
		-- Draw the background outline
		gfx.setLineWidth(5)
		gfx.drawRect(0, 0, width, height)		
		
		-- Now draw the name and score
		gfx.setFont(font)
		gfx.drawTextAligned(winnerName .. ' wins!', width / 2,20,kTextAlignment.center)
		
		gfx.setFont(numberFont)
		gfx.drawTextAligned(winnerScore .. ' to ' .. loserScore, width / 2,50,kTextAlignment.center)
		
		-- Call to action		
		gfx.setFont(font)
		gfx.drawTextAligned('Press Ⓐ to restart game!', width / 2,110,kTextAlignment.center)
		
	gfx.popContext()
end


