function [probability] = SinExpCameraIRF(t,k1,dt,varargin)
metaData=struct('name','Single Exp PDF for Camera',...
            'PDF',  'SinExpCameraIRF(t,k1,0.1,tmin)',...
            'dataVar','t',...
            'fitVar', 'k1',...
            'ub',   '10000',...
            'lb',   '0',...
            'guess','10');
 if nargin==1;
       probability=metaData;
  return
   end
%DoubExpPDFwIRF custom PDF for double exponential function
phist=0.1; phiend=0.9;
%convert dwell times to number of frames
f=t./dt;

if nargin==4;
	tdead=varargin{1};
else
    tdead=0;
end 
if tdead==dt;

    firstFrameL=(1/dt)*(1-exp(-k1*dt));
%         correction=((1-exp(-phist*dt*k1))*0.5*phist*phiend)/((1-exp((-2-phiend+phist)*dt*k1))+((1-exp(-phist*dt*k1))*0.5*phist*phiend));
%     correction=((1-exp(-phist*dt*k1))*0.5*phist*phiend)/((1-exp(-(2-phiend+phist)*dt*k1))/2);
    correction=(2*(1-exp(-phist*dt*k1))*0.5*phist*phiend)/((1-exp(-(1-phiend+phist)*dt*k1))-(1-exp(-phist*dt*k1)));
    
%     correction=0;
    firstFrameL=firstFrameL*(1-correction);
else
    firstFrameL=0;
end
probability=(1/dt).*(1-exp(-k1.*dt)).*exp(-k1.*(t-tdead));
probability(t==dt)=firstFrameL;


end

