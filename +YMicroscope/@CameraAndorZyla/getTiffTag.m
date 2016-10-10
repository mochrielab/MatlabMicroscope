% get tiff tag, for saving tiff images
function tagstruct = getTiffTag(obj)
size = obj.getSize();
tagstruct.Artist='Yao Zhao';
tagstruct.BitsPerSample = 16;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.ExtraSamples = Tiff.ExtraSamples.Unspecified;
tagstruct.HostComputer='Regan Lab''s computer';
tagstruct.MaxSampleValue=2^16-1;
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
end