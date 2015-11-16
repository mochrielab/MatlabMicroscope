classdef (ConstructOnLoad) JoystickEventData < event.EventData
   properties
      xspeed
      yspeed
      zspeed
      isadjustedtolooprate
   end
   
   methods
      function data = ToggleEventData(xspeed,yspeed,zspeed,isadjustedtolooprate)
         data.xspeed=xspeed;
         data.xspeed=yspeed;
         data.xspeed=zspeed;
         data.isadjustedtolooprate=isadjustedtolooprate;
      end
   end
end