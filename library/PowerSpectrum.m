function [ psdx,freq ] = PowerSpectrum( x, Fs )
%give power spectrum of the data
N = length(x);
xdft=fft(x);
xdft=xdft(1:N/2+1);
psdx=(1/(Fs*N))*abs(xdft).^2;
psdx(2:end-1) =  2*psdx(2:end-1);
freq=0:Fs/N:Fs/2;
end

