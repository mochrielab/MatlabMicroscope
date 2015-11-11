classdef StageZPrior < handle
    % class to control the priorZstage
    %  Yao Zhao 11/9/2015
    enumeration
        finescan(3,61,1)
        coarsescan(3,11,3)
    end
    
    properties (SetAccess = protected)
        zoffset
        numstacks
        stepsize
    end
    
    properties (Constant)
        um_per_volts=200/10;
    end
    
    methods
        function obj=StageZPrior(zoffset,numstacks,stepsize)
            obj.zoffset=zoffset;
            obj.numstacks=numstacks;
            obj.stepsize=stepsize;
        end
        
        function setZoffset(obj,zoffset)
            if zoffset<0
                throw(MException('PrioZStage:ZoffsetOutOfLowerBound',...
                    [num2str(zoffset),' zoffset out of lower bound 0']));
            elseif zoffset>10
                throw(MException('PrioZStage:ZoffsetOutOfUpperBound',...
                    [num2str(zoffset),' zoffset out of upper bound 10']));
            else
                obj.zoffset=zoffset;
                notify(obj,'ZoffsetDidSet');
            end
        end
        
        
        function setNumstacks(obj,numstacks)
            if numstacks<0
                throw(MException('PrioZStage:NegativeNumstacks',...
                    [num2str(numstacks),' numstacks out of lower bound 0']));
            else
                obj.numstacks=floor(numstacks/2)*2+1;
                notify(obj,'NumstacksDidSet');
            end
        end
        
        function setStepsize(obj,stepsize)
            stepsize=round(stepsize);
            if stepsize<0
                throw(MException('PrioZStage:NegativeStepsize',...
                    [num2str(stepsize),' stepsize out of lower bound 0']));
            else
                obj.stepsize=stepsize;
                notify(obj,'StepsizeDidSet');
            end
        end
    end
    
    
    
    events
        ZoffsetDidSet
        NumstacksDidSet
        StepsizeDidSet
    end
    
end

