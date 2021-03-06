function [probability] = DoubleExp_Camera(t,C,tau1,tau2,dt,tmin)
% discrete PDF for fitting single exponential lifetime data when the data
% is binned as it is when taken using a camera with finite frame time.
% Based on the formulas in "Deconvolution of Camera Instrument Response 
% Functions" Lewis et. al. Biophysical Journal, 2017. To be used with
% MEMLET program originally published in Woody et. al Biophysical Journal, 2016
% Based on Equation 7 of Lewis et. al with the fm=1 correction derived in 
% a similar way as S18 was derived for the single exponential case. 

phi=0.5; %intensity threshold for detecting events, only comes into play for fm=1

metaData=struct('name','Double Exp PDF for Camera',...
            'PDF',  'DoubleExp_Camera(t,C,tau1,tau2,del_t,tmin)',...
            'dataVar','t',...
            'fitVar', 'C,tau1,tau2',...
            'ub',   '1,1000,1000',...
            'lb',   '0,0,0',...
            'guess','0.5,0.1,10');
if nargin==1; %returns the MetaData when only one argument is given
    probability=metaData;
    return
end

%convert dwell times to number of frames
f=t./dt;

fm=tmin/dt; %minimum number of frames 

if fm==1;
    %equation has a factor of 1/dt to convert it from a probability mass
    %function to a probability density function for compatibility with
    %MEMLET's plotting and log-likelihood ratio test functions
    probability= 1/dt*(C*tau1*(1-exp(-dt/tau1))^2*exp((-dt/tau1)*(f-1))+(1-C)*tau2*(1-exp(-dt/tau2))^2*exp((-dt/tau2)*(f-1)))...
        /(C*tau1*(1-exp(((-dt*(1+(1-phi)^2))/tau1)))+(1-C)*tau2*(1-exp(((-dt*(1+(1-phi)^2))/tau2))));
else
    probability=1/dt*(C*tau1*(1-exp(-dt/tau1))^2*exp((-dt/tau1)*(f-1))+(1-C)*tau2*(1-exp(-dt/tau2))^2*exp((-dt/tau2)*(f-1)))...
       /(C*tau1*(1-exp(-dt/tau1))*exp((-dt/tau1)*(fm-1))+(1-C)*tau2*(1-exp(-dt/tau2))*exp((-dt/tau2)*(fm-1)));
end
 
end

