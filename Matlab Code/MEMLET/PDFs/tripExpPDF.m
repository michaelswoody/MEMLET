function [probability] = tripExpPDF_2(t,a,b,k1,k2,k3,varargin)

%TRIPEXPPDF custom PDF for triple exponential function
%   Detailed explanation goes here
metaData=struct('name','Triple Exp',...
            'PDF',  'tripExpPDF(t,A,B,k1,k2,k3)',...
            'dataVar','t',...
            'fitVar', 'A,B,k1,k2,k3',...
            'ub',   '1,1,10000,10000,10000',...
            'lb',   '0,0,0,0,0',...
            'guess','0.2,0.4,10,100,1000');
if nargin==1;
    limtype=t;
    switch limtype
        case 0
        case 1
       metaData.PDF='tripExpPDF(t,A,B,k1,k2,k3,tmin)';
        case 2
        metaData.PDF='tripExpPDF(t,A,B,k1,k2,k3,0,tmax)';
         case 3
        metaData.PDF='tripExpPDF(t,A,B,k1,k2,k3,tmin,tmax)';
    end
    probability=metaData;
    return
elseif nargin==7;
	tdead=varargin{1};
    tmax=Inf;
elseif nargin==8;
    tdead=varargin{1};
    tmax=varargin{2};
else
    tdead=0;
    tmax=Inf;
end 
probability=(a*k1*exp(-k1.*t)+b*k2*exp(-k2.*t)+(1-a-b)*k3*exp(-k3.*t))./...
    (a*exp(-k1.*tdead)- a*exp(-k1.*tmax)+...
    b*exp(-k2.*tdead)- b*exp(-k2.*tmax)+...
    (1-a-b)*exp(-k3.*tdead)-(1-a-b)*exp(-k3.*tmax));

if 1-a-b<0
    probability=0;
end 
end

