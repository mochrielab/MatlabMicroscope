classdef PriorZStage < handle
    %11/9/2015
    %  Yao Zhao
    enumeration
        finescan(3,61,1)
        coarsescan(3,11,3)
    end
    
    properties
        zoffset
        numstacks
        stepsize
    end
    
    properties (Constant)
        um_per_volts=200/10;
    end
    
    methods
        function obj=PriorZStage(zoffset,numstacks,stepsize)
            obj.zoffset=zoffset;
            obj.numstacks=numstacks;
            obj.stepsize=stepsize;
        end
    end
    
end

