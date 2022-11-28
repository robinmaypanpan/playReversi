import "CoreLibs/object"
import 'CoreLibs/sprites'

local gfx = playdate.graphics

class('PlayerDisplay').extends(gfx.sprite)

local width = 70
local height = 200
local font = gfx.font.new('assets/fonts/Picory')
local numberFont = gfx.font.new('assets/fonts/Picory')

function PlayerDisplay:init(name, pieceImage)
	PlayerDisplay.super.init(self)
	self.score = 0
	self.name = name
	self.isActive = false
	self.pieceImage = pieceImage
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
		gfx.setColor(gfx.kColorWhite)
		
		-- Draw the background
		gfx.fillRect(0, 0, width, height)
				
		gfx.setColor(gfx.kColorBlack)
		
		-- Draw the background outline
		gfx.setLineWidth(3)
		gfx.drawRect(0, 0, width, height)
		
		-- Now draw the name and score
		gfx.setFont(font)
		gfx.drawTextAligned(self.name, width / 2,8,kTextAlignment.center)
		
		gfx.setFont(numberFont)
		gfx.drawTextAligned(self.score, width / 2,55,kTextAlignment.center)
		
		-- Last, the player indicator
		if (self.isActive) then
			self.pieceImage:draw(width / 2 - 12.5, 150)
		end
		
	gfx.popContext()
	return image
end

function PlayerDisplay:setActive(isActive)
	self.isActive = isActive
	self:setImage(self:drawDisplay())
end

