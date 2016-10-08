classdef EventLoop < handle
    % user created event loop
    % the loop is used for detecting event
    % Yao Zhao 11/9/2015
    
    properties (Access = protected)
        rate = 10;
        isrunning
    end
    
    methods
        function obj = EventLoop(rate)
            obj.rate=rate;
            obj.isrunning=false;
        end
        
        % run the loop
        function run(obj,callback)
            obj.isrunning=true;
%             lh=addlistener(obj,'StopLoop',@(hobj,eventdata)callbackStop(hobj));
            while obj.isrunning
                callback();
                pause(1/obj.rate);
            end
%             delete(lh);
%             function callbackStop (obj)
%                 obj.isrunning=false;
%             end
        end
        
        % stop loop
        function stop(obj)
%             notify(obj,'StopLoop');
            obj.isrunning=false;
        end
        
        % set loop rate
        function setRate(obj,rate)
            obj.rate=rate;
        end
        
        % get rate
        function rate = getRate(obj)
            rate = obj.rate;
        end
    end
    
    events
        StopLoop
    end
    
end

