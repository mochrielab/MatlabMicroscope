function [HWHMstart] = HWHMguess(x0,Nframes,A,y0,SumSqGrad)
%Obtains guess for half width half max of the Lorentzian-type peak by
%finding approximate location of point half way between max and min of the
%peak
diff = zeros([1,size(1:Nframes,2)]);
for i = 1:Nframes
    diff(i) = abs(((A + y0)/2) - SumSqGrad(i));
    %save to dfiference array: absolute value of the difference between the
    %value halfway between the max and min of the peak and the input data
    %points that make the curve
end
HWHM = find(diff==min(diff)); %finds locations where the difference array
%has minimum value(s). The minimum value(s) will give us the point(s)
%closest to the location of the maximum value of the peak
%this will be used as our initial guess/approximation of the half width at
%half max

%if HWHM just contains 1 element (it should), then we don't need to worry 
%about anything, and we'll just go into the first part of the if/else 
%section
if length(HWHM)==1
    HWHMstart = HWHM;
else
%otherwise, we look for the value that is closest to x0 in terms of
%position
    [val,idx] = min(abs(x0-HWHM));
    HWHMstart = HWHM(idx);
end

end

