function setup( obj )
%initial setup of all devices

import YMicroscope.*

display('initiallizing...')
% add camera
obj.camera = CameraAndorZyla ();
% add trigger
obj.trigger=TriggerNidaq();
% add light sources
obj.lightsources=[LightsourceRGB('com6','brightfield'),...
    LightsourceSola('com3','fluorescent')];
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

