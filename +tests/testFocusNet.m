
% load example image
% im = imread(fullfile('examples', 'images', '16.tif'));
% load focus net
fn = YMicroscope.FocusNet(fullfile('models', 'probnet22'), 16);

%% load image
tic
ax=axes();colormap gray; axis image;
act = MicroscopeActionCapture(m, ax);
img = act.run();
fn.loadImages(img);
toc
%% inference
tic
fn.inference();
toc
% plot
fn.plot(img);
%% debug
a = fn.net.blobs('data').get_data();


%             figure('Position', [50 50 800 800])
