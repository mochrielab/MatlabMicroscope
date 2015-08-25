function [  ] = zstack2movie( filename,name )
%convert zstack to a movie
load(filename);
% name='test';
%%
vid=VideoWriter(name);
vid.FrameRate = 3;
figure('Position',[0 50 800 800]);
axes('Position',[0 0 1 .9])
    set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
    colormap gray;axis image;axis off;
clims=[0 max(img3(:))];
title({['exposure=',num2str(Exposure),'ms'],...
    ['numstack=',num2str(NumbStacks)],...
    ['stepsize=',num2str(StepSize),'pix'],...
    })
vid.open;
for istack=1:size(img3,3)
    imagesc(img3(:,:,istack),clims);
    vid.writeVideo(getframe);
end
close(vid)
close all;
end
