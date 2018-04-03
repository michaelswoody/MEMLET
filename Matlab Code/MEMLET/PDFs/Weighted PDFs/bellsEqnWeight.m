function probability =bellsEqnWeight(t,F,w,k1,d)

metaData=struct('name','Bell''s Equation Weight',...
            'PDF',  '((k1*exp(-(F*d)/4.1))*exp(-(k1*exp(-(F*d)/4.1))*t))^w',...
            'dataVar','t,F,w',...
            'fitVar', 'k1,d',...
            'ub',   '10000,100',...
            'lb',   '0,-100',...
            'guess','10,0');            
  if nargin==1;
      limtype=t;
      switch limtype
        case 1 
              metaData.PDF='(((k1*exp(-(F*d)/4.1))*exp(-(k1*exp(-(F*d)/4.1))*t))/(exp(-(k1*exp(-(F*d)/4.1))*tmin)))^w';
        end 
      probability=metaData;
    return
  
  end
  
  
  probability=((k1.*exp(-(F.*d)./4.1)).*exp(-(k1.*exp(-(F*d)./4.1)).*t))^w;