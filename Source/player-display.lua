import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

class('PlayerDisplay').extends(gfx.sprite)

local width = 70
local height = 200
local font = gfx.font.new('assets/fonts/Bubble-Time')
local numberFont = gfx.font.new('assets/fonts/Bubble-Time')

function PlayerDisplay:init(name)
	PlayerDisplay.super.init(self)
	self.score = 0
	self.name = name
	self:setImage(self:drawDisplay())
	self:setCenter(0,0)
end

function PlayerDisplay:setScore(newScore)
	self.score = newScore
	self:setImage(self:drawDisplay())
end

function PlayerDisplay:drawDisplay()
	local image = gfx.image.new(width, height)
	gfx.pushContext(image)
		gfx.setColor(gfx.kColorBlack)
		
		-- Draw the background first
		gfx.drawRect(0, 0, width, height)
		
		-- Now draw the name and score
		gfx.setFont(font)
		gfx.drawTextAligned(self.name, width / 2,5,kTextAlignment.center)
		
		gfx.drawTextAligned(self.score, width / 2,55,kTextAlignment.center)
		
	gfx.popContext()
	return image
end

