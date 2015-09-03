% find the center position of a zstack in fluorescence

dirpath='I:\microscope_pics\08_31_2015';
filename='5fov6_zstack_14_02_46.tif';
ffn=fullfile(dirpath,filename);
info=imfinfo(ffn);
numstacks=length(info);
img_3d = zeros(info(1).Height,info(1).Width,numstacks);
for istack=1:numstacks
    img_3d(:,:,istack)=imread(ffn,istack);
end

% find the zstack center of a fluroescent particle based on the central region
% better than imgradient
tic
wsize=250;
numstacks=size(img_3d,3);
max_intensity=zeros(1,numstacks);
midpoint=round([size(img_3d,1),size(img_3d,2)]/2);
for istack=1:numstacks
    img=img_3d(midpoint(1)-wsize:midpoint(1)+wsize,...
        midpoint(2)-wsize:midpoint(2)+wsize,istack);
    all_int=sort(img(:),'descend');
    max_intensity(istack)=mean(all_int(1:50));
end
[~,zcenter] = max(max_intensity);
zs=1:numstacks;
choose_range=max_intensity>mean(max_intensity);
gaussfun = @(p,x)p(1)+p(2)*exp(-(x-p(3)).^2/p(4)^2);
p0=[min(max_intensity),max(max_intensity)-min(max_intensity),zcenter,5];
pfit=fminunc(@(p)sum((gaussfun(p,zs(choose_range))-max_intensity(choose_range)).^2),p0);
zcenter=pfit(3);
toc

close all
plot(zs,max_intensity,'o',zs(choose_range),gaussfun(pfit,zs(choose_range)));
xlabel('zstack number');
ylabel('averaged maximum intensity');
legend('raw','gaussin fitting');
title(['fluroescent particle zstack center finding : ',num2str(zcenter)]);
    
    print(gcf,'fluoAutofocusfit','-dpng')

    figure
    SI(squeeze(sum(img_3d,3)));
    title('projection image');
    print(gcf,'fluoAutofocusimg','-dpng')
%% find the zstack center of the bright field

dirpath='I:\microscope_pics\08_31_2015';
filename='5fov6_zstack_14_02_18.tif';
ffn=fullfile(dirpath,filename);
info=imfinfo(ffn);
numstacks=length(info);
img_3d = zeros(info(1).Height,info(1).Width,numstacks);
for istack=1:numstacks
    img_3d(:,:,istack)=imread(ffn,istack);
end
%
tic
wsize=250;
numstacks=size(img_3d,3);
zs=1:numstacks;
mean_gradient_intensity=zeros(1,numstacks);
midpoint=round([size(img_3d,1),size(img_3d,2)]/2);
for istack=1:numstacks
    img=img_3d(midpoint(1)-wsize:midpoint(1)+wsize,...
        midpoint(2)-wsize:midpoint(2)+wsize,istack);
    imgrad=imgradient(img);    
    mean_gradient_intensity(istack)=mean(imgrad(:));
end
y = sgolayfilt(mean_gradient_intensity,3,15);
[~,loc_peak]=findpeaks(y);
[~,loc_valley]=findpeaks(-y);

zcenter= nan;
choose_range=[];
for ipeak=1:length(loc_peak)-1
    ind=find(loc_valley>loc_peak(ipeak)&loc_valley<loc_peak(ipeak+1));
    if ~isempty(ind)
        zcenter = loc_valley(ind);
%         choose_range=loc_peak(ipeak)+5:loc_peak(ipeak+1)-5;
        choose_range = zcenter-5:zcenter+5;

        break
    end
end
[~,zcenter]=min(mean_gradient_intensity(choose_range));
zcenter=zcenter+choose_range(1)-1;
% gaussfun = @(p,x)p(1)+p(2)*exp(-(x-p(3)).^2/p(4)^2);
% p0=[max(mean_gradient_intensity(choose_range)),...
%     min(mean_gradient_intensity(choose_range))-max(mean_gradient_intensity(choose_range)),...
%     zcenter,2];
% pfit=fminunc(@(p)sum((gaussfun(p,zs(choose_range))-mean_gradient_intensity(choose_range)).^2),p0);
% zcenter=pfit(3);
toc

close all
% plot(zs,mean_gradient_intensity,'o',zs,y,zs(choose_range),gaussfun(pfit,zs(choose_range)));
plot(zs,mean_gradient_intensity,'o',zs,y,zcenter,mean_gradient_intensity(zcenter),'*');
xlabel('zstack number');
ylabel('mean intensity gradient');
legend('raw','smooth','center');
title(['brightfield cell zstack center finding: ',num2str(zcenter)]);
%%



