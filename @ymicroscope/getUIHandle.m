function [ h ] = getUIHandle( obj, panel, textstring )
%   get the control field from the panel
%   used to update stuff on UI

%%
% get to the panel
h=[];
panel_hs=get(obj.figure_handle,'children');
panel_names=cell(size(panel_hs));
for i=1:length(panel_hs)
    if ischar(panel_hs(i).Title)
        panel_names{i} = panel_hs(i).Title;
    else
        panel_names{i} = '';
    end
end

if ischar(panel)
    ipanel = find(strcmp(panel_names,panel));
    if isempty(ipanel)
        warning('can''t find pannel');
        return
    end
elseif isnumeric(panel)
    ipanel = panel;
else
    warning('wrong panel type');
    return
end

if ipanel <= 0 || ipanel > length(panel_hs)
    warning('wrong panel id');
    return
end
% get to the control
control_hs=get(panel_hs(ipanel),'children');
if isnumeric(textstring);
    if textstring >1 && textstring <=length(control_hs)
        h = control_hs(textstring);
    else
        warning('out of bound textstring number');
        return
    end
else ischar(textstring);
    control_styles = {control_hs.Style};
    control_names = {control_hs.String};
    text_index = (strcmp(control_styles,'text'));
    textfield = find(strcmp(control_names,textstring) & text_index);
    if isempty(textfield)
        warning('can''t find textstring');
        return
    end
    h=control_hs(textfield+1);
end

end
