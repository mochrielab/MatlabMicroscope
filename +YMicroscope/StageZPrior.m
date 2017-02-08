classdef StageZPrior < YMicroscope.Stage
    % class to control the priorZstage
    %  Yao Zhao 11/9/2015
    
%     enumeration
%         finescan(3,61,1)
%         coarsescan(3,11,3)
%     end
    
    properties (Access = protected)
        trigger
    end
    
    properties (SetAccess = protected)
        zoffset
        numstacks
        stepsize
    end
    
    properties (Constant)
        um_per_volts=200/10;
        % piezo conversion
        um_per_pix=6.5/100;
        volts_per_pix=(6.5/100)/(200/10);
    end
    
    properties (Dependent)
    end
    
    methods
        % constructor
        function obj=StageZPrior(trigger,zoffset,numstacks,stepsize)
            obj.trigger = trigger;
            obj.setZoffset(zoffset);
            obj.setNumstacks(numstacks);
            obj.setStepsize(stepsize);
            display('Z stage connected');
        end
        
        % get position
        function [ pos ] = getPosition( obj )
            pos = obj.zoffset;
        end
        
        % set position
        function setPosition(obj, pos)
            if length(pos)==1
                obj.setZoffset(pos)
            else
                throw(MException('PrioZStage:ZoffsetSize',...
                    [length(pos),' zoffset size should be 1']));
            end
            notify(obj, 'ZPDidSet');
        end
        
        % move
        function move(obj, pix)
            zoffset = obj.getPosition();
            obj.setPosition(zoffset + pix*obj.volts_per_pix);
        end
        
        function setSpeed(obj,vs)
            warning('not implemented')
        end
        function [ vs ] = getSpeed(obj)
            warning('not implemented')
        end
        
        
        % get z off set
        % only set value without moving the stage
        function setZoffset(obj,zoffset)
            if zoffset<0
                throw(MException('PrioZStage:ZoffsetOutOfLowerBound',...
                    [num2str(zoffset),' zoffset out of lower bound 0']));
            elseif zoffset>10
                throw(MException('PrioZStage:ZoffsetOutOfUpperBound',...
                    [num2str(zoffset),' zoffset out of upper bound 10']));
            else
                % save value
                obj.zoffset=zoffset;
                % move the stage
                obj.trigger.setState('zstage',obj.zoffset);
                notify(obj,'ZoffsetDidSet');
            end
        end
        
        % set number stacks
        % set number of stacks
        function setNumstacks(obj,numstacks)
            if numstacks<0
                throw(MException('PrioZStage:NegativeNumstacks',...
                    [num2str(numstacks),' numstacks out of lower bound 0']));
            else
                obj.numstacks=floor(numstacks/2)*2+1;
                notify(obj,'NumstacksDidSet');
            end
        end
        
        % set step size
        % set stepsize of zscan
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
        
        % get z array of a scan
        function zarray = getZarray(obj)
            stacks=(1:obj.numstacks)-(obj.numstacks+1)/2;
            zarray=obj.zoffset+obj.stepsize*stacks*obj.volts_per_pix;
        end
        
        % delete object
        function delete(obj)
            obj.trigger.setState('zstage',0);
            display('Prior Z stage 0V');
        end
        
    end    
    
    events
        ZoffsetDidSet
        NumstacksDidSet
        StepsizeDidSet
    end
    
end

