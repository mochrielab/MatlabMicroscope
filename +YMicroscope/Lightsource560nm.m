classdef Lightsource560nm < YMicroscope.Lightsource
    % class for 560nm laser, fluorescent illumination
    % 01/23/17 - SEP
    
    properties (Access = protected)
        trigger
    end
    
    properties (Constant)
        color_options = {'all'}
    end
    
    methods
        
        function obj = Lightsource560nm(comport,label,trigger)
            % add com port control
            obj.label=label;
            obj.com = serial(comport);
            obj.trigger = trigger;
            try
                fopen(obj.com);
            catch
                exception=MException('Lightsource:NotConnectedCOM',...
                    'com port not connected');
                throw(exception);
            end
            set(obj.com,'Terminator','CR');
            obj.color=obj.color_options{1};
            obj.setExposure(100);
            obj.setPower(100);
            
            % 04/17/17 SEP
            fprintf(obj.com,'SETLDENABLE 1');
            fprintf(obj.com,'POWERENABLE 1');
            fprintf(obj.com,'SETPOWER 0 100');
            
            disp('560nm connected!')
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
        end
        
        function setPower(obj,power)
        % choose between 100-1000mW **CHECK this section to make sure it's
        % working exactly as desired!! 01/25/17 SEP
            if power<100
                exception=MException('Lightsource:InvalidPower',...
                    ['power ',num2str(power),' not supported']);
                throw(exception);
            elseif power>1000
                exception=MException('Lightsource:InvalidPower',...
                    ['power ',num2str(power),' not supported']);
                throw(exception);
            else
                obj.power=power;
            end
            cmd560 = ['SETPOWER 0 ',num2str(obj.power)];
            fprintf(obj.com,cmd560);
            notify(obj,'PowerDidSet');
        end
        
        
        function setColor(obj,color)
            if strcmp(color,'all')
            else
                exception=MException('Lightsource:UnsupportedColor',...
                    ['color ',color,' not supported']);
                throw(exception);
            end
        end
        
        function turnOn(obj)
            obj.trigger.setState('shutter560',1); % 04/17/17 SEP
%             fprintf(obj.com,'SETLDENABLE 1');
%             fprintf(obj.com,'POWERENABLE 1'); 
%             fprintf(obj.com,'SETPOWER 0 100'); 
            obj.ison=true;
        end
        
        function turnOff(obj)
            obj.trigger.setState('shutter560',0); % 04/17/17 SEP
%             fprintf(obj.com,'SETLDENABLE 0'); % turn off 560nm laser (later will be controlling shutter)
            obj.ison=false;
        end
        
        function delete(obj)
            try
                fprintf(obj.com,'SETLDENABLE 0'); % turn off 560nm laser
                fclose(obj.com);
                display('560nm laser disconnected')
            end
        end
    end
    
end

