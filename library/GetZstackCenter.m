function [ zcenter ] = GetZstackCenter( img_3d,mode,varargin )
% find the center of the zstack
% only using the center of the image
% input:    img_3d the zstack image
%           mode: brightfield, fluorescent particle
%           wsize: the aoi from the center

if nargin ==2
    wsize=250;
elseif nargin ==3
    wsize=varargin{1};
else
    error('wrong number of input variables');
end
imgsize=size(img_3d);
maxwsize = floor((min(imgsize(1:2))-1)/2);

if wsize> maxwsize
    wsize=maxwsize;
    warning('wsize set to the max possible value');
end

if strcmp(mode,'brightfield E.coli')
    %%
    numstacks=size(img_3d,3);
    zs=1:numstacks;
    meangradint=zeros(1,numstacks);
    midpoint=round([size(img_3d,1),size(img_3d,2)]/2);
    for istack=1:numstacks
        img=img_3d(midpoint(1)-wsize:midpoint(1)+wsize,...
            midpoint(2)-wsize:midpoint(2)+wsize,istack);
        imgrad=imgradient(img);
        meangradint(istack)=mean(imgrad(:));
    end
    y = sgolayfilt(meangradint,3,15);
    [~,loc_peak]=findpeaks(y);
    [~,loc_valley]=findpeaks(-y);
    
    possible_pairs=[];
    choose_range=[];
    for ipeak=1:length(loc_peak)-1
        ind=find(loc_valley>loc_peak(ipeak)&loc_valley<loc_peak(ipeak+1));
        if ~isempty(ind)
            possible_pairs = [possible_pairs; ...
                loc_valley(ind),loc_peak(ipeak),loc_peak(ipeak+1),...
                meangradint(loc_peak(ipeak))+meangradint(loc_peak(ipeak+1))...
                -2*meangradint(loc_valley(ind))];
            %         choose_range=loc_peak(ipeak)+5:loc_peak(ipeak+1)-5;
            break
        end
    end
    if size(possible_pairs,1)>0
        [~,tmp]=max(possible_pairs(:,4));   
        zcenter=possible_pairs(tmp,1);
    end
    choose_range = zcenter-5:zcenter+5;
    [~,zcenter]=min(meangradint(choose_range));
    zcenter=zcenter+choose_range(1)-1;
    % gaussfun = @(p,x)p(1)+p(2)*exp(-(x-p(3)).^2/p(4)^2);
    % p0=[max(mean_gradient_intensity(choose_range)),...
    %     min(mean_gradient_intensity(choose_range))-max(mean_gradient_intensity(choose_range)),...
    %     zcenter,2];
    % pfit=fminunc(@(p)sum((gaussfun(p,zs(choose_range))-mean_gradient_intensity(choose_range)).^2),p0);
    % zcenter=pfit(3);
    
    %     close all
    figure(12345)
        % plot(zs,mean_gradient_intensity,'o',zs,y,zs(choose_range),gaussfun(pfit,zs(choose_range)));
        plot(zs,meangradint,'o',zs,y,zcenter,meangradint(zcenter),'*');
        xlabel('zstack number');
        ylabel('mean intensity gradient');
        legend('raw','smooth','center');
        title(['brightfield cell zstack center finding: ',num2str(zcenter)]);
    zcenter=max(1,zcenter);
    zcenter=min(numstacks,zcenter);


elseif strcmp(mode,'fluorescent E.coli')
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
    options=optimoptions('fminunc','Algorithm','quasi-newton','Display','off');
    pfit=fminunc(@(p)sum((gaussfun(p,zs(choose_range))-max_intensity(choose_range)).^2),p0,options);
    zcenter=pfit(3);
    zcenter=max(1,zcenter);
    zcenter=min(numstacks,zcenter);
    % close all
   
    figure(12345)
    plot(zs,max_intensity,'o',zs(choose_range),gaussfun(pfit,zs(choose_range)));
    xlabel('zstack number');
    ylabel('averaged maximum intensity');
    legend('raw','gaussin fitting');
    title(['fluroescent particle zstack center finding : ',num2str(zcenter)]);

else
    error('unsupported mode')
end


end

