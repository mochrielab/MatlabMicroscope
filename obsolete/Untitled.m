datapath='I:\microscope_pics\09_28_2015';
file='1fov1_zstack_13_48_08.tif';
for i=1:50
   im=imread(fullfile(datapath,file),i);
   clf
   SI(im);
   pause
end