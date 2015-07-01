function [ obj ] = ZFocus( obj )
% autofocus z direction

% initialize
obj.nidaq.Rate=3; %Hz
obj.nidaq.IsContinuous=0; % continuous writing
obj.mm.setCircularBufferMemoryFootprint(4000);
obj.mm.clearCircularBuffer();
intervalMs=1e3/obj.nidaq.Rate;%
numImages=length(obj.stacks);
cameralabel=obj.mm.getCameraDevice;
width = obj.mm.getImageWidth();
height = obj.mm.getImageHeight();
numstacks=length(obj.stacks);
if obj.mm.getBytesPerPixel == 2
    pixelType = 'uint16';
else
    pixelType = 'uint8';
end

% prepare data to send
data=obj.stacks*obj.volts_per_pix+obj.dataoffset;
data=reshape(data,length(data),1);
queueOutputData(obj.nidaq,data)

% prepare data acquisition
obj.mm.prepareSequenceAcquisition(cameralabel);
obj.mm.initializeCircularBuffer();

obj.nidaq.startBackground;
obj.mm.startSequenceAcquisition(cameralabel,numImages,intervalMs,1);
% live in background
while obj.mm.isSequenceRunning
    img=obj.mm.getLastImage();
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    imagesc(img);colormap gray;axis image;axis off
    drawnow;
end

% grab frame
display(['number of images in buffer: ',...
    num2str(obj.mm.getRemainingImageCount())]);
istack=0;
img3=uint16(zeros(height,width,numstacks));
while obj.mm.getRemainingImageCount()>0
    istack=istack+1;
    imgtmp=obj.mm.popNextImage();
    img = reshape(imgtmp, [width, height]); 
    img3(:,:,istack)=img';
end

% ending program **What do I do with this little section, keep? discard?**
obj.nidaq.stop;
obj.mm.stopSequenceAcquisition();

%% New addition for auto-focusing
% Sum of Squares of Gradients of Each Image using Sobel method
Nframes = size(img3,3);

SumSqGrad = ImgGrad(Nframes,img3); %function that will find the sum
%of the square of the gradients of each stack image

% Fit curve with Lorentzian
FocusLoc = LorentzPkFit(Nframes,SumSqGrad);
%func returns max of fit, which is assumed to be location of in-focus plane

%% new addition microscope-specific
startLoc = round(numstacks/2); %initial starting location
stkDiff = startLoc - FocusLoc; %how many levels apart the in-focus plane is
%from the current plane

%What is the distance from one plane to another? How many volts does this
%correspond to? For now let's call this voltperlvl...
TotVolts = stkDiff.*obj.volts_per_pix;
obj.dataoffset=obj.dataoffset+TotVolts;

%feed this value to the piezo stage so that it will move in response to
%this voltage


end