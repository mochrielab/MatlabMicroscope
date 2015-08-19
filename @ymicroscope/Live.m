function [ obj ] = Live( obj, hobj, event )
%show live image

% if strcmp(obj.status,'standing')
%     msgbox('movie or zstack is running');
% end

if strcmp(obj.status,'live_running')
    set(hobj,'String','Start Live');
    obj.status = 'standing';
elseif strcmp(obj.status,'standing')
    set(hobj,'String','Stop Live');
    obj.status = 'live_running';
    % set camera to be triggered by the computer
    obj.nidaq.outputSingleScan([obj.dataoffset, 0]);
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'Software (Recommended for Live Mode)'); % set exposure to external
    while strcmp(obj.status,'live_running')
        try
            obj.mm.setExposure(obj.exposure);
            obj.mm.snapImage();
            img = obj.mm.getImage();
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();
            if obj.mm.getBytesPerPixel == 2
                pixelType = 'uint16';
            else
                pixelType = 'uint8';
            end
            img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            img = transpose(img);                % make column-major order for MATLAB
            % plot
            axes(obj.imageaxis_handle);
            cla
            imagesc(img);colormap gray;axis image;axis off
            drawnow;
        catch error
            axes(obj.imageaxis_handle);
            cla
            imagesc(0);colormap gray;axis image;axis off
            drawnow;
            warning(['error in live: ',error.identifier]);
        end
    end
else
    msgbox(['error: microscope is ',obj.status]);
end



end


