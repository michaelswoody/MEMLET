function [probability] = GaussianTwoPDF(x,A,mu,sig,mu2,sig2,varargin)
if nargin==6
   probability = A*(exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi)))+...
    (1-A)*(exp(-((x-mu2).^2)/(2.0*sig2^2))/(sig2*sqrt(2.0*pi))); 
else
    if nargin==7;
        tmin=varargin{1};
        tmax=Inf;
    elseif nargin==8;
        tmin=varargin{1};
        tmax=varargin{2};
    end 
%GaussianPDG custom PDF for single Gaussian distribution
%   Detailed explanation goes here

% is there a pre-defined constant for pi?
%if not

% pi = 3.14159265359;

probability = A*(exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi)))+...
    (1-A)*(exp(-((x-mu2).^2)/(2.0*sig2^2))/(sig2*sqrt(2.0*pi)));
probability=probability/(A*(normcdf(tmax,mu,sig)-normcdf(tmin,mu,sig))...
    +(1-A)*(normcdf(tmax,mu2,sig2)-normcdf(tmin,mu2,sig2)));
end 
end

