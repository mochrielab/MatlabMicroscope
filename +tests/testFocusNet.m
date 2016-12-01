
% load example image
im = imread(fullfile('examples', 'images', '16.tif'));
% load focus net
fn = YMicroscope.FocusNet(fullfile('models', 'probnet22'), 16);

%% load image
tic
fn.loadImages(im);
toc
%% inference
tic
fn.inference();
toc
%%
fn.plot(im);