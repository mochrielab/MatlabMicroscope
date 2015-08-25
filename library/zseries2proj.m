function [ proj, timelabel ] = zseries2proj( datapath,name )
%convert all movie series to a projection stack
%%
% datapath='C:\microscope_pics\08_24_2015\4\slide2\movie2';
files=dir(fullfile(datapath,'movie*'));
numframes=length(files);

load(fullfile(datapath,files(1).name));
szvector=size(img3);
proj=zeros([szvector(1:2),numframes]);
timelabel=zeros(1,numframes);
tn=files(1).name;
t1 = str2num(tn(7:8)) *3600 ...
    +str2num(tn(10:11)) *60 ...
    +str2num(tn(13:14)); 

for iframe=1:numframes
    if iframe>1
    load(fullfile(datapath,files(iframe).name));
    end
    img3=double(img3);
    proj(:,:,iframe)=squeeze(sum(img3,3));
    tn=files(iframe).name;
    timelabel(iframe) = str2num(tn(7:8)) *3600 ...
    +str2num(tn(10:11)) *60 ...
    +str2num(tn(13:14))-t1;     
end

%%


vid=VideoWriter(name);
vid.FrameRate = 3;
figure('Position',[0 50 800 800]);
axes('Position',[0 0 1 .9])
    set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
    colormap gray;axis image;axis off;
% clims=[min(proj(:)) max(proj(:))];
title({['exposure=',num2str(Exposure),'ms'],...
    ['numstack=',num2str(NumbStacks)],...
    ['stepsize=',num2str(StepSize),'pix'],...
    })
vid.open;
for istack=1:size(proj,3)
    imagesc(proj(:,:,istack));
    vid.writeVideo(getframe);
end
close(vid)
close all;

end
