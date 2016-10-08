function [GradArray] = ImgGrad(Nframes,stack)
%function reads in the images from a z-stack scan and then determines the
%sum of the squares of the gradients of each image
%basic idea is that the image in the stack that is the correct focal plane
%will be the one that is the sharpest - i.e. have the largest gradients
%Thus when we obtain an array of the values calculated in this function, a
%subsequent plot could be fitted with some Gaussian function; the maximum
%of that fit determined; and the approximately best in-focus plane
%localized

GradArray = zeros(1,Nframes);
for i=1:Nframes
    mag = imgradient(stack(:,:,i),'Sobel');
    magSq = mag.^2; %squaring the gradient values found using imgradient
    SumMagSq = sum(sum(magSq)); %sum of the squares of the gradients per img
    GradArray(i) = SumMagSq;
end
% figure; plot(1:Nframes,GradArray,'.r');
end

