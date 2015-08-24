
% photo bleaching analysis
dirpath = 'C:\microscope_pics\08_18_2015\mNeonGreen_4prime\photobleach';
name = 'zstack_18_32_32';
load(fullfile(dirpath,[name,'.mat']));
%% find particles
img1=double(img3(:,:,1));
img2=double(img3(:,:,end));

% se = strel('disk',8);
img1bg = imgaussfilt(img1,20);%imopen(img1,se);
img1 = img1 - img1bg;

% img1 = bpass(img1,2,10);

pks=pkfnd(img1,1800,11);
pks=pks(pks(:,1)<500&pks(:,1)>400&pks(:,2)<200,:);
% cnt=pks;
cnt=cntrd(img1,pks,11,0);
% SI(double(img3(:,:,1)));hold on;
SI(img1);hold on;
plot(cnt(:,1),cnt(:,2),'o');
savefig(['tracking_',name]);

%% calculating images
numparticles = size(cnt,1);
numframes = size(img3,3);
intensities = zeros(numframes,numparticles);

wz = 10;
for iframe =1:numframes
    img = double(img3(:,:,iframe));
    imgbg = imgaussfilt(img,20);
    img = img - imgbg;
    for iparticle =1:numparticles
        pcnt = cnt(iparticle,1:2);
        pdcnt = pcnt - round(pcnt);
        [X,Y] = meshgrid((-wz:wz)+pdcnt(1),(-wz:wz)+pdcnt(2));
        mask = X.^2+Y.^2 < 4^2;
        wimg = img((-wz:wz)+round(pcnt(2)),(-wz:wz)+round(pcnt(1)));
        wimg = wimg.*mask;
        intensities(iframe,iparticle) = sum(wimg(:));
    end
end
% plot
for iparticle = 1:numparticles
    plot((1:numframes)*.1,intensities(:,iparticle)); hold on;
end
xlabel('seconds');
ylabel('total intensity for each particle')
savefig(['decaycurve_',name]);



%%

dirpath = 'C:\microscope_pics\08_18_2015\mNeonGreen_4prime\photobleach';
name = 'zstack_18_29_40';
load(fullfile(dirpath,[name,'.mat']));
%% find particles
img1=double(img3(:,:,1));
img2=double(img3(:,:,end));

% se = strel('disk',8);
img1bg = imgaussfilt(img1,20);%imopen(img1,se);
img1 = img1 - img1bg;

img1 = bpass(img1,2,10);

SI(double(img3(:,:,1)));hold on;
% SI(img1);hold on;
plot(cnt(:,1),cnt(:,2),'o');
savefig(['tracking_',name]);

%% calculating images
numparticles = size(cnt,1);
numframes = size(img3,3);
intensities = zeros(numframes,numparticles);

wz = 10;
for iframe =1:numframes
    img = double(img3(:,:,iframe));
    imgbg = imgaussfilt(img,20);
    img = img - imgbg;
    for iparticle =1:numparticles
        pcnt = cnt(iparticle,1:2);
        pdcnt = pcnt - round(pcnt);
        [X,Y] = meshgrid((-wz:wz)+pdcnt(1),(-wz:wz)+pdcnt(2));
        mask = X.^2+Y.^2 < 4^2;
        wimg = img((-wz:wz)+round(pcnt(2)),(-wz:wz)+round(pcnt(1)));
        wimg = wimg.*mask;
        intensities(iframe,iparticle) = sum(wimg(:));
    end
end
%% plot
for iparticle = 1:numparticles
    plot((1:numframes)*.1,intensities(:,iparticle),'-'); hold on;
end
xlabel('seconds');
ylabel('total intensity for each particle')
savefig(['decaycurve_',name]);


%%
dirpath = 'C:\microscope_pics\08_18_2015\mNeonGreen_4prime\photobleach';
name = 'zstack_18_05_45';
load(fullfile(dirpath,[name,'.mat']));
%% find particles
img1=double(img3(:,:,1));
img2=double(img3(:,:,end));

% se = strel('disk',8);
img1bg = imgaussfilt(img1,20);%imopen(img1,se);
img1 = img1 - img1bg;

img1 = bpass(img1,2,10);

SI(double(img3(:,:,1)));hold on;
% SI(img1);hold on;
plot(cnt(:,1),cnt(:,2),'o');
savefig(['tracking_',name]);

%% calculating images
numparticles = size(cnt,1);
numframes = size(img3,3);
intensities = zeros(numframes,numparticles);

wz = 10;
for iframe =1:numframes
    img = double(img3(:,:,iframe));
    imgbg = imgaussfilt(img,20);
    img = img - imgbg;
    for iparticle =1:numparticles
        pcnt = cnt(iparticle,1:2);
        pdcnt = pcnt - round(pcnt);
        [X,Y] = meshgrid((-wz:wz)+pdcnt(1),(-wz:wz)+pdcnt(2));
        mask = X.^2+Y.^2 < 8^2;
        wimg = img((-wz:wz)+round(pcnt(2)),(-wz:wz)+round(pcnt(1)));
        wimg = wimg.*mask;
        intensities(iframe,iparticle) = sum(wimg(:));
    end
end
%% plot
for iparticle = 1:numparticles
    plot((1:numframes)*.1,intensities(:,iparticle)); hold on;
end
xlabel('seconds');
ylabel('total intensity for each particle')
savefig(['decaycurve_',name]);

