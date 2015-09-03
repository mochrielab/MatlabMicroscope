function [  ] = GotoZCenter(obj, img_3d )
%drive the microscope to focus to the z center 




% getting image mode
light_mode=[];
if ~isempty(strfind(lower(obj.illumination_mode),'brightfield'))
    light_mode='brightfield';
elseif ~isempty(strfind(lower(obj.illumination_mode),'fluorescent'))
    light_mode='fluorescent';
else
    warning('unsupported light mode');
    return
end


% find where to move
desired_z = GetZstackCenter(img_3d,[light_mode,' ',obj.sample_type],...
    obj.autofocus_window);

current_z = (obj.numstacks+1)/2;

diff_z = desired_z - current_z;

% move stage
obj.zoffset = obj.zoffset + diff_z * obj.volts_per_pix * obj.stepsize;
obj.Go;

display(obj.zoffset);

end

