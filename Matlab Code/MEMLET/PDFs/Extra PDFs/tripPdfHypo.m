function f=tripPdfHypo(t,katp,ks,kw,kb,kc,vargin)

metaData(1)=struct('name','Triple PDF Hypoexp', ...
                    'PDF',   ' tripPdfHypo(t,katp,ks,kw,kb,kc)',...
                     'dataVar','t',...                    
                    'fitVar', 'kb,kc,k1,k2,k3',...
                      'ub',   '1000,1000,1000,10000,10000',...
                    'lb',   '0,0,0,0,0',...
                    'guess','50,20,1,10,100'); 
             
  if nargin==1;
      limtype=t;
      switch limtype
        case 0
        case 1
        metaData.PDF= 'tripPdfHypo(t,katp,ks,kw,kb,kc,tmin)';
        end 
       f=metaData;
  return
  end 
  
if kb==kc
kb=kb+1;
end
if nargin==7;
	tdead=vargin;
else
    tdead=0;
end 
k3=kw+kb;
k2=ks+kc;
k1=katp;
%pdfs for each term
pdfA=k3*exp(-k3*t);
pdfB=(k3*k2)/(k3-k2)*(exp(-k2*t)-exp(-k3*t));
pdfC=((k2/(k2-k3))*(k1/(k1-k3)))*k3*exp(-k3*t)+...
    ((k3/(k3-k2))*(k1/(k1-k2)))*k2*exp(-k2*t)+...
    ((k3/(k3-k1))*(k2/(k2-k1)))*k1*exp(-k1*t);
%relative proportion of each term
a= kw/(kw+kb);
%b=(k2/(k2+kc) -(k3*k2)/((k3+kb)*(k2+kc)));
% b=-((ks*((kw/(kw+kb))-1))/(ks+kc));
% b=a*(ks/(ks+kc)); 
b=-((ks*((kw/(kw+kb))-1))/(ks+kc));
c= 1-a-b;
%demonimator for normalization
dA= exp(-k3*tdead);
dB= +(k2)/(k2-k3)*(exp(-k3*tdead)) -k3/(k2-k3)*(exp(-k2*tdead));
dC= ((k2/(k2-k3))*(k1/(k1-k3)))*exp(-k3*tdead)+...
    ((k3/(k3-k2))*(k1/(k1-k2)))*exp(-k2*tdead)+...
    ((k3/(k3-k1))*(k2/(k2-k1)))*exp(-k1*tdead);
%putting it all together 
N= a*pdfA+b*pdfB+c*pdfC;
D=a*dA+b*dB+c*dC;
f=N/D;



if c<0
    f=0;
end 
end 

% Equation Before July 2nd, 2015 before correcting for competition
% function f=tripPdfHypo(t,k1,k2,k3,kb,kc,vargin)
% if kb==kc
% kb=kb+1;
% end
% if nargin==7;
% 	tdead=vargin;
% else
%     tdead=0;
% end 
% %pdfs for each term
% pdfA=k3*exp(-k3*t);
% pdfB=(kb*k2)/(kb-k2)*(exp(-k2*t)-exp(-kb*t));
% pdfC=((kc/(kc-kb))*(k1/(k1-kb)))*kb*exp(-kb*t)+...
%     ((kb/(kb-kc))*(k1/(k1-kc)))*kc*exp(-kc*t)+...
%     ((kb/(kb-k1))*(kc/(kc-k1)))*k1*exp(-k1*t);
% %relative proportion of each term
% a= k3/(k3+kb);
% %b=(k2/(k2+kc) -(k3*k2)/((k3+kb)*(k2+kc)));
% b=-((k2*((k3/(k3+kb))-1))/(k2+kc));
% c= 1-a-b;
% %demonimator for normalization
% dA= exp(-k3*tdead);
% dB= +(k2)/(k2-kb)*(exp(-kb*tdead)) -kb/(k2-kb)*(exp(-k2*tdead));
% dC= ((kc/(kc-kb))*(k1/(k1-kb)))*exp(-kb*tdead)+...
%     ((kb/(kb-kc))*(k1/(k1-kc)))*exp(-kc*tdead)+...
%     ((kb/(kb-k1))*(kc/(kc-k1)))*exp(-k1*tdead);
% %putting it all together 
% N= a*pdfA+b*pdfB+c*pdfC;
% D=a*dA+b*dB+c*dC;
% f=N/D;
% 
% 
% 
% if c<0
%     f=0;
% end 
% end 