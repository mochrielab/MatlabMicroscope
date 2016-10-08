import YMicroscope.*
%% test constructor
cam = CameraAndorZyla();
display('camera successfully loaded')
%% test exposure
for i = 0:100:400
    cam.setExposure(i);
    display(['exposure successfully set for ',num2str(i)]);
end
%% test roi options
for i = 1:length(cam.roi_options)
    roi = cam.roi_options{i};
    cam.setRoi(roi)
    display(['roi successfully set for ',roi]);
end
%% test image capture
cam.prepareModeSnapshot();
img = cam.capture();
display('image capture successful');
%% test image sequence
% cam.prepareModeSequence();
% cam.startSequenceAcquisition();
% cam.stopSequenceAcquisition();
% cam.getLastImage();
% cam.popNextImage();
% display('image capture successful');
%% print spect
cam.printCameraProperties()
display('camera spects printed');
%% 
cam.getTiffTag()
display('tiff tag printed')

%% test delete camera
delete(cam)
display('delete camera successful');
