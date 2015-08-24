close all;
datapath='C:\microscope_pics\08_19_2015\3';
bf='capture_15_27_03';
fl='capture_15_27_31';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'3merg_1','-dpng');
%% 
close all;
datapath='C:\microscope_pics\08_19_2015\3';
bf='capture_15_33_43';
fl='capture_15_33_56';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'3merg_2','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\4';
fl='capture_17_31_50';
bf='capture_17_32_04';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'4merg_1','-dpng');

%%
close all;
datapath='C:\microscope_pics\08_19_2015\4';
bf='capture_17_33_54';
fl='capture_17_34_01';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'4merg_2','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\4';
bf='capture_17_36_37';
fl='capture_17_36_50';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'4merg_3','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\4''';
fl='capture_18_02_04';
bf='capture_18_02_11';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'4pmerg_1','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\4''';
fl='capture_18_15_46';
bf='capture_18_15_51';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'4pmerg_2','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\5';
bf='capture_18_42_54';
fl='capture_18_42_58';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'5merg_1','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\3 30min induction';
fl='capture_18_47_27';
bf='capture_18_47_31';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:));
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'330minmerg_1','-dpng');
%%
close all;
datapath='C:\microscope_pics\08_19_2015\3 30min induction';
fl='capture_18_51_33';
bf='capture_18_51_36';
load(fullfile(datapath,bf));
img=double(img);
imgbf=img/max(img(:)); 
load(fullfile(datapath,fl));
img=double(img);
imgfl=(img-mean(img(:)))/(max(img(:))-mean(img(:)));
imgmerg=zeros([size(img),3]);
imgmerg(:,:,1)=imgbf+imgfl;
imgmerg(:,:,2)=imgbf;
imgmerg(:,:,3)=imgbf;
figure('Position',[0 50 800 800]);axes('Position',[0 0 1 1])
image(imgmerg);axis image;axis off;
title('exposure 50 illumination medium');
print(gcf,'330minmerg_2','-dpng');


