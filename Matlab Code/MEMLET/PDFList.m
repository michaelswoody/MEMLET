function [output varargout]=PDFList(PDFname,varargin)
%return values for a given selected PDF
%asking for 'all' gives the names only of every PDF in the database
%varargin{1} is type of data requested
%varagin{2} is the deadtime combination type (0-no limits, 1-tmin only, 2- tmax only, 3 tmin and tmax) 

if nargin==1
 
    type='all';
elseif nargin==2;
 
    type=varargin{1};
else
    type=varargin{1};
    limtype=varargin{2};
  
end
%custom PDFs
%start with index 1, follow the format below filling in where there is ***
% be sure to increment the index for each new PDF you add 

% custNames{1}='';

               
%    customPDF(1)=struct('PDF',   '  ',...
%                      'dataVar','   ',...                    
%                     'fitVar', '    ',...
%                       'ub',   '    ',...
%                     'lb',   '    ',...
%                     'guess','    ');
%                 
%                  
    switch limtype % allows different PDFS to be specified for various cases
        case 0 % case when no tmin or tmax
        case 1 % case with tmin only 
        customPDF(1).PDF='   ';
        case 2 % case with tmax only
        customPDF(1).PDF='   '; 
        case 3 % case with both tmin and tmax
        customPDF(1).PDF='    '; 
    end  
                
     
                
        
%built in PDFs
names{1}='Single Exp';
    builtInPDF(1)=struct('PDF',   'k1*exp(-k1*t)',...
                     'dataVar','t',...                    
                    'fitVar', 'k1',...
                      'ub',   '10000',...
                    'lb',   '0',...
                    'guess','10');
    switch limtype
        case 0
        case 1
        builtInPDF(1).PDF='(k1*exp(-k1*t))/(exp(-k1*tmin))';
        case 2
        builtInPDF(1).PDF='(k1*exp(-k1*t))/(1-exp(-k1*tmax))'; 
        case 3 
        builtInPDF(1).PDF='(k1*exp(-k1*t))/(exp(-k1*tmin)-exp(-k1*tmax))'; 
    end  
 
names{2}='Double Exp';
    builtInPDF(2)=struct('PDF',  'A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t)',...
                      'dataVar','t',...                    
                    'fitVar', 'A,k1,k2',...
                      'ub',   '1,10000,10000',...
                    'lb',   '0,0,0',...
                    'guess','0.5,10,100');
 switch limtype
        case 0
        case 1
        builtInPDF(2).PDF='(A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))/(A*exp(-k1*tmin)+(1-A)*exp(-k2*tmin))';
         case 2
        builtInPDF(2).PDF='(A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))/(1-A*exp(-k1*tmax)+1-(1-A)*exp(-k2*tmax))';
         case 3
        builtInPDF(2).PDF='(A*k1*exp(-k1*t)+(1-A)*k2*exp(-k2*t))/(A*exp(-k1*tmin)-A*exp(-k1*tmax)+(1-A)*exp(-k2*tmin)-(1-A)*exp(-k2*tmax))';
    end
    
names{3}='Triple Exp';
    builtInPDF(3)=struct('PDF',  'tripExpPDF(t,A,B,k1,k2,k3)',...
            'dataVar','t',...
            'fitVar', 'A,B,k1,k2,k3',...
            'ub',   '1,1,10000,10000,10000',...
            'lb',   '0,0,0,0,0',...
            'guess','0.2,0.4,10,100,1000');
    switch limtype
        case 0
        case 1
        builtInPDF(3).PDF='tripExpPDF(t,A,B,k1,k2,k3,tmin)';
        case 2
        builtInPDF(3).PDF='tripExpPDF(t,A,B,k1,k2,k3,0,tmax)';
         case 3
        builtInPDF(3).PDF='tripExpPDF(t,A,B,k1,k2,k3,tmin,tmax)';
    end
 
names{4}='Gaussian';
    builtInPDF(4)=struct('PDF',  'GaussianPDF(x,mu,sig)',...
            'dataVar','x',...
            'fitVar', 'mu,sig',...
            'ub',   '100,100',...
            'lb',   '-100,0',...
            'guess','0,1');
     switch limtype
        case 0
        case 1
        builtInPDF(4).PDF='GaussianPDF(x,mu,sig,tmin)';
        case 2
        builtInPDF(4).PDF='GaussianPDF(x,mu,sig,-Inf,tmax)';
         case 3
        builtInPDF(4).PDF='GaussianPDF(x,mu,sig,tmin,tmax)';
    end
 
       
names{5}='Double Gaussian';
    builtInPDF(5)=struct('PDF',  'GaussianTwoPDF(x,A,mu,sig,mu2,sig2)',...
            'dataVar','x',...
            'fitVar', 'A,mu,sig,mu2,sig2',...
            'ub',   '1,100,100,100,100',...
            'lb',   '0,-100,0,-100,0',...
            'guess','0.5,0,1,5,1');
         switch limtype
        case 0
        case 1
        builtInPDF(5).PDF='GaussianTwoPDF(x,A,mu,sig,mu2,sig2,tmin)';
        case 2
        builtInPDF(5).PDF='GaussianTwoPDF(x,A,mu,sig,mu2,sig2,-Inf,tmax)';
         case 3
        builtInPDF(5).PDF='GaussianTwoPDF(x,A,mu,sig,mu2,sig2,tmin,tmax)';
    end
    
names{6}='Bell''s Equation';
    builtInPDF(6)=struct('PDF',  '(k1*exp(-(F*d)/4.1))*exp(-(k1*exp(-(F*d)/4.1))*t)',...
            'dataVar','t,F',...
            'fitVar', 'k1,d',...
            'ub',   '10000,100',...
            'lb',   '0,-100',...
            'guess','10,0');
   switch limtype
        case 0
        case 1
        builtInPDF(6).PDF= '((k1*exp(-(F*d)/4.1))*exp(-(k1*exp(-(F*d)/4.1))*t))/(exp(-(k1*exp(-(F*d)/4.1))*tmin))';
    end    
    
      names{7}='Gamma';
   builtInPDF(7)=struct('PDF',   '(k^alpha/gamma(alpha))*t^(alpha-1)*exp(-k*t)',...
                     'dataVar','t',...                    
                    'fitVar', 'k,alpha',...
                      'ub',   '1000,1000',...
                    'lb',   '0,0',...
                    'guess','50,2');
 names{8}='Chisquared';
   builtInPDF(8)=struct('PDF',   '(1/(2^(k/2)*gamma(k/2))*(x^(k/2-1)*exp(-x/2))',...
                     'dataVar','x',...                    
                   'fitVar', 'k',...
            'ub',   '100,',...
            'lb',   '0' ,...
            'guess','1');
        
        names{9}='Beta';
   builtInPDF(9)=struct('PDF',   '(x^(a-1)*(1-x)^(b-1))/beta(a,b)',...
                     'dataVar','x',...                    
                   'fitVar', 'a,b',...
            'ub',   '100,100',...
            'lb',   '0,0' ,...
            'guess','1,2');     
        
        
if exist('custNames')
    builtInPDF=[builtInPDF customPDF];
    names=[names custNames];
end
 %read things 
if strcmp(PDFname,'all') %returns all the names of the PDFs 
    output=names;
else 
    Index = find(strcmp(names,PDFname));
   if nargout==6 %returns all values for the given PDF
       output=eval(sprintf('builtInPDF(%d).PDF',Index));
       varargout{1}=eval(sprintf('builtInPDF(%d).dataVar',Index));
       varargout{2}=eval(sprintf('builtInPDF(%d).fitVar',Index));
       varargout{3}=eval(sprintf('builtInPDF(%d).lb',Index));
       varargout{4}=eval(sprintf('builtInPDF(%d).ub',Index));
       varargout{5}=eval(sprintf('builtInPDF(%d).guess',Index));
   else
       output=eval(sprintf('builtInPDF(%d).%s',Index,type));
   end
end 
end