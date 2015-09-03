function [y]=NormLorentzian(param,x)
%function gives formula describing lorentzian peak for fitting purposes
y0 = param(1); %offset
A = param(2); %amplitude
w = param(3); %half-width at half-max
x0 = param(4); %position of maximum value
y = y0+(2*A/pi).*(w./(4*(x-x0).^2+w.^2)); %normalized lorentzian peak func.
end
