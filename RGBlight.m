classdef RGBlight < Lightsource
    % class for sola light, fluorescent illumination
    %  Yao Zhao 11/7/2015
            
    properties (Constant)
        color_options = {'Red','Green','Blue','White'};
    end
    
    methods
        
        function obj = RGBlight(comport)
            % add com port control
            try
                obj.com = serial(comport);
                fopen(obj.com);
                fprintf(obj.com,'%s\r','*OA');
                obj.setColor('White');
                disp('RGB light connected')
            catch 
                warning('RGB illuminator not connected to com port');
            end
        end
        
        function setExposure(obj,exposure)
            obj.exposure = exposure;
        end
        
        function setColor(obj, color)
            for i=1:length(obj.color_options)
                if strcmp(color,obj.color_options{i})
                    obj.color=color;
                    return;
                end
            end
            warning('invalid input color');
        end
        
        function setIntensity(obj,intensity)
            % choose between 1-10
            for i=1:10
                if intensity == i
                    fprintf(obj.com,'%s\r',['*D',num2str(10-i)]);
                    return;
                end
            end
            warning('invalid input intensity');
        end
        
        function turnOn(obj)
            code = obj.decodeColor;
            if ~isempty(code)
                fprintf(obj.com,'%s\r',['*O',code]);
            end
        end
        
        function turnOff(obj)
            fprintf(obj.com,'%s\r','*FT');
        end
        
        function delete(obj)
            fprintf(obj.com,'%s\r','*FA');
            fclose(obj.com);
            disp('RGB light disconnected');
        end
        
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

