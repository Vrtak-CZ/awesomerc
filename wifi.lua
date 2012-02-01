function wifi(adapter)
     spacer = " "
     local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
     local wifiStrength = f:read()
     if wifiStrength == "0" then
         wifiStrength = "Network Down"
     else
         wifiStrength = "Wifi:"..spacer..wifiStrength.."%"
     end
     text = spacer..wifiStrength..spacer
     f:close()
     return text
 end

return wifi
