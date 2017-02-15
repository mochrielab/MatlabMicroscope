classdef TiffIO < handle
    %class for TIFF image IO
    %   11/8/2015
    
    properties 
        rootpath
        handle
        tagstruct
        filename
        tag
        microscope_handle
    end
       
    
    methods
        % create a tiffIO with path and tag
        function obj=TiffIO(path,tag,microscope_handle)
            import YMicroscope.*
            obj.rootpath=path;
            obj.tag=tag;
            obj.microscope_handle = microscope_handle;
        end
        
        % get full saving path
        function datepath=getDataSavePath(obj)
            t=clock;
            datepath=fullfile(obj.rootpath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',...
                num2str(t(1))]);
            if ~exist(datepath,'dir')
                mkdir(datepath);
            end
        end
        
        % get full file name - if no name is typed into UI, then should get
        % '_(tag)_(time).tif' for file name
        function filename=getFullFileName(obj)
            t=clock;
            filename=fullfile(obj.getDataSavePath,[obj.microscope_handle.headername,'_',...
                obj.tag,'_',num2str(t(4),'%02d'),'_',num2str(t(5)...
                ,'%02d'),'_',num2str(round(t(6)),'%02d'),'.tif']);
        end
        
        % Tiff file is open/closed ('rewritten') each time want to save, so
        % cannot create headername in this TiffIO class, since it won't
        % ever be saved ... moving to Microscope.m
        % open file for write
        function fopen(obj,tagstruct)
            if strcmp(obj.tag,'capture')
                % 'a' is for opening/creating file for writing; appending
                % data to end of file
                obj.handle=Tiff(obj.getFullFileName(),'a');
            else
                % w8 is for opening file for writing a BigTIFF file;
                % discards existing contents
                obj.handle=Tiff(obj.getFullFileName(),'w8');
            end
            obj.tagstruct=tagstruct;
            obj.filename=obj.getFullFileName;
        end
        
        % write to file with image
        function fwrite(obj,img)
            if ~isempty(obj.tagstruct)
                obj.handle.setTag(obj.tagstruct);
            end
            obj.handle.write(img);
            obj.handle.writeDirectory;
        end
        
        % close the file
        function fclose(obj,setting)
            obj.handle.close();
            save([obj.filename(1:end-3),'mat'],'setting');
        end
        
    end
    
    events
    end
    
end

