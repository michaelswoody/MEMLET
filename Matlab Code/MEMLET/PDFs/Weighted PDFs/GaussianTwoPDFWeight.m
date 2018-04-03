function [probability] = GaussianTwoPDFWeight(x,w,A,mu,sig,mu2,sig2,varargin)
 metaData=   struct('name','Double Gaussian Weighted',...
                'PDF',  'GaussianTwoPDFWeight(x,w,A,mu,sig,mu2,sig2)',...
                       'dataVar','x,w',...
                    'fitVar', 'A,mu,sig,mu2,sig2',...
                    'ub',   '1,100,100,100,100',...
                    'lb',   '0,-100,0,-100,0',...
                    'guess','0.5,0,1,5,1');
 if nargin==1;
      limtype=x;
       switch limtype
         case 0
        case 1
        metaData.PDF='GaussianTwoPDFWeight(x,w,A,mu,sig,mu2,sig2,tmin)';
        case 2
        metaData.PDF='GaussianTwoPDFWeight(x,w,A,mu,sig,mu2,sig2,-Inf,tmax)';
         case 3
        metaData.PDF='GaussianTwoPDFWeight(x,w,A,mu,sig,mu2,sig2,tmin,tmax)';
       end  
       probability=metaData;
 else
if nargin==7
   probability = A*(exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi)))+...
    (1-A)*(exp(-((x-mu2).^2)/(2.0*sig2^2))/(sig2*sqrt(2.0*pi))); 
else
    if nargin==8;
        tmin=varargin{1};
        tmax=Inf;
    elseif nargin==9;
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

probability=probability.^w;
end

