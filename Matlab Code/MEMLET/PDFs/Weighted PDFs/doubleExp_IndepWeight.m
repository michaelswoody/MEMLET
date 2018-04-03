function probability=DoubleExp_IndepWeight(t,w,k1,k2,varargin) 
%this PDF is used when there are two sequential steps, but only the final result is observed
  metaData=   struct('name','Double Exp Weighted (Independent) ',...
                'PDF',  '(A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))^w',...
                      'dataVar','t,w',...                    
                    'fitVar', 'A,k1,k2',...
                      'ub',   '1,10000,10000',...
                    'lb',   '0,0,0',...
                    'guess','0.5,10,100');
 if nargin==1;
      limtype=t;
       switch limtype
        case 0
        case 1
        metaData.PDF='((A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))/(A*exp(-k1*tmin)+(1-A)*exp(-k2*tmin)))^w';
         case 2
        metaData.PDF='((A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))/(1-A*exp(-k1*tmax)+1-(1-A)*exp(-k2*tmax)))^w';
         case 3
        metaData.PDF='((A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))/(A*exp(-k1*tmin)-A*exp(-k1*tmax)+(1-A)*exp(-k2*tmin)-(1-A)*exp(-k2*tmax)))^w';
        end
      probability=metaData;
    return
  
 end
 
