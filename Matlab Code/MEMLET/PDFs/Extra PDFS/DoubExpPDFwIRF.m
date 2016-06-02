function [probability] = DoubExpPDFwIRF(t,C,k1,k2,dt,varargin)
metaData=struct('name','Double Exp PDF for Camera',...
            'PDF',  'DoubExpPDFwIRF(t,C,k1,k2,0.1,tmin)',...
            'dataVar','t',...
            'fitVar', 'C,k1,k2',...
            'ub',   '1,10000,10000',...
            'lb',   '0,0,0',...
            'guess','0.5,10,100');
   if nargin==1;
       probability=metaData;
  return
   end
%DoubExpPDFwIRF custom PDF for double exponential function

%For an arbitrary dwell time measured to be f frames
%long, the expression for the probability below gives the
%likelihood of measuring that dwell time given our current PDF and
%parameter values k1, k2, C.  Since dwell times can physically lie along a
%continuum, but are quantized into integer multiples of camera frames
%during measurement, a range of different dwell times between (f-1)dt and
%(f+1)dt can give a dwell time of fdt with varying probabilities.  Thus,
%the likelihood of measuring f frames is the product: P(actual dwell time t
%based on pdf)*P(dwell time t recorded as f frames) integrated over all the
%actual dwell times t that could be interpreted as f frames long.  In this
%case, P(dwell time t recorded as f frames) is a triangle that starts at
%f-1, peaks at f, and goes back down at f+1.  Using triangles like this
%will help counter-act having histogram bins that are too high in the very
%low dwell times, since the steep double-exponential shape early in the
%curve will make the population 'rounded up' to a higher frame much greater
%than the population 'rounded down' to a lower frame.

%convert dwell times to number of frames
f=t./dt;

if nargin==6;
	tdead=varargin{1};
else
    tdead=0;
end 

unadjlikelihood=(k1*exp(-k2*dt.*(f+1))-k1*exp(-f.*(k2*dt))+C*k1*exp(-f.*(k2*dt))-C*k2*exp(-f.*(k1*dt))+2*k1*sinh(k2*dt/2)*exp(-f.*(k2*dt)+k2*dt/2)-C*k1*exp(-k2*dt.*(f+1))+C*k2*exp(-k1*dt.*(f+1))+2*C*k2*sinh(k1*dt/2)*exp(k1*dt/2-f.*(k1*dt))-2*C*k1*sinh(k2*dt/2)*exp(k2*dt/2-f.*(k2*dt)))/(k1*k2*dt^2);

%With this rounding inherent in the camera frames, we won't pick up any of
%the short events that are under our threshold (and thus counted as 0
%frames).  However, we still need to consider them when we normalize our
%PDF.  So let's calculate the likelhoods corresponding to those 'lost
%frames' and add them to the function we found above before we normalize.
%We can do this by integrating our PDF when weighted by the half-triangle
%that goes down from (0,1) to (deltat, 0)

firsttrianglelikelihood = (C*k1-k1-C*k2+k1*exp(-k2*dt)+k1*k2*dt-C*k1*exp(-k2*dt)+C*k2*exp(-k1*dt))/(k1*k2*dt^2);

%This equation for that 'ignored triangle' is the only extra quantity that
%needs to be added onto our sum of Ln's if there's no dead time, ie fd=1.
%If there is dead time, in additon to that triangle, we also need to add on
%the likelihoods corresponding to all of the dwell times that we miss
%during the dead-time.  I.e., for each frame length that we can't detect,
%we need to evaluate the integral of the PDF*triangle corresponding that
%number of frames, and then sum all those integrals up.

if tdead~=0
    deadframes=tdead/dt;
else
    deadframes=0;
end

deadtimelikelihood = 0;
for i=1:(deadframes-1)
    deadtimelikelihood = deadtimelikelihood + (k1*exp(-k2*dt*(i+1))-k1*exp(-i*k2*dt)+C*k1*exp(-i*k2*dt)-C*k2*exp(-i*k1*dt)+2*k1*sinh(k2*dt/2)*exp(k2*dt/2-i*k2*dt)-C*k1*exp(-k2*dt*(i+1))+C*k2*exp(-k1*dt(i+1))+2*C*k2*sinh(k1*dt/2)*exp(k1*dt/2-i*k1*dt)-2*C*k1*sinh(k2*dt/2)*exp(k2*dt/2-i*k2*dt))/(k1*k2*dt);
end

%Now each number of measured frames f can have a term Lr calculated,
%representing the ratio of the likelihood of measuring f frames, divided by
%the total likelihood of measuring any non-dead time number of frames, ie
%the fraction of measurements that should have that measured dwell time.
%This is more useful to apply to our actual data, which obviously doesn't
%include the dead time events.

Lr=unadjlikelihood./(1-dt*firsttrianglelikelihood-deadtimelikelihood);

%This Lr is the actual likelihood we want to minimize for our MLE fitting

probability=Lr;

if C<0
    probability=0;
end 
end

