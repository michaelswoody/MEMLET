function [probability] = GaussianPDF(x,mu,sig,varargin)

%GaussianPDG custom PDF for single Gaussian distribution
if nargin==4;
	tmin=varargin{1};
    tmax=Inf;
elseif nargin==5;
    tmin=varargin{1};
    tmax=varargin{2};
else
    tmin=0;
    tmax=Inf;
end 

probability = exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi));
probability=probability/(normcdf(tmax,mu,sig)-normcdf(tmin,mu,sig));
end

