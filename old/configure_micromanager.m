dirpath='C:\Program Files\Micro-Manager-1.4\plugins\Micro-Manager';
files=dir(fullfile(dirpath,'*.jar'));
for ifile=1:length(files)
    javaaddpath(fullfile(dirpath,files(ifile).name));
end
display('finished loading java path');
import mmcorej.*;
mmc=CMMCore();
% %%
%  mmc.snapImage();
% img = mmc.getImage();  % returned as a 1D array of signed integers in row-major order
% width = mmc.getImageWidth();
%  height = mmc.getImageHeight();
% if mmc.getBytesPerPixel == 2
%     pixelType = 'uint16';
% else
%     pixelType = 'uint8';
% end
%  img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
% img = reshape(img, [width, height]); % image should be interpreted as a 2D array
% img = transpose(img);                % make column-major order for MATLAB
%  imshow(img);