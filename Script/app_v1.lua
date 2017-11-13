--connect to Access Point (DO NOT save config to flash)
station_cfg={}
station_cfg.ssid="yourssid"
station_cfg.pwd="yourpwd"

mqtt_config={}
mqtt_config.host = "192.168.1.36"  
mqtt_config.port = 1883
mqtt_config.user = ""
mqtt_config.pwd = ""
mqtt_config.clientid = node.chipid()
mqtt_config.endpoint = "nodemcu/"

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
    m:on("connect", function(client)
        print("Connected to broker")
        -- subscribe topic with qos = 0        
        client:subscribe(mqtt_config.endpoint .. "ping",0,function(conn) print("Successfully subscribed to " .. mqtt_config.endpoint .. "ping") end)
        -- Sends a simple ping to the broker
        local function send_ping()  
            client:publish(mqtt_config.endpoint .. "ping","id=" .. mqtt_config.clientid,0,0,function(conn) print("Ping sent") end )
        end
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end)
    m:on("offline", function(client) print ("offline") end)
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        -- do something, we have received a message
      end
    end)
    
    -- Connect to broker
    m:connect(mqtt_config.host, mqtt_config.port, 0,nil ,
    function(client, reason)
        print("failed reason: " .. reason)
    end)
end


--MAIN
wifi_start()
