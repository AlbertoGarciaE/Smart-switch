-- Config of WiFi
station_cfg={}
station_cfg.ssid="yourssid"
station_cfg.pwd="yourpass"
-- Config mqtt
mqtt_config={}
mqtt_config.host = "192.168.1.47"  
mqtt_config.port = 1883
mqtt_config.user = ""
mqtt_config.pwd = ""
mqtt_config.clientid = node.chipid()
mqtt_config.endpoint = "nodemcu/"
-- Config led pinout
-- IO index 	ESP8266 pin
-- 0	GPIO16
-- 1	GPIO5
-- 2	GPIO4
-- 3	GPIO0
-- 4	GPIO2
-- 5	GPIO14
-- 6	GPIO12
-- 7	GPIO13
-- 8	GPIO15 
-- 9	GPIO3
-- 10	GPIO1
-- 11	GPIO9
-- 12	GPIO10
-- No support for open-drain/interrupt/pwm/i2c/ow.
-- [*] D0(GPIO16) can only be used as gpio read/write.
blue_led = 4 --GPIO2 onboard blue led
