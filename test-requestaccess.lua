-- Minimal Reproducible Example for net.http.requestAccess() crash
-- Playdate SDK 3.0.1

import "CoreLibs/graphics"

local gfx = playdate.graphics
local net = playdate.network

print("Starting MRE test")
print("SDK Version: " .. playdate.metadata.sdkVersion)
print("Device: " .. playdate.metadata.deviceID)

local frameCount = 0
local accessRequested = false

function playdate.update()
	frameCount += 1

	gfx.clear()
	gfx.drawText("Frame: " .. frameCount, 10, 10)

	-- Try to request access on frame 10
	if frameCount == 10 and not accessRequested then
		print("Frame 10: About to call net.http.requestAccess()")
		accessRequested = true

		-- This line causes a crash on device
		net.http.requestAccess()

		print("Frame 10: requestAccess() returned successfully")
	end

	if frameCount > 10 then
		gfx.drawText("Access requested", 10, 30)
	end
end
