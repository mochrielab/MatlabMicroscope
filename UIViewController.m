classdef UIViewController < UIView
    %UIView Controller to control the UIView
    % Yao Zhao, 11/9/2015
    
    properties
        microscope_handle
    end
    
    methods
        function obj = UIViewController(microscope_handle)
            obj@UIView();
            obj.microscope_handle=microscope_handle;
            % add controls
            obj.addControlButton(0,0,'live','Live',[]);
            obj.addControlButton(1,0,'capture','Capture',[]);
            obj.addControlButton(2,0,'zstack','Zstack',[]);
            obj.addControlButton(3,0,'movie','Movie',[]);
            obj.addControlButton(0,1,'light','Light',[]);
            obj.addControlButton(1,1,'joystick','JoysTick',[]);
            obj.addControlButton(2,1,'zfocus','ZFocus',[]);
            % add selectors
            
            % add parameters
            obj.addPanelCell(0,0,'brightfield exposure',...
                'brightfield exposure(ms)',[])
            obj.addPanelCell(0,1,'brightfield intensity',...
                'brightfield itensity(1-10)',[])
            obj.addPanelCell(0,2,'fluorescence exposure',...
                'fluorescence exposure(ms)',[])
            obj.addPanelCell(0,3,'fluorescence intensity',...
                'fluorescence itensity(0-255)',[])

        end
    end
    
end

