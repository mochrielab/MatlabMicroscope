function [  ] = SetupUI( obj )
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
% light button
light_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[15 245 200 60],...
    'String','Light On','Fontsize',20,...
    'Callback',@(hobj,event)switch_light(hobj,event,obj));
% stage button
light_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
    'Unit','Pixels','Position',[240 245 200 60],...
    'String','JS Disabled','Fontsize',20,...
    'Callback',@(hobj,event)enable_joystick(hobj,event,obj));
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

% % DAQpkg button
% ImgSeq_handle=uicontrol('Parent',controlpanel_handle,'Style','pushbutton',...
%     'Unit','Pixels','Position',[690 245 200 60],...
%     'String','ImgSeq','Fontsize',20,...
%     'Callback',@(hobj,event)obj.DAQpkg(hobj,event));
%% set illumination mode
illumination_options=obj.illumination_mode_options;
illumination_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[15 175 200 20],'Value',find(strcmp(illumination_options,obj.illumination_mode)),...
    'String',illumination_options,'Fontsize',10,...
    'Callback',@(hobj,event)set_illumination_mode(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[15 195 200 20],...
    'String','Illumination Mode','Fontsize',10);
%% set movie mode
moviemode_options=obj.movie_mode_options;
illumination_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[15 95 200 20],'Value',find(strcmp(obj.movie_mode,moviemode_options)),...
    'String',moviemode_options,...
    'Fontsize',10,'Callback',@(hobj,event)set_movie_mode(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[15 115 200 20],...
    'String','Movie Mode','Fontsize',10);
%% set display mode ROI
ROI_options=obj.display_size_options;
ROI_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[240 175 200 20],'Value',find(strcmp(ROI_options,obj.display_size)),...
    'String',ROI_options,'Fontsize',10,...
    'Callback',@(hobj,event)set_ROI(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[240 195 200 20],...
    'String','Display Size','Fontsize',10);
%% set biology sample type
sample_type_handle=uicontrol('Parent',controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[240 95 200 20],'Value',find(strcmp(obj.sample_type_options,obj.sample_type)),...
    'String',obj.sample_type_options,'Fontsize',10,...
    'Callback',@(hobj,event)set_sample_type(hobj,event,obj));
uicontrol('Parent',controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[240 115 200 20],...
    'String','sample type','Fontsize',10);
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
    'Position',[15 340 200 20],'Style','edit',...
    'String',num2str(obj.exposure_brightfield),...
    'Callback',@(hobj,event)set_brightfield_exposure(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 360 200 20],'Style','text','String',...
    'Brightfield Exposure (ms)');

% illumination intensity 
fluorescent_illumination_intensity_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 290 200 20],'Style','edit',...
    'String',num2str(obj.fluorescent_illumination_intensity),...
    'Callback',@(hobj,event)set_fluorescent_illumination_intensity(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[15 310 200 20],'Style','text','String',...
    'Fluorescent Illumination Intensity (0-255)');

% z offset
zoffset_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 390 200 20],'Style','edit',...
    'String',num2str(obj.zoffset),...
    'Callback',@(hobj,event)set_zoffset(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 410 200 20],'Style','text','String',...
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

% z stack size
znum_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 290 200 20],'Style','edit',...
    'String',num2str(obj.stepsize),...
    'Callback',@(hobj,event)set_stepsize(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[230 310 200 20],'Style','text','String',...
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
movie_interval_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 340 200 20],'Style','edit',...
    'String',num2str(obj.movie_interval),...
    'Callback',@(hobj,event)set_movie_interval(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 360 200 20],'Style','text','String',...
    'Movie Interval (mins)');

% movie repeat
movie_cycles_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 290 200 20],'Style','edit',...
    'String',num2str(obj.movie_cycles),...
    'Callback',@(hobj,event)set_movie_cycles(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[445 310 200 20],'Style','text','String',...
    'Movie Cycles');

% framerate
experimentname_handle=...
    uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[660 390 200 20],'Style','edit',...
    'String',num2str(obj.experiment_name),...
    'Callback',@(hobj,event)set_experiment_name(hobj,event,obj));
uicontrol('Parent',parampanel_handle,'Unit','Pixels',...
    'Position',[660 410 200 20],'Style','text','String',...
    'Experiment Name');
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

function set_fluorescent_illumination_intensity(hobj,event,obj)
if ~isnan(str2double(get(hobj,'string')))
    obj.fluorescent_illumination_intensity=str2double(get(hobj,'string'));
end
set(hobj,'String',num2str(obj.fluorescent_illumination_intensity));
end

function set_zoffset(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<0
    elseif input>10
    else
        obj.zoffset=input;
    end
end
set(hobj,'String',num2str(obj.zoffset));
obj.nidaq.outputSingleScan(obj.zoffset);
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

function set_movie_interval(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<0
    else
        obj.movie_interval=input;
    end
end
set(hobj,'String',num2str(obj.movie_interval));
end

function set_movie_cycles(hobj,event,obj)
input=str2double(get(hobj,'string'));
if ~isnan(input)
    if input<=0
    else
        obj.movie_cycles=input;
    end
end
set(hobj,'String',num2str(obj.movie_cycles));
end

function set_illumination_mode(hobj,event,obj)

input=get(hobj,'value');
if input==1 %No light sources are on
    obj.illumination_mode='None'; %no illumination modes selected
    if strcmp(obj.status,'live_running')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([0 0]);
    end
elseif input==2
    obj.illumination_mode='Brightfield - W'; %ßselect white LED
    if strcmp(obj.status,'live_running')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([1 0]);
    end
elseif input==3
    obj.illumination_mode='Brightfield - R'; % select red LED
    if strcmp(obj.status,'live_running')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([0 1]);
    end
elseif input==4
    obj.illumination_mode='Fluorescent';
    if strcmp(obj.status,'live_running')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        obj.nidaq2.outputSingleScan([0 0]);
    end
end
end

function set_movie_mode(hobj,event,obj)

input=get(hobj,'value');
obj.movie_mode=obj.movie_mode_options{input};
end

function set_sample_type(hobj,event,obj)

input=get(hobj,'value');
obj.sample_type=obj.sample_type_options{input};

end

function set_ROI(hobj,event,obj)
input=get(hobj,'value');
obj.display_size=obj.display_size_options{input};
end

function set_framerate(hobj,event,obj)
if ~isnan(str2double(get(hobj,'string')))
    obj.framerate=str2double(get(hobj,'string'));
end
set(hobj,'String',num2str(obj.framerate));

end

function set_experiment_name(hobj,event,obj)
% if ~isnan(str2double(get(hobj,'string')))
    obj.experiment_name=(get(hobj,'string'));
% end
set(hobj,'String',(obj.experiment_name));

end

function switch_light(hobj,event,obj)
    if strcmp(obj.status,'standing')
        obj.status='light on';
        hobj.set('string','Light Off');
        obj.SwitchLight('on');
    elseif strcmp(obj.status,'light on')
        obj.status='standing';
        hobj.set('string','Light On');
        obj.SwitchLight('off');
    else
        msgbox(['microscope status is ',obj.status]);
    end
end

function enable_joystick(hobj,event,obj)
    if obj.joystick_enabled==0
        hobj.set('string','JS Enabled');
        obj.joystick_enabled = 1;
        obj.JoystickControl;
    elseif obj.joystick_enabled==1
        hobj.set('string','JS Disabled');
        obj.joystick_enabled = 0;
    else
        msgbox(['joystick status is ',obj.joystick_enabled]);
    end
end

