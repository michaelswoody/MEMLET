function [output varargout]=PDFList(PDFname,varargin)
%return values for a given selected PDF
%asking for 'all' gives the names only of every PDF in the database
%varargin{1} is type of data requested
%varagin{2} is the deadtime combination type (0-no limits, 1-tmin only, 2- tmax only, 3 tmin and tmax) 

if nargin==1
    limtype=0;
    type='all';
elseif nargin==2;
    limtype=0;
    type=varargin{1};
else
    type=varargin{1};
    limtype=varargin{2};
  
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
    

 
names{3}='Gaussian';
    builtInPDF(3)=struct('PDF',  'GaussianPDF(x,mu,sig)',...
            'dataVar','x',...
            'fitVar', 'mu,sig',...
            'ub',   '100,100',...
            'lb',   '-100,0',...
            'guess','0,1');
     switch limtype
        case 0
        case 1
        builtInPDF(3).PDF='GaussianPDF(x,mu,sig,tmin)';
        case 2
        builtInPDF(3).PDF='GaussianPDF(x,mu,sig,-Inf,tmax)';
         case 3
        builtInPDF(3).PDF='GaussianPDF(x,mu,sig,tmin,tmax)';
    end
 
       
names{4}='Double Gaussian';
    builtInPDF(4)=struct('PDF',  'GaussianTwoPDF(x,A,mu,sig,mu2,sig2)',...
            'dataVar','x',...
            'fitVar', 'A,mu,sig,mu2,sig2',...
            'ub',   '1,100,100,100,100',...
            'lb',   '0,-100,0,-100,0',...
            'guess','0.5,0,1,5,1');
         switch limtype
        case 0
        case 1
        builtInPDF(4).PDF='GaussianTwoPDF(x,A,mu,sig,mu2,sig2,tmin)';
        case 2
        builtInPDF(4).PDF='GaussianTwoPDF(x,A,mu,sig,mu2,sig2,-Inf,tmax)';
         case 3
        builtInPDF(4).PDF='GaussianTwoPDF(x,A,mu,sig,mu2,sig2,tmin,tmax)';
    end

%scan folder for PDF files 
ProgDir=which('PDFList.m');
ProgDir=ProgDir(1:end-9);
PDFDir=[ProgDir 'PDFs\'];
 fildPDFs=[]; filenames=[];
if isdir(PDFDir)
    listing =  dir(PDFDir);
    listing=listing(cellfun(@(x) x==0, {listing.isdir}));
    addpath(PDFDir);
     for i=1:size(listing,1) %skips . and ..
        filePDFs(i)=eval([listing(i).name(1:end-2) '(' num2str(limtype) ');']);
        fileNames{i}=filePDFs(i).name; 
        filePDFs(i)=eval([listing(i).name(1:end-2) '(' num2str(limtype) ');']);
     end   
    filePDFs = rmfield(filePDFs,'name');
    builtInPDF=[builtInPDF  filePDFs];
    names=[names  fileNames];
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