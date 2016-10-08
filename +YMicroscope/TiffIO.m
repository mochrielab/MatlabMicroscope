classdef TiffIO < handle
    %class for image IO
    %   11/8/2015
    
    properties 
        rootpath
        handle
        tagstruct
        filename
        tag
    end
       
    
    methods
        function obj=TiffIO(path,tag)
            obj.rootpath=path;
            obj.tag=tag;
        end
        
        function datepath=getDataSavePath(obj)
            t=clock;
            datepath=fullfile(obj.rootpath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',...
                num2str(t(1))]);
            if ~exist(datepath,'dir')
                mkdir(datepath);
            end
        end
        
        function filename=getFullFileName(obj)
            t=clock;
            filename=fullfile(obj.getDataSavePath,[obj.tag,'_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d'),'.tif']);
        end
        
        function fopen(obj,size)
            if strcmp(obj.tag,'capture')
                obj.handle=Tiff(obj.getFullFileName(),'a');
            else
                obj.handle=Tiff(obj.getFullFileName(),'w8');
            end
            obj.tagstruct=obj.getTiffTag('Andor Zyla 5.5',size);
            obj.filename=obj.getFullFileName;
        end
        
        function fwrite(obj,img)
            obj.handle.setTag(obj.tagstruct);
            obj.handle.write(img);
            obj.handle.writeDirectory;
        end
        
        function fclose(obj,setting)
            obj.handle.close();
            save([obj.filename(1:end-3),'mat'],'setting');
        end
        
    end
    
    methods (Static)
        function tagstruct = getTiffTag(camlabel,size)
            if strcmp(camlabel,'Andor Zyla 5.5')
                tagstruct.Artist='Yao Zhao';
                tagstruct.BitsPerSample = 16;
                tagstruct.Compression = Tiff.Compression.None;
                tagstruct.ExtraSamples = Tiff.ExtraSamples.Unspecified;
                tagstruct.HostComputer='Regan Lab''s computer';
                tagstruct.MaxSampleValue=2^12-1;
                tagstruct.MinSampleValue=0;
                tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
                tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
                tagstruct.ResolutionUnit = Tiff.ResolutionUnit.Centimeter;
                tagstruct.SampleFormat = Tiff.SampleFormat.Int;
                tagstruct.SamplesPerPixel = 1;
                tagstruct.Software = 'MATLAB';
                tagstruct.XResolution = 0.000065;
                tagstruct.YResolution = 0.000065;
                tagstruct.ImageLength = size(1);%obj.img_width;
                tagstruct.ImageWidth = size(2);%obj.img_height;
            else
                warning('unsupported camera camera label');
            end
        end
    end
    
end

