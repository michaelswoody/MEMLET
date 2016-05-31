function probability =PDF_1fdep_1findp_par(t,k1,d,k2)
 metaData=struct('name','1 Fdep, 1 Findp parallel',...
                'PDF',   '((k1*exp(-(F*d)/4.1)+k2)*exp(-(k1*exp(-(F*d)/4.1)+k2)*t))',...
                     'dataVar','t,F',...                    
                    'fitVar', 'k1,d,k2',...
                      'ub',   '1000,1000,1000',...
                    'lb',   '0,-100,0',...
                    'guess','1,5,20');
  if nargin==1;
      limtype=t;
      switch limtype
        case 0
        case 1
        metaData.PDF= '((k1*exp(-(F*d)/4.1)+k2)*exp(-(k1*exp(-(F*d)/4.1)+k2)*t))/(exp(-(k1*exp(-(F*d)/4.1)+k2)*tmin))';
        end 
      probability=metaData;
    return
  
  end  
  
  switch limtype
        case 0
             probability=((k1.*exp(-(F.*d)./4.1)+k2).*exp(-(k1.*exp(-(F.*d)./4.1)+k2).*t)); 
        case 1
            probability=((k1.*exp(-(F.*d)./4.1)+k2).*exp(-(k1.*exp(-(F.*d)./4.1)+k2).*t))./(exp(-(k1*exp(-(F*d)/4.1)+k2)*tmin)); 
        end 
 