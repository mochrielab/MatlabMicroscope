function [ output_args ] = merge_plot_save( datapath,bf,fl,name,description )
% merge image, plot image and save image
close all;
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf;
imgmerg(:,:,2)=imgbf+imgfl/2;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 .9])
image(imgmerg(500:2000,500:2000,:));axis image;axis off;
max(max(imgmerg(:,:,2)))
title({['exposure = ',num2str(Exposure),'ms'],description});
print(gcf,name,'-dpng');
savefig(gcf,name);
end

