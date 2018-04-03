function probability =singExpWeight(t,w,k1)

metaData=struct('name','Single Exp Weight',...
            'PDF',  '(k1*exp(k1*t))^w',...
            'dataVar','t,w',...
            'fitVar', 'k1',...
            'ub',   '10000',...
            'lb',   '0',...
            'guess','10');            
  if nargin==1;
      limtype=t;
      switch limtype
        case 1 
              metaData.PDF='((k1*exp(-k1*t))/(exp(-k1*tmin)))^w';
        case 2
          metaData.PDF='((k1*exp(-k1*t))/(1-exp(-k1*tmax)))^w'; 
        case 3 
          metaData.PDF='((k1*exp(-k1*t))/(exp(-k1*tmin)-exp(-k1*tmax)))^w';
      end
      probability=metaData;
    return
  
  end
  
  
  probability=(k1*exp(k1*t))^w;