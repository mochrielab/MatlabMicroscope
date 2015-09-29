dirpath = 'C:\Users\Yao\Desktop\microscope Yao\table noise';
files=dir(fullfile(dirpath,'*.fig'));
filenames={files.name};
for ifile=1:length(filenames)
    close all;
    open(fullfile(dirpath,filenames{ifile}));
    [~,name]=fileparts(filenames{ifile});
    dataObjs = get(gca, 'Children');
    ydata=get(dataObjs,'Ydata');
    x=ydata{1};
    y=ydata{3};
    z=ydata{2};
    Fs=1000;
    t = (0:length(x)-1)/Fs;
    [ psdx,freq ] = PowerSpectrum( x, Fs );
    [ psdy,freq ] = PowerSpectrum( y, Fs );
    [ psdz,freq ] = PowerSpectrum( z, Fs );
    clf
    set(gcf,'Position',[0 50 1800 900]);
    subplot(1,2,1);
    plot(t,x,'r',t,y,'g',t,z,'b');
    xlabel('time(s)');
    ylabel('displacement(\mum)');
    legend('x','y','z');
    title(strrep(name,'_',' '));
    subplot(1,2,2);
    plot(freq,psdx,'r'); hold on;
    plot(freq,psdy,'g');
    plot(freq,psdz,'b');
    axis([0 100 0 max([psdx,psdy,psdz])+.1]);
    xlabel('frequency(Hz)');
    ylabel('Power spectrum (\mum^{-2}Hz^{-1})');
    title('Power spectrum');
    legend('x','y','z')
    print(gcf,name,'-dpng');
end