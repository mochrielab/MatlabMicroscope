% grab the overall settings of the microscope
function settings=getSettings(obj)
settings=[];
props=properties(obj);
for i=1:length(props)
    for j=1:length(obj.(props{i}))
        htmp=obj.(props{i})(j);
        if isprop(htmp,'label')
            label=htmp.label;
            props2=properties(htmp);
            for k=1:length(props2)
                if ~strcmp(props2{k},'label')
                    settings.([label,'_',props2{k}])...
                        =htmp.(props2{k});
                end
            end
        end
    end
end
end