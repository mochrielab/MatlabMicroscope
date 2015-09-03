function [ tagstruct ] = GetImageTag( obj, camlabel )
%get preset image tags for different camera

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
    tagstruct.ImageLength = obj.img_width;
    tagstruct.ImageWidth = obj.img_height;
else
    warning('unsupported camera camera label');
end

end

