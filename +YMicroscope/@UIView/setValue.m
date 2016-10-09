% set the value for specific tag
function setValue(obj,tag,stringvalue)
warning('need to be updated');return
% set string value for a given tag
handles=[obj.controlpanel_handle.get('Children'),...
    obj.parampanel_handle.get('Children')];
display('handle size')
size(handles)
for i=1:numel(handles)
    if strcmp(handles(i).get('Tag'),tag)
        if strcmp(handles(i).get('Style'),'popupmenu')
            selections=handles(i).get('String');
            for j=1:length(selections)
                if strcmp(selections{j},stringvalue)
                    handles(i).set('Value',j);
                    return;
                end
            end
            warning('invalid string value');
        else
            handles(i).set('String',stringvalue);
        end
        return
    end
end
end