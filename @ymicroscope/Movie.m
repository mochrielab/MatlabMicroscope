function [  ] = Movie( obj, varargin )
%taking a movie

if nargin == 1
    UI_enabled = 0;
elseif nargin == 3
    UI_enabled = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end


% do a movie

if strcmp(obj.status,'standing') 
    if UI_enabled
        set(hobj,'String','Stop Movie')
    end
    % movie mod 1
    if (strcmp(obj.movie_mode,'zstack_plain'))
        if UI_enabled
            Movie_ZstackPlain(obj,hobj,event)
        else
            Movie_ZstackPlain(obj);
        end
    end
    % movie mod 2
    if (strcmp(obj.movie_mode,'zstack_singlefile'))
        if UI_enabled
            Movie_Singlefile(obj,hobj,event)
        else
            Movie_Singlefile(obj);
        end
    end
       % movie mod 3
    if (strcmp(obj.movie_mode,'zstack_autofocus'))
        if UI_enabled
            Movie_ZstackAutoFocus(obj,hobj,event)
        else
            Movie_ZstackAutoFocus(obj);
        end
    end
elseif sum(strcmp(cellfun(@(x)['movie_running_',x],obj.movie_mode_options,...
        'UniformOutput',0),obj.status))
    obj.status = 'movie stopping';
    if UI_enabled
        set(hobj,'String','Stopping')
    end
else
    msgbox(['error: microscope is ',obj.status]);
end

