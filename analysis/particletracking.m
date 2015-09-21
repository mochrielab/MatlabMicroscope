dirpath='I:\microscope_pics\09_20_2015';
% name='drifttest_zstack_20_28_16';
% name='newexperiment_zstack_21_42_15';
% name='newexperiment_zstack_21_42_35';
% name='newexperiment_zstack_21_57_26';

files=dir(fullfile(dirpath,['drift*analog*.tif']));
filenames={files.name};
%%
for ifile=1:length(files)
    [~,name]=fileparts(filenames{ifile});
    file=fullfile(dirpath,[name,'.tif']);
    setting=load(fullfile(dirpath,[name,'.mat']));
    pos=zeros(setting.setting.numstacks,2);
    %%
    warning off;
    for iframe=1:setting.setting.numstacks
        img0=imread(file,iframe);
        img=bpass(img0,1,10);
        pks=pkfnd(img,0.5*max(img(:)),20);
        cnt=cntrd(img,pks,20,0);
        %     SI(img);hold on;
        %     plot(cnt(:,1),cnt(:,2),'.');
        if size(cnt,1)==1
            pos(iframe,:)=mean(cnt(:,1:2),1);
        else
            error('wrong number');
        end
    end
    %%
    y=pos(:,1)'*0.065;
    y=y-mean(y);
    x=pos(:,2)'*0.065;
    x=x-mean(x);
    Fs=setting.setting.framerate;
    t = (0:length(x)-1)/Fs;
    [ psdx,freq ] = PowerSpectrum( x, Fs );
    [ psdy,freq ] = PowerSpectrum( y, Fs );
    clf
    set(gcf,'Position',[0 50 900 900]);
    % plot(t,x,'r',t,y,'g');
    % xlabel('time(s)');
    % ylabel('displacement(\mum)');
    % legend('x','y','z');
    % title(strrep(name,'_',' '));
    plot(freq,psdx,'r'); hold on;
    plot(freq,psdy,'g');
    axis([0 100 0 max([psdx,psdy])+.1]);
    xlabel('frequency(Hz)');
    ylabel('Power spectrum (\mum^{-2}Hz^{-1})');
    title(['Power spectrum, Sampling Freq: ',num2str(setting.setting.framerate)]);
    legend('x','y')
    print(gcf,name,'-dpng');
    
end