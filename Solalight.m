classdef Solalight < Lightsource
    % class for sola light, fluorescent illumination
    %  Yao Zhao 11/7/2015
    
    properties (Constant)
        color_options = {'all'}
    end
    
    methods
        
        function obj = Solalight(comport,label)
            % add com port control
            try
                obj.label=label;
                obj.com = serial(comport);
                fopen(obj.com);
                fprintf(obj.com,'%s',char([hex2dec('57') hex2dec('02') hex2dec('FF') hex2dec('50')]));
                fprintf(obj.com,'%s',char([hex2dec('57') hex2dec('03') hex2dec('AB') hex2dec('50')]));
                obj.color=obj.color_options{1};
                disp('Sola connected!')
            catch exception
                warning(['Sola illuminator! not connected to com port:',...
                    exception.message]);
            end
        end
        
        function didset=setExposure(obj,exposure)
            if exposure < 0
               warning('negative exposure')
               didset=false;
            else
                obj.exposure = exposure;
                notify(obj,'ExposureDidSet');
                didset=true;
            end
        end
        
        function didset=setIntensity(obj,intensity)
            % choose between 0-255
            if intensity<0
                obj.intensity=0;
                warning('zoffset goes below zero');
                didset=false;
                return;
            elseif intensity>255
                obj.intensity=255;
                warning('zoffset goes above 255');
                didset=false;
                return;
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
            didset=true;
        end
        
        
        function didset=setColor(obj,color)
            warning('color mode not supported');
            didset=false;
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

