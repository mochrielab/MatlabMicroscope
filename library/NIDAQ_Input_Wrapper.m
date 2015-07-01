classdef NIDAQ_Input_Wrapper < handle
    %nidaq input data wrapper
    
    properties
        data
        count
        totalcount
    end
    
    methods
        % initialize
        function obj = NIDAQ_Input_Wrapper(data)
            obj.data = zeros(size(data));
            obj.count = 0;
            obj.totalcount = size(data,1);
        end
        
        % add data
        function [] = datalistener(obj,src,event)
            obj.count = obj.count + 1;
            obj.data(obj.count,:) = event.Data;
        end
    end
    
end

