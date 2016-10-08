classdef EventLoop < handle
    %user created event loop
    % Yao Zhao 11/9/2015
    
    properties (Access = private)
        rate = 10;
        isrunning
    end
    
    methods
        function obj = EventLoop(rate)
            obj.rate=rate;
            obj.isrunning=false;
        end
        
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
        
        function stop(obj)
%             notify(obj,'StopLoop');
            obj.isrunning=false;
        end
        
        function setRate(obj,rate)
            obj.rate=rate;
        end
        
    end
    
    events
        StopLoop
    end
    
end

