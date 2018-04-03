local ok,e = pcall(dofile,"config.lua")
if not ok then
  -- handle error; e has the error message
  print ("ERROR loading config " .. e)
end


function wifi_start()  
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    wifi.sta.connect()
    print("Connecting to " .. station_cfg.ssid .. " ...")
    --config.SSID = nil  -- can save memory
    tmr.alarm(1, 2500, 1, wifi_wait_ip)
end

function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    mqtt_start()
  end
end

function mqtt_start()
    -- init mqtt client with logins, keepalive timer 120sec  
    m = mqtt.Client(mqtt_config.clientid, 120, mqtt_config.user, mqtt_config.pwd)
    -- register message callback beforehand
    -- Calling subscribe/publish only makes sense once the connection
    -- was successfully established. You can do that either here in the
    -- 'connect' callback or you need to otherwise make sure the
    -- connection was established (e.g. tracking connection status or in
    -- m:on("connect", function)).
    m:on("connect", handle_connect)
    m:on("offline", handle_offline)
    m:on("message", handle_message)
    
    -- Connect to broker
    m:connect(mqtt_config.host, mqtt_config.port, 0, nil,
    function(client, reason)
        print("failed reason: " .. reason)
    end)
end

function handle_connect(client)
	print("Connected to broker")
	-- subscribe topic with qos = 0        
	client:subscribe(mqtt_config.endpoint .. "action",0,function(client) print("Successfully subscribed to topic") end)
	client:subscribe(mqtt_config.endpoint .. "state",0,function(client) print("Successfully subscribed to topic") end)
end

local function publish_state(client)
	if gpio.read(blue_led) == 0 then
		client:publish(mqtt_config.endpoint .. "state","pin_state = ON",0,0,function(client) print("state sent") end )
	else
		client:publish(mqtt_config.endpoint .. "state","pin_state = OFF",0,0,function(client) print("state sent") end )
	end
end
	
function handle_offline(client)
	print ("offline")
end

function handle_message(client, topic, data) 
	if data ~= nil then
		print(topic .. ": " .. data)
		if topic == mqtt_config.endpoint .. "action" then
			set_pin_state(data)
			publish_state(client)
		end
	end
end
	
function set_pin_state(state)
	if state == "ON" then
		gpio.write(blue_led, gpio.LOW)
	else
    	if state == "OFF" then
    		gpio.write(blue_led, gpio.HIGH)
    	else
    		print("Unrecognize state value=" .. state)
    	end	
    end
end

function main()
	gpio.mode(blue_led, gpio.OUTPUT) -- Initialise the pin
	gpio.write(blue_led, gpio.LOW)
	wifi_start()
end
--MAIN

main()
