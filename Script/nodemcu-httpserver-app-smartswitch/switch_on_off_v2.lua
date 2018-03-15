-- switch_on_of_v2.lua
-- Used with nodemcu-httpserver to activate a relay shield
-- Author: Alberto García

local function getSwitchStatus()
   if gpio.read(relay_pin) == 0 then return 'OFF' else return 'ON' end
end

local function setSwitchState(state)
	if state == "ON" then
		print("switch on led " .. blue_led)
		gpio.write(relay_pin, gpio.HIGH)
	elseif state == "OFF" then
		print("switch off led " .. blue_led)
		gpio.write(relay_pin, gpio.LOW)
	else
		print("Unrecognize state value=" .. state)
	end	
end

local function sendResponse(connection, httpCode, errorCode, action, message)
   connection:send("HTTP/1.0 "..httpCode.." OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":'..errorCode..',"action":"'..action..'", "message":"'..message..'","status":"'..getSwitchStatus()..'"}')
end


local function sendStatus(connection, httpCode, errorCode, action)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":'..errorCode..',"action":"'..action..'","status":"'..getSwitchStatus()..'"}')
end



return function (connection, req, args)

	relay_pin = 3 --GPIO0
	gpio.mode(relay_pin,gpio.OUTPUT)
	
	if args.action == "switch" then
      setSwitchState(args.state)
	  sendResponse(connection, 200, 0, args.action.."-"..args.state, "You switched the Smart Switch "..args.state)
      return
	end
	
	if args.action == "status" then
      sendStatus(connection,200, 0, args.action)
      return
    end
	
	-- everything else is error   
    sendResponse(connection, 400, -5, args.action,"Bad action")
	
end
