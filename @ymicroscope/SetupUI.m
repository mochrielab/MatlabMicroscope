function [ obj ] = SetupUI( obj )
% set up the UI window for the program

%%
close all;
obj.status='standing';
% figure
figure_handle=figure('Position',[0 50 1920 950]);
obj.figure_handle=figure_handle;
% image axes
imageaxis_handle=axes('Parent',figure_handle,...
    'Unit','Pixels','Position',[20 20 910 910],'Box','on','BoxStyle','full',...
    'xtick',[],'ytick',[]);
imagesc(0);colormap gray;axis image;axis off
obj.imageaxis_handle=imageaxis_handle;
% control panel
controlpanel_handle=uipanel('Parent',figure_handle,...
    'Unit','Pixels','Position',[950+20 475+20 970-50 475-30],...
    'Title','Control','Fontsize',14,...
    'BorderType','etchedin','HighlightColor','green'); 
% parameter setting panel
parampanel_handle=uipanel('Parent',figure_handle,...
    'Unit','Pixels','Position',[950+20 20 970-50 475-10],...
    'Title','Parameters','Fontsize',14,...
    'BorderType','etchedin','HighlightColor','blue');
%% live button
live_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[15 340 200 60],...
    'String','Start Live','Fontsize',20,...
    'Callback',@(hobj,event)obj.Live(hobj,event));
% capture button
capture_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[240 340 200 60],...
    'String','Capture','Fontsize',20,...
    'Callback',@(hobj,event)obj.Capture(hobj,event));
% zstack button
zstack_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[465 340 200 60],...
    'String','Zstack','Fontsize',20,...
    'Callback',@(hobj,event)obj.Zscan(hobj,event));
% movie button
movie_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[690 340 200 60],...
    'String','Start Movie','Fontsize',20,...
    'Callback',@(hobj,event)obj.Movie(hobj,event));
% focus button
focus_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[465 245 200 60],...
    'String','Focus','Fontsize',20,...
    'Callback',@(hobj,event)obj.ZFocus(hobj,event));
% DAQpkg button
ImgSeq_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[690 245 200 60],...
    'String','ImgSeq','Fontsize',20,...
    'Callback',@(hobj,event)obj.DAQpkg(hobj,event));
%% set illumination mode
illumination_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[15 270 200 20],'Value',1,...
    'String',{'None','Brightfield - W','Brightfield - R','Fluorescent'},'Fontsize',10,...
    'Callback',@(hobj,event)set_illumination_mode(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[15 290 200 20],...
    'String','Illumination Mode','Fontsize',10);
%% set movie mode
illumination_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[15 190 200 20],'Value',1,...
    'String',{'zstack_plain'},...
    'Fontsize',10,'Callback',@(hobj,event)set_movie_mode(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[15 210 200 20],...
    'String','Movie Mode','Fontsize',10);
%% set display mode ROI
%%% Added 06/03/15 - text to appear in the pop-up menu %%%
ROI_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[240 270 200 20],'Value',1,...
    'String',{'2160 x 2560','1024 x 1344','512 x 512','256 x 256'},'Fontsize',10,...
    'Callback',@(hobj,event)set_ROI(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[240 290 200 20],...
    'String','Display Size','Fontsize',10);
%% setting parameters
% fluorescent exposure
fluorescent_exposure_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 390 200 20],'Style','edit',...
    'String',num2str(obj.exposure_fluorescent),...
    'Callback',@(hobj,event)set_fluorescent_exposure(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 410 200 20],'Style','text','String',...
    'Fluorescent Exposure (ms)');
% brightfield exposure
brightfield_exposure_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 390 200 20],'Style','edit',...
    'String',num2str(obj.exposure_brightfield),...
    'Callback',@(hobj,event)set_brightfield_exposure(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 410 200 20],'Style','text','String',...
    'Brightfield Exposure (ms)');

% z offset
zoffset_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 340 200 20],'Style','edit',...
    'String',num2str(obj.dataoffset),...
    'Callback',@(hobj,event)set_dataoffset(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 360 200 20],'Style','text','String',...
    'z offset (Volts)');

% z stack number
znum_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 340 200 20],'Style','edit',...
    'String',num2str(obj.numstacks),...
    'Callback',@(hobj,event)set_numstacks(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 360 200 20],'Style','text','String',...
    'number of stacks');

% z stack number
znum_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 340 200 20],'Style','edit',...
    'String',num2str(obj.stepsize),...
    'Callback',@(hobj,event)set_stepsize(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 360 200 20],'Style','text','String',...
    'zstep size (pix)');

