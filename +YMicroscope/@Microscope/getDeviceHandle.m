% get device handle with label
function handle=getDeviceHandle(obj,label)

% all microscope properties
props=properties(obj);
for i=1:length(props)
    % loop through array of device handles
    for j=1:length(obj.(props{i}))
        % find the label tag
        if isprop(obj.(props{i})(j),'label')
            % compare and return
            if strcmp(obj.(props{i})(j).label,label)
                handle=obj.(props{i})(j);
                return
            end
        end
    end
end
handle=[];
warning(['cant not find device with label:',label])
end