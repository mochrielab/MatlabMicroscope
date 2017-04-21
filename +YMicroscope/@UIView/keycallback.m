function keycallback(src,obj)
% obj.figure_handle.get(gcf,'CurrentCharacter')
    switch obj.figure_handle.get(gcf,'CurrentKey')
        case 'leftarrow'
            disp('move left')
        case 'rightarrow'
            disp('move right')
        case 'uparrow'
            disp('move up')
        case 'downarrow'
            disp('move down')
        case 'j'
            disp('move in')
        case 'k'
            disp('move out')
    end
end