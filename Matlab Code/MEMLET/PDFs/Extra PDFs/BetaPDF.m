function probability=BetaPDF(x,a,b,varargin)


  metaData=struct('name','Beta Distribution',...
           'PDF',   '(x^(a-1)*(1-x)^(b-1))/beta(a,b)',...
                     'dataVar','x',...                    
                   'fitVar', 'a,b',...
            'ub',   '100,100',...
            'lb',   '0,0' ,...
            'guess','1,2');     
    
      
 if nargin==1;
     probability=metaData;
    return
 end
 

  probability=(x.^(a-1).*(1-x).^(b-1))./beta(a,b);
  