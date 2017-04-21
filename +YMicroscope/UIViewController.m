classdef UIViewController < YMicroscope.UIView
    %UIView Controller to control the UIView
    % Yao Zhao, 11/9/2015
    
    properties
        microscope_handle
        actions
    end
    
    methods
        function obj = UIViewController(microscope_handle)
            import YMicroscope.*
            obj@YMicroscope.UIView();
            obj.microscope_handle=microscope_handle;
            
            % 04/21/17 SEP
            obj.figure_handle.set('WindowKeyPressFcn',@(src,eventdata)keyfun(src,obj));
            
            function keyfun(src,obj)
                switch get(gcf,'CurrentKey')
                    case 'leftarrow'
%                         disp('move left') --> left
                        obj.microscope_handle.xystage.moveLeft(100);
                    case 'rightarrow'
%                         disp('move right') --> right
                        obj.microscope_handle.xystage.moveRight(100);     
                    case 'uparrow'
%                         disp('move up') --> forward
                        obj.microscope_handle.xystage.moveFwd(100);
                    case 'downarrow'
%                         disp('move down') --> back
                        obj.microscope_handle.xystage.moveBkwd(100);
                    case 'semicolon'
                        obj.microscope_handle.zstage.setZoffset(obj.microscope_handle.zstage.zoffset+0.01);
                    case 'quote'
                        obj.microscope_handle.zstage.setZoffset(obj.microscope_handle.zstage.zoffset-0.01);
                end
            end
            
            obj.actions=[ MicroscopeActionLive(...
                obj.microscope_handle,obj.imageaxis_handle,obj.hist_handle),...
                MicroscopeActionCapture(...
                obj.microscope_handle,obj.imageaxis_handle,obj.hist_handle),...
                MicroscopeActionSequenceZstack(...
                obj.microscope_handle,obj.imageaxis_handle,obj.hist_handle),...
                MicroscopeActionLiveFNet(...
                obj.microscope_handle,obj.imageaxis_handle,obj.hist_handle),...
                %                 MicroscopeActionSequenceMovieImage('movieimage',...
                %                 obj.microscope_handle,obj.imageaxis_handle),...
                %                 MicroscopeActionSequenceMovieStack('moviezstack',...
                %                 obj.microscope_handle,obj.imageaxis_handle),...
                ];
%             obj.savingFilename = TiffIO(obj.microscope_handle.datapath,'headername');
            % add controls
            for i=1:length(obj.actions)
                ir= floor((i-1)/4);
                ic= mod((i-1),4);
                obj.addControlButton(ic,ir,obj.actions(i));
            end
            
            % add refresh button for histogram
            obj.addHistRefreshButton(3,3);

            % add selectors
            obj.addControlSelector(0,2,'illumination','Illumination',...
                obj.microscope_handle);
            obj.addControlSelector(1,2,'roi','Camera ROI',...
                obj.microscope_handle.camera);
            obj.addControlSelector(0,3,'issaving','Save Captures',...
                obj.actions(2));
            obj.addControlSelector(1,3,'lockfocus','LiveFocus',...
                obj.actions(4));
            
            % add parameters
            obj.addParamCellWithExposure(0,0,'exposure','Brightfield Exposure(ms)',...
                obj.microscope_handle.lightsources(1), obj.microscope_handle.camera);
            obj.addParamCell(0,1,'intensity','Brightfield Intensity(1-10)',...
                obj.microscope_handle.lightsources(1));
            obj.addParamCellWithExposure(0,2,'exposure','Fluorescent Exposure(ms)',...
                obj.microscope_handle.lightsources(2), obj.microscope_handle.camera);
            obj.addParamCell(0,3,'intensity','Fluorescent Intensity(0-255)',...
                obj.microscope_handle.lightsources(2));
            try
            obj.addParamCellWithExposure(0,4,'exposure','473nm Laser Exposure(ms)',...
                obj.microscope_handle.lightsources(3), obj.microscope_handle.camera);
            obj.addParamCellWithExposure(0,5,'exposure','560nm Laser Exposure(ms)',...
                obj.microscope_handle.lightsources(4), obj.microscope_handle.camera);
            obj.addParamCell(0,6,'power','560nm Power(mW)',...
                obj.microscope_handle.lightsources(4));
            catch
                disp('Laser(s)=OFF')
                clc
            end
            obj.addParamCell(1,0,'zoffset','Piezo Center (volts)',...
                obj.microscope_handle.zstage);
            obj.addParamCell(1,1,'numstacks','Number of Stacks',...
                obj.microscope_handle.zstage);
            obj.addParamCell(1,2,'stepsize','Step Size (pixels)',...
                obj.microscope_handle.zstage);
            obj.addParamCell(2,0,'framerate','Frame Rate of Camera (Hz)',...
                obj.microscope_handle.trigger);
            obj.addParamCell(2,1,'clockrate','Sampling Rate of Clock (Hz)',...
                obj.microscope_handle.trigger);
%             obj.addParamCell(2,0,'moviecycles','number of movie cycles',...
%                 obj);
%             obj.addParamCell(2,1,'movieinterval','movie interval (mins)',...
%                 obj);
            obj.addParamCell(3,0,'focalplanecorrect','Focal Plane Correction (pixel)',...
                obj.actions(4));
            obj.addParamCell(3,1,'headername','Filename',...
                obj.microscope_handle);

        end
        
        function delete(obj)
            for i = 1:length(obj.actions)
                delete(obj.actions(i))
            end
            obj.delete@YMicroscope.UIView();
        end
        
    end
    
    events
    end
    
end

