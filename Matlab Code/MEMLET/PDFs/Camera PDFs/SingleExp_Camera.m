function [probability] = SingleExp_Camera(t,tau1,dt,tmin)
% discrete PDF for fitting single exponential lifetime data when the data
% is binned as it is when taken using a camera with finite frame time.
% Based on the formulas in "Deconvolution of Camera Instrument Response 
% Functions" Lewis et. al. Biophysical Journal, 2017. To be used with
% MEMLET program originally published in Woody et. al Biophysical Journal, 2016
% Based on Equation 3 of Lewis et. al with the fm=1 correction given in
% Suppmemental Equation S18. 

phi=0.5; % threshold of intensity for camera data. Only is important for when fm=1.

metaData=struct('name','Single Exp PDF for Camera',... %default values for MEMLET
            'PDF',  'SingleExp_Camera(t,tau1,dt,tmin)',...
            'dataVar','t',...
            'fitVar', 'tau1',...
            'ub',   '10000',...
            'lb',   '0',...
            'guess','10');
        


if nargin==1; % returns MetaData when called with only one argument
       probability=metaData;
  return
end

f=t./dt; %convert dwell times to number of frames

if fm==1; %if fm=1 use the correction
    %equation has a factor of 1/dt to convert it from a probability mass
    %function to a probability density function for compatibility with
    %MEMLET's plotting and log-likelihood ratio test functions
      A=phi+(tau1/dt)*(1-exp(-((1-phi)*dt)/tau1)); %fm=1 correction factor Eqn S18
      probability=(1-exp(-dt./tau1)).*exp(-(dt*(f-tmin/dt))./tau1)*1/A;
else %if fm>1 
      probability=(1-exp(-dt./tau1)).*exp(-(dt*(f-tmin/dt))./tau1);
end


end

