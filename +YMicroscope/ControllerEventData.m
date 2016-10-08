classdef (ConstructOnLoad) ControllerEventData < event.EventData
   properties
      xspeed
      yspeed
      zspeed
      isadjustedtolooprate
   end
   
   methods
      % constructor
      function data = ControllerEventData(xspeed,yspeed,zspeed,isadjustedtolooprate)
         data.xspeed=xspeed;
         data.yspeed=yspeed;
         data.zspeed=zspeed;
         data.isadjustedtolooprate=isadjustedtolooprate;
      end
   end
end