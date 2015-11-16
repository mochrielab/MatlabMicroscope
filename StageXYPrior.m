classdef StageXYPrior < handle
    %Prior XY stage
    
    properties (SetAccess = private)
        com
        pos_x = 0
        pos_y = 0
        pos_movespeed
    end
    
    methods
        function obj=StageXYPrior(com)
            try
                obj.com = serial(com);
                fopen(obj.com);
                set(obj.com,'Terminator','CR');
                set(obj.com,'timeout',1);
                obj.getPosition;
                disp('prior stage connected!')
            catch exception
                warning(['Prior XY Stage not connected:',...
                    exception.message]);
            end
            
        end
        
        function [ pos ] = getPosition( obj )
            %get the XY position of the prior stage
            try
                availablebytes=obj.com.BytesAvailable;
                if availablebytes>0
                    fread(obj.com, availablebytes)
                end
                
                fprintf(obj.com,'%s\r','PS'); % send new request
                pos = fscanf(obj.com); % read position
                % process position
                pos = strsplit(pos,',');
                x=str2double(pos{1});
                y=str2double(pos{2});
                if ~isnan(x) && ~isnan(y);
                    obj.pos_x = x;
                    obj.pos_y = y;
                    pos=[x,y];
                else
                    warning('read stage position unsuccessful');
                end
            catch error
                warning(['read stage error: ',error.message]);
            end
        end
        
        function setSpeed(obj,vx,vy)
            obj.sendCommand(['VS,',num2str(vx),',',num2str(vy)]);
        end
        
        function [ out ] = sendCommand( obj, str )
        % send stage command, and get feed back
            fprintf(obj.com,'%s\r',str);
            % wait and load
            out=fscanf(obj.com);
            % load rest
            while get(obj.com,'BytesAvailable')>0
                out=[out,fscanf(obj.com)];
            end
            % display(out);
        end

        function delete(obj)
            fclose(obj.com);
            display('Prior XY stage disconnected');
        end
        
    end
    
end

