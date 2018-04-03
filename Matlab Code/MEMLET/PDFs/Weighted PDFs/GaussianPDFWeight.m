function [probability] = GaussianPDFWeight(x,w,mu,sig,varargin)
 metaData=   struct('name','Gaussian Weighted',...
                  'PDF',  'GaussianPDFWeight(x,w,mu,sig)',...
            'dataVar','x,w',...
            'fitVar', 'mu,sig',...
            'ub',   '100,100',...
            'lb',   '-100,0',...
            'guess','0,1');
 if nargin==1;
      limtype=x;
      switch limtype
        case 0
        case 1
        metaData.PDF='GaussianPDFWeight(x,w,mu,sig,tmin)';
        case 2
        metaData.PDF='GaussianPDFWeight(x,w,mu,sig,-Inf,tmax)';
         case 3
        metaData.PDF='GaussianPDFWeight(x,w,mu,sig,tmin,tmax)';
    end 
       probability=metaData;
 else
probability = exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi));
if nargin==5;
	tmin=varargin{1};
    tmax=Inf;
    probability=probability/(1-normcdf(tmin,mu,sig));   
elseif nargin==6;
    tmin=varargin{1};
    tmax=varargin{2};
    probability = exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi));
    probability=probability/(normcdf(tmax,mu,sig)-normcdf(tmin,mu,sig));
else
    probability = exp(-((x-mu).^2)/(2.0*sig^2))/(sig*sqrt(2.0*pi));
end 
probability=probability.^w;



end

