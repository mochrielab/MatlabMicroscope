function [ obj ] = Movie( obj, varargin )
%taking a movie

if nargin == 1
    update_button = 0;
elseif nargin == 3
    update_button = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end


% do a movie

if strcmp(obj.status,'standing') && strcmp(get(hobj,'String'),'Start Movie')
    if update_button
        set(hobj,'String','Stop Movie')
    end
    % movie mod 1
    for itmp=1:double(strcmp(obj.movie_mode,'zstack_plain'))
        if update_button
            Movie_ZstackPlain(obj,hobj,event)
        else
            Movie_ZstackPlain(obj);
        end
    end
    % movie mod 2
    for itmp=1:double(strcmp(obj.movie_mode,'zstack_singlefile'))
        %%
        if update_button
            Movie_Singlefile(obj,hobj,event)
        else
            Movie_Singlefile(obj);
        end

    end
    
elseif strcmp(obj.status,'movie_running_zstack_plain') || ...
        strcmp(obj.status,'movie_running_zstack_singlefile')
    obj.status = 'movie stopping';
    if update_button
        set(hobj,'String','Stopping')
    end
else
    msgbox(['error: microscope is ',obj.status]);
end

