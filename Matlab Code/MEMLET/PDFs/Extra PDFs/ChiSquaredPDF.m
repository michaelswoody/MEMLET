function probability=ChiSquaredPDF(x,k,varargin)


  metaData=struct('name','Chi Squared Distribution',...
           'PDF',   '(1/(2^(k/2)*gamma(k/2)))*(x^(k/2-1)*exp(-x/2))',...
                     'dataVar','x',...                    
                   'fitVar', 'k',...
            'ub',   '100,',...
            'lb',   '0' ,...
            'guess','1'); 
    
      
 if nargin==1;
     probability=metaData;
    return
   end
 

  probability=(1./(2.^(k./2).*gamma(k./2))).*(x.^(k./2-1).*exp(-x./2));
  