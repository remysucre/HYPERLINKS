import "CoreLibs/graphics"
import "CoreLibs/sprites"

local gfx = playdate.graphics
local geo = playdate.geometry

local pageHeight = 0
local links = {}
local hoveredLink = nil

local fnt = gfx.font.new("fonts/Asheville-Sans-14-Bold")
gfx.setFont(fnt)

-- print(txt.format)
-- 
-- local testText, truncated = gfx.sprite.spriteWithText(txt.format, 400, 400)

-- testText:moveTo(200, 120)
-- testText:add()

-- viewport
local viewportTop = 0

local page = gfx.sprite.new()
page:setSize(100, 100)
page:moveTo(200, 120)
page:add()

page.padding = 10
page.width = 400 - 2 * page.padding
page.tail = 30

-- cursor
local cursor = gfx.sprite.new()
cursor:moveTo(200, 120)
cursor:setSize(25, 25)
cursor:setZIndex(32767)
cursor:add()

cursor.vx = 0
cursor.vy = 0
cursor.thrust = 0.5
cursor.maxSpeed = 4
cursor.friction = 0.95

function layout(orb)
		
	local content = orb.content
	local x = 0
	local y = 0
	local toDraw = {}
	for word in string.gmatch(content, "%S+") do
		local w, h = gfx.getTextSize(word)
		if x + w > page.width then
			y += h
			x = 0
		end
		table.insert(toDraw, {
			txt = word, 
			x = x, 
			y = y
		})
		x += w
		
		local sw = fnt:getTextWidth(" ")
		if x + sw <= page.width then
			table.insert(toDraw, {
				txt = " ",
				x = x,
				y = y
			})
			x += sw
		end
	end
	
	pageHeight = y + page.tail
	
	local pageImage = gfx.image.new(page.width, pageHeight)
	gfx.lockFocus(pageImage)
	
	for _, cmd in ipairs(toDraw) do
		gfx.drawText(cmd.txt, cmd.x, cmd.y)
	end
	
	gfx.unlockFocus()
	page:setImage(pageImage)
	page:moveTo(200, page.padding + pageHeight / 2)
end

local orb = json.decode([[
	{
		"content": "welcome, the entire land"
	}
	]])

layout(orb)

function cursor:draw(x, y, width, height)
	local w, h = self:getSize()
	
	local moon = geo.point.new(math.floor(w/2)+1, h-3)
	
	local tran = geo.affineTransform.new()
	tran:rotate(playdate.getCrankPosition(), math.floor(w/2)+1, math.floor(h/2)+1)
	tran:transformPoint(moon)
	
	local x, y = moon:unpack()
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(x-4, y-4, 7, 7)
	gfx.fillRect(7, 7, 11, 11)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillRect(x-2, y-2, 3, 3)
	gfx.fillRect(9, 9, 7, 7)
end

function playdate.update()
			
	local crankChange = playdate.getCrankChange()
	if crankChange ~= 0 then
		cursor:markDirty()
	end

	if playdate.buttonIsPressed(playdate.kButtonUp) then
		local radians = math.rad(playdate.getCrankPosition() - 90)  -- Adjust for 0° being up
		
		cursor.vx = cursor.vx + math.cos(radians) * cursor.thrust
		cursor.vy = cursor.vy + math.sin(radians) * cursor.thrust
	end
	
	if cursor.vx ~= 0 or cursor.vy ~= 0 then
		cursor.vx = cursor.vx * cursor.friction
		cursor.vy = cursor.vy * cursor.friction
		
		local speed = math.sqrt(cursor.vx * cursor.vx + cursor.vy * cursor.vy)
		if speed > cursor.maxSpeed then
			cursor.vx = (cursor.vx / speed) * cursor.maxSpeed
			cursor.vy = (cursor.vy / speed) * cursor.maxSpeed
		end
		
		local curX, curY = cursor:getPosition()
		local toX = curX + cursor.vx
		local toY = math.max(0, curY + cursor.vy)
		
		if toY < viewportTop then
			gfx.setDrawOffset(0, 0 - toY)
			viewportTop = toY
		end
		
		if toY > viewportTop + 240 then
			gfx.setDrawOffset(0, 240 - toY)
			viewportTop = toY - 240
		end
		
		cursor:moveTo(toX % 400, toY)
	end

	gfx.sprite.update()	
end