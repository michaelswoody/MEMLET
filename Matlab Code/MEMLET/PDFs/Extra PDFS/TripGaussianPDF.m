function [probability] = TripGaussianPDF(x,A,B,mu,mu2,mu3,sig1,sig2,sig3)
 metaData=struct('name','Triple Gaussian',...
                'PDF',   'TripGaussianPDF(x,A,B,mu,mu2,mu3,sig1,sig2,sig3)',...
                     'dataVar','x',...                    
                    'fitVar', 'A,B,mu,mu2,mu3,sig1,sig2,sig3',...
                      'ub',   '1,1,100,100,100,100,100,100',...
                    'lb',   '0,0,-100,-100,-100,0,0,0',...
                    'guess','.33,.33,1,-1,0,5,5,5');
if nargin==1; 
    probability=metaData;
    return
end  
    if (1-A-B)<0
        probability=0;
        return
    end
   probability = A*(exp(-((x-mu).^2)/(2.0*sig1^2))/(sig1*sqrt(2.0*pi)))+...
    (B)*(exp(-((x-mu2).^2)/(2.0*sig2^2))/(sig2*sqrt(2.0*pi)))+...
    (1-A-B)*(exp(-((x-mu3).^2)/(2.0*sig3^2))/(sig3*sqrt(2.0*pi)));
 
%GaussianPDG custom PDF for single Gaussian distribution
%   Detailed explanation goes here

% is there a pre-defined constant for pi?
%if not

% pi = 3.14159265359;


 
end

