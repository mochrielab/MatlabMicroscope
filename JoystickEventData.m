classdef (ConstructOnLoad) JoystickEventData < event.EventData
   properties
      xspeed
      yspeed
      zspeed
   end
   
   methods
      function data = ToggleEventData(xspeed,yspeed,zspeed)
         data.xspeed=xspeed;
         data.xspeed=yspeed;
         data.xspeed=zspeed;
      end
   end
end