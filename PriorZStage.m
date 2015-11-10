classdef PriorZStage < handle
    %11/9/2015
    %  Yao Zhao
    
    properties
        center
    end
    
    properties (Constant)
        um_per_volts=200/10;
    end
    
    methods
        function obj=PriorZStage()
            obj.center=5;
        end
    end
    
end

