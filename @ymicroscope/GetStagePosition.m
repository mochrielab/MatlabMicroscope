function [ pos ] = GetStagePosition( obj )
%get the XY position of the prior stage

availablebytes=obj.priorXYstage.BytesAvailable;
if availablebytes>0
fread(obj.priorXYstage, availablebytes)
end

fprintf(obj.priorXYstage,'%s\r','PS'); % send new request

pos = fscanf(obj.priorXYstage); % read position

% process position
pos = strsplit(pos,','); 
x=str2double(pos{1});
y=str2double(pos{2});
if ~isnan(x) && ~isnan(y);
    obj.pos_x = x;
    obj.pos_y = y;
    pos=[x,y];
else
    warning('read stage position unsuccessful');
end

end