% framerate
framerate_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 390 200 20],'Style','edit',...
    'String',num2str(obj.framerate),...
    'Callback',@(hobj,event)set_framerate(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 410 200 20],'Style','text','String',...
    'Frame Rate (Hz)');

% movie interval
movieinterval_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[660 390 200 20],'Style','edit',...
    'String',num2str(obj.movieinterval),...
    'Callback',@(hobj,event)set_movieinterval(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[660 410 200 20],'Style','text','String',...
    'Movie Interval (mins)');

% movie repeat
moviecycles_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[660 340 200 20],'Style','edit',...
    'String',num2str(obj.moviecycles),...
    'Callback',@(hobj,event)set_moviecycles(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[660 360 200 20],'Style','text','String',...
    'Movie Cycles');
end

% call back functions
function set_fluorescent_exposure(hobj,event,obj)
if ~isnan(str2double(get(hobj,'string')))
    obj.exposure_fluorescent=str2double(get(hobj,'string'));
end
set(hobj,'String',num2str(obj.exposure_fluorescent));

end

function set_brightfield_exposure(hobj,event,obj)
if ~isnan(str2double(get(hobj,'string')))
    
    obj.exposure_brightfield=str2double(get(hobj,'string'));
end
set(hobj,'String',num2str(obj.exposure_brightfield));

end

function set_dataoffset(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<0
    elseif input>10
    else
        obj.dataoffset=input;
    end
end
set(hobj,'String',num2str(obj.dataoffset));
obj.nidaq.outputSingleScan(obj.dataoffset);
end

function set_numstacks(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<0
    else
        obj.numstacks=floor(input/2)*2+1;
    end
end
set(hobj,'String',num2str(obj.numstacks));
end

function set_stepsize(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<0
    else
        obj.stepsize=input;
    end
end
set(hobj,'String',num2str(obj.stepsize));
end

function set_movieinterval(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<=0
    else
        obj.movieinterval=input;
    end
end
set(hobj,'String',num2str(obj.movieinterval));
end

function set_moviecycles(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<=0
    else
        obj.moviecycles=input;
    end
end
set(hobj,'String',num2str(obj.moviecycles));
end

function set_illumination_mode(hobj,event,obj)

input=get(hobj,'value');
if input==1 %No light sources are on
    obj.illumination_mode='None'; %no illumination modes selected
    fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
    obj.nidaq2.outputSingleScan([0 0]);
    %obj.nidaq.outputSingleScan([0 0 0]);
elseif input==2
    obj.illumination_mode='Brightfield - W'; %�select white LED
    fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
    obj.nidaq2.outputSingleScan([1 0]);
    %obj.nidaq.outputSingleScan([0 1 0]);
elseif input==3
    obj.illumination_mode='Brightfield - R'; % select red LED
    fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
    obj.nidaq2.outputSingleScan([0 1]);
    %obj.nidaq.outputSingleScan([0 0 1]);
elseif input==4
    obj.illumination_mode='Fluorescent';
    fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
    obj.nidaq2.outputSingleScan([0 0]);
    %obj.nidaq.outputSingleScan([0 0 0]);
    
end
end

function set_movie_mode(hobj,event,obj)

input=get(hobj,'value');
switch input
    case 1
        obj.movie_mode = 'zstack_plain';
    otherwise
        msgbox('error movie option')
end
end

%%% Added 06/03/15 - setting region of interest
function set_ROI(hobj,event,obj)
input=get(hobj,'value');
if input==1 %Default 2160 x 2560 pixels
    obj.display_size = '2160 x 2560';
    obj.img_width = 2560;
    obj.img_height = 2160;
    obj.mm.clearROI();
elseif input==2 %1024 x 1344 pixels
    obj.display_size = '1024 x 1344';
    obj.mm.setROI(608,568,1344,1024);
    obj.img_width = 1344;
    obj.img_height = 1024;
elseif input==3 %512 x 512 pixels
    obj.display_size = '512 x 512';
    obj.mm.setROI(824,1024,512,512);
    obj.img_width = 512;
    obj.img_height = 512;
elseif input==4 %256 x 256 pixels
    obj.display_size = '256 x 256';
    obj.mm.setROI(952,1152,256,256);
    obj.img_width = 256;
    obj.img_height = 256;
end
end

%%% Added 06/04/15 - setting frame rate (Question!!! - is there a max frame rate we can set???)
function set_framerate(hobj,event,obj)
if ~isnan(str2double(get(hobj,'string')))
    obj.framerate=str2double(get(hobj,'string'));
end
set(hobj,'String',num2str(obj.framerate));

end



