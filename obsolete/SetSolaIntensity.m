function [  ] = SetSolaIntensity( obj )
%set the intensity of the sola illumination light source

intensity=round(obj.fluorescent_illumination_intensity);
if intensity > 255
    intensity=255;
    warning('maxinum intensity value is 255');
elseif intensity < 0
    intensity = 0 ;
    warning('minimum intensity value is 0');
end

s=dec2hex(255-intensity);
if length(s)==1
    s=['0',s];
end
fprintf(obj.sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') ...
    hex2dec('04') hex2dec(['F',s(1)]) hex2dec([s(2),'0']) hex2dec('50')])); 


end

