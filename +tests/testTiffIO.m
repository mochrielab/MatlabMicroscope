import YMicroscope.*

% constructor
tio = TiffIO('','test');
display('created TiffIO');

% get save path
tiopath = tio.getDataSavePath()
display('got data save path')

% get full name
tio.getFullFileName()
display('got full file name')

% save image
imgdata = uint8(eye(300,300));
tagstruct.ImageLength = size(imgdata,1);
tagstruct.ImageWidth = size(imgdata,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';
tio.fopen(tagstruct)
tio.fwrite(imgdata)
tio.fclose([])
display('save tmp image')

% delete
delete(tio)
display('delete object')

% remove folder
rmdir(tiopath)