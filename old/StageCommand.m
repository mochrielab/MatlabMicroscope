function [ out ] = StageCommand( obj, str )
% send stage command, and get feed back
fprintf(obj.priorXYstage,'%s\r',str);
% wait and load
out=fscanf(obj.priorXYstage);
% load rest
while get(obj.priorXYstage,'BytesAvailable')>0
out=[out,fscanf(obj.priorXYstage)];
end
% display(out);

end

