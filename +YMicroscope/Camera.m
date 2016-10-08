classdef Camera < handle
    % basic camera class
    
    properties (SetAccess = protected)
        label
        exposure
        roi
    end
    
    methods (Abstract)
        capture(obj)
        setExposure(obj, exposure_input)
        getSize(obj)
        setRoi(obj, roi_input)
        prepareModeSnapshot (obj)
        prepareModeSequence (obj)
        startSequenceAcquisition(obj)
        stopSequenceAcquisition(obj)
        popNextImage(obj)
        getLastImage(obj)
        printCameraProperties(obj)
        getTiffTag(obj)
    end
    
    events
        RoiDidSet
        ExposureDidSet
    end
end

