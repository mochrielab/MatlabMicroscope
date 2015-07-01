function [MaxLoc] = LorentzPkFit(Nframes,SumSqGrad)
x=(1:Nframes)';
yOrig=SumSqGrad';
figure;
plot(x,yOrig,'.b'); %plots original data
hold on;

%% formulate initial guesses for parameters
y0 = min(SumSqGrad); %guess for offset
A = max(SumSqGrad); %guess for amplitude
x0 = find(SumSqGrad == A,1,'first'); %guess position of max
w = abs(HWHMguess(x0,Nframes,A,y0,SumSqGrad) - x0); %guess for HWHM
initialCond=[y0,A,w,x0];

%% use nlinfit to fit data with user-defined Lorentzian peak fnc
paramFinal=nlinfit(x,yOrig,@NormLorentzian,initialCond);
yEnd=NormLorentzian(paramFinal,x);
plot(x,yEnd,'-g'); %plots the fit on top of the data read in
legend('Orig','Fit');

%% Finding location of max value based off of fit
LorentzMax = max(yEnd); %finds maximum of the fit    
MaxLoc = find(yEnd == LorentzMax,1,'first'); %finds first index
%corresponding to maximum value of Lorentzian fit
end








