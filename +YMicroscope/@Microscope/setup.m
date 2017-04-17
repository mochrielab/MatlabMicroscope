function setup( obj )
%initial setup of all devices

import YMicroscope.*

display('initializing...')
% add camera
obj.camera = CameraAndorZyla ();
% add trigger
obj.trigger=TriggerNidaq();

try
    % add light sources
    obj.lightsources=[LightsourceRGB('com6','brightfield'),...
        LightsourceSola('com3','fluorescent'),...
        Lightsource473nm(obj.trigger,'laser473'),...
        Lightsource560nm('com4','laser560',obj.trigger)]; % 04/17/17 SEP
    disp('Lasers=ON')
catch % need to test this out - turn off lasers and try to restart program
    obj.lightsources=[LightsourceRGB('com6','brightfield'),...
        LightsourceSola('com3','fluorescent')]; % 1/24/17 SEP
    disp('Lasers=OFF')
end

obj.lightsource = obj.lightsources(1);
% set current illumination model
% obj.illumination_options={obj.lightsources.label};
obj.illumination=obj.illumination_options{4};
obj.camera.setExposure(obj.getLightsource.exposure);
% add xy stage
obj.xystage = StageXYPrior('com5');
% add z stage
obj.zstage = StageZPrior(obj.trigger, 3, 61, 1);
% add joystick
obj.controllers = [ControllerJoystickLogitech()];
obj.controller = obj.controllers(1);
% set status
obj.setStatus('idle');
display('done')
end

