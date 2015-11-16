classdef (Abstract) MicroscopeActionMovie < MicroscopeActionSequence
    %zstack class for microscope actions
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)
        icycle
        moviecycles =0;
        movieinterval =0;
    end
    
    methods
        
        % start movie acquisition
        function start(obj)
            % call super
            start@MicroscopeActionSequence(obj);
        end
        
        function setMoviecycles(moviecycles)
            if moviecycles >=0
                obj.moviecycles=moviecycles;
                notify(obj,'MoviecyclesDidSet');
            else
                throw(MException('Action:NegativeMovieCycles',...
                    'negative movie cycles'));
            end
        end
        
        function setMovieinterval(movieinterval)
            if movieinterval >=0
                obj.movieinterval=movieinterval;
                notify(obj,'MovieintervalDidSet');
            else
                throw(MException('Action:NegativeMovieInterval',...
                    'negative movie interval'));
            end
        end
        
        
        % run acquisition
        function run (obj)
            obj.start;
            % refresh cycle
            obj.icycle=1;
            % set movie interval
            obj.eventloop.setRate(1/obj.movieinterval);
            % run event loop
            obj.eventloop.run(@()callbackSingleLoop(obj));
            %finish
            obj.finish;
            % call back function
            function callbackSingleLoop (obj)
                if obj.icycle<=obj.moviecycles
                    obj.eventloop.stop;
                else
                    obj.runSingleLoop;
                end
            end
        end
                
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Zstack';
                case 'DidFinish'
                    dispstr = 'Zstack';
                otherwise
                    dispstr=getEventDisplay@MicroscopeAction(obj,eventstr);
            end
        end

    end
    
    methods (Abstract)
        % things to be done in the single loop
        runSingleLoop(obj)
    end
    
    events
        MoviecyclesDidSet
        MovieintervalDidSet
    end
    
end

