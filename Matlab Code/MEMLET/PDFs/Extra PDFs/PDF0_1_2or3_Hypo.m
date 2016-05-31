function probability= PDF0_1_2or3_Hypo(t,k1,k2,k3,varargin)


   metaData=struct('name','0->1-->{2 or 3}  HypoExponential',...
                'PDF',   '(k2/(k2+k3))*(k1*k2)/(k1-k2)*(exp(-t*k2)-exp(-t*k1))+(k3/(k2+k3))*(k1*k3)/(k1-k3)*(exp(-t*k3)-exp(-t*k1))',...
                     'dataVar','t',...                    
                    'fitVar', 'k1,k2,k3',...
                      'ub',   '1000,1000,1000',...
                    'lb',   '0,0,0',...
                    'guess','1,10,20');
 if nargin==1;
      limtype=t;
      switch limtype
        case 0
        case 1
        metaData.PDF= 'PDF0_1_2or3_Hypo(t,k1,k2,k3,tmin)';
        end 
      probability=metaData;
    return
  
 end    
 if nargin==5;
      tmin=varargin{1};
 else
     tmin=0; 
 end      
  
 probability=(k2./(k2+k3)).*(k1.*k2)./(k1-k2).*(exp(-t.*k2)-exp(-t.*k1))+(k3./(k2+k3)).*(k1.*k3)./(k1-k3).*(exp(-t.*k3)-exp(-t.*k1))./...
      (k2./(k2+k3)).*(k1.*k2)./(k1-k2).*(exp(-tmin.*k2)./k2-exp(-tmin.*k1)./k1)+(k3./(k2+k3)).*(k1.*k3)./(k1-k3).*(exp(-tmin.*k3)./k3-exp(-tmin.*k1)./k1);