classdef LightsourceSola < Lightsource
    % class for sola light, fluorescent illumination
    %  Yao Zhao 11/7/2015
    
    properties (Constant)
        color_options = {'all'}
    end
    
    methods
        
        function obj = LightsourceSola(comport,label)
            % add com port control
            obj.label=label;
            obj.com = serial(comport);
            fopen(obj.com);
            fprintf(obj.com,'%s',char([hex2dec('57') hex2dec('02') hex2dec('FF') hex2dec('50')]));
            fprintf(obj.com,'%s',char([hex2dec('57') hex2dec('03') hex2dec('AB') hex2dec('50')]));
            obj.color=obj.color_options{1};
            obj.setExposure(100);
            obj.setIntensity(30);
            disp('Sola connected!')
        end
        
        function setExposure(obj,exposure)
            if exposure < 0
                exception=MException('Lightsource:NegativeExposure','negative exposure');
               throw(exception);
            else
                obj.exposure = exposure;
                notify(obj,'ExposureDidSet');
            end
        end
        
        function setIntensity(obj,intensity)
            % choose between 0-255
            if intensity<0
                exception=MException('Lightsource:InvalidIntensity',...
                    ['intensity ',num2str(intensity),' not supported']);
                throw(exception);
            elseif intensity>255
                exception=MException('Lightsource:InvalidIntensity',...
                    ['intensity ',num2str(intensity),' not supported']);
                throw(exception);
            else
                obj.intensity=intensity;
            end
            s=dec2hex(255-obj.intensity);
            if length(s)==1
                s=['0',s];
            end
            fprintf(obj.com,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') ...
                hex2dec('04') hex2dec(['F',s(1)]) hex2dec([s(2),'0']) hex2dec('50')]));
            notify(obj,'IntensityDidSet');
        end
        
        
        function setColor(obj,color)
            if strcmp(color,'All')
            else
                exception=MException('Lightsource:UnsupportedColor',...
                    ['color ',color,' not supported']);
                throw(exception);
            end
        end
        
        function turnOn(obj)
            fprintf(obj.com,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
            obj.ison=true;
        end
        
        function turnOff(obj)
            fprintf(obj.com,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
            obj.ison=false;
        end
        
        function delete(obj)
            display('sola light disconnected')
            fclose(obj.com);
        end
    end
    
end

