classdef LightsourceRGB < YMicroscope.Lightsource
    % class for RGB light made by MVI
    %  Yao Zhao 11/7/2015
            
    properties (Constant)
        color_options = {'Red','Green','Blue','White'};
    end
    
    methods
        
        % constructor
        function obj = LightsourceRGB(comport, label)
            % add com port control
            obj.label=label;
            obj.com = serial(comport);
            fopen(obj.com);
            fprintf(obj.com,'%s\r','*OA');
            obj.setColor('White');
            obj.setExposure(40);
            obj.setIntensity(1);
            disp('RGB light connected')
        end
        
        % setExposure
        function setExposure(obj,exposure)
            if exposure < 0
                exception=MException('Lightsource:NegativeExposure','negative exposure');
               throw(exception);
            else
                obj.exposure = exposure;
                notify(obj,'ExposureDidSet');
            end
        end
        
        % setColor
        function setColor(obj, color)
            for i=1:length(obj.color_options)
                if strcmp(color,obj.color_options{i})
                    obj.color=color;
                    if obj.ison
                        obj.turnOff;
                        obj.turnOn;
                    end
                    notify(obj,'ColorDidSet');
                    return;
                end
            end
            exception=MException('Lightsource:UnsupportedColor',...
                ['color ',color,' not supported']);
            throw(exception);
        end
        
        % setIntensity
        function setIntensity(obj,intensity)
            % choose between 1-10
            for i=1:10
                if intensity == i
                    obj.intensity=intensity;
                    fprintf(obj.com,'%s\r',['*D',num2str(10-i)]);
                    notify(obj,'IntensityDidSet');
                    return;
                end
            end
            exception=MException('Lightsource:InvalidIntensity',...
                ['intensity ',num2str(intensity),' not supported']);
            throw(exception);
        end
        
        % turn on the light
        function turnOn(obj)
            code = obj.decodeColor();
            for i=1
                if ~isempty(code)
                    fprintf(obj.com,'%s\r',['*O',code]);
                end
            end
            obj.ison=true;
            notify(obj,'DidTurnOn');
        end
        
        % turn off the light
        function turnOff(obj)
            fprintf(obj.com,'%s\r','*FT');
            obj.ison=false;
            notify(obj,'DidTurnOn');
        end
        
        % delete
        function delete(obj)
            fprintf(obj.com,'%s\r','*FA');
            fclose(obj.com);
            disp('RGB light disconnected');
        end
        
        % decode color for com port command
        function code = decodeColor(obj)
            switch obj.color
                case 'Red'
                    code = 'R'; return
                case 'Green'
                    code = 'G'; return
                case 'Blue'
                    code = 'B'; return
                case 'White'
                    code = 'T'; return
            end
            warning('invalid color')
        end
    end
    
end

