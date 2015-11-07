classdef RGBlight < Lightsource
    % class for sola light, fluorescent illumination
    %  Yao Zhao 11/7/2015
    
    properties
    end
    
    methods
        
        function obj = RGBlight(nidaq,niport,comport)
            % add ni channel
            obj.nidaq=nidaq;
            ch=obj.nidaq.addDigitalChannel('Dev1',niport,'OutputOnly');
            ch.Name = 'RGB';
            % add com port control
            try
%                 obj.com = serial(comport);
                disp('RGB connected!')
            catch 
                warning('RGB illuminator! not connected to com port');
            end
        end
        
        function setExposure(obj,exposure)
            obj.exposure = exposure;
        end
        
        function setIntensity(obj,intensity)
        end
        
        function turnOn(obj)
        end
        
        function turnOff(obj)
        end
        
        function delete(obj)
            fclose(obj.com);
        end
    end
    
end

