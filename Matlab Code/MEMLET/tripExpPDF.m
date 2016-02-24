function [probability] = tripExpPDF(t,a,b,k1,k2,k3,varargin)

%TRIPEXPPDF custom PDF for triple exponential function
%   Detailed explanation goes here

if nargin==7;
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

