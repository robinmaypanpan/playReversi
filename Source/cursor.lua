import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'lib/AnimatedSprite'

local gfx = playdate.graphics

class('Cursor').extends(AnimatedSprite)

function Cursor:init(spaceSize)	
	Cursor.super.init(self, gfx.imagetable.new('images/cursor'))
	self.spaceSize = spaceSize;
	
	self:addState('valid', 1, 3, {tickStep = 5, yoyo = true})
	self:addState('invalid', 4, 5, {tickStep = 13})
	self:setZIndex(20)
end

function Cursor:drawCursor()
	local cursorSize = self.spaceSize + 20
	local cursorImage = gfx.image.new(cursorSize, cursorSize)
	gfx.pushContext(cursorImage)		
		gfx.setColor(gfx.kColorBlack)
		
		if (self.isValid == false) then
			gfx.setDitherPattern(0.4)
			gfx.fillRect(0,0,cursorSize, cursorSize)
		end
		
		gfx.setDitherPattern(0)
		gfx.setLineWidth(10)
		gfx.drawRect(0, 0, cursorSize, cursorSize)
		
	gfx.popContext()
	return cursorImage
end

function Cursor:setValidPosition(isValid)
	self.isValid = isValid
	if (isValid) then
		self:changeState('valid', true)
	else
		self:changeState('invalid', true)
	end
end