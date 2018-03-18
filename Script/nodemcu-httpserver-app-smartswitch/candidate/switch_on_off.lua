-- switch_on_of.lua
-- Used with nodemcu-httpserver.
-- Author: Alberto García

local function readSwitchStatus(pinConfig)
   if gpio.read(blue_led) == 1 then return 'OFF' else return 'ON' end
end

local function setSwitchStatus(state)
	if state == "ON" then
		print("switch on led " .. blue_led)
		gpio.write(blue_led, gpio.LOW)
	elseif state == "OFF" then
		print("switch off led " .. blue_led)
		gpio.write(blue_led, gpio.HIGH)
	else
		print("Unrecognize state value=" .. state)
	end	
end

local function sendResponse(connection, httpCode, errorCode, action, message)

   -- Handle nil inputs
   if action == nil then action = '' end
   if message == nil then message = '' end

   connection:send("HTTP/1.0 "..httpCode.." OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":'..errorCode..',"action":"'..action..'", "message":"'..message..'"}')
end


local function sendStatus(connection, pinConfig)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":'..errorCode..',"action":"'..action..'", "message":"'..message..'"}')
end



return function (connection, req, args)

	blue_led = 4 --GPIO2 onboard blue led
	gpio.mode(blue_led,gpio.OUTPUT)
	setSwitchStatus(args.action)
	sendResponse(connection, 200, 0, args.action, "You pushed the Smart Switch")
	return

end
