function [output varargout]=PDFList(PDFname,varargin)
%(v1.3) return values for a given PDF, will scan the subfolder "PDFs" to
%look for additional PDFS, included weighted. See User's Guide for more details
%asking for 'all' gives the names only of every PDF in the database
%varargin{1} is type of data requested
%varagin{2} is the deadtime combination type (0-no limits, 1-tmin only, 2- tmax only, 3 tmin and tmax) 

if nargin==1
    limtype=0;
    type='all';
    origPDFname=PDFname;
    search=[1];
   
    if ~isempty(strfind(origPDFname,'Oth'))
        PDFname='all';
        search=[search 2];
    end 
    if ~isempty(strfind(origPDFname,'Cam'))
        PDFname='all';
        search=[search 3];
    end 
    if ~isempty(strfind(origPDFname,'Wei'))
        PDFname='all';
        search=[search 4];
    end
    
     if strcmp(PDFname,'all')
     elseif strcmp(PDFname,origPDFname)
        search=[1 2 3 4]; 
     end

elseif nargin==2;
    limtype=0;
    type=varargin{1};
    search=[1 2 3 4];  
else
    type=varargin{1};
    limtype=varargin{2};
    search=[1 2 3 4];  
end
if ispc;
    searchDirs={'PDFs','PDFs\Extra PDFs\','PDFs\Camera PDFs\','PDFs\Weighted PDFs\'};
else 
    searchDirs={'PDFs/','PDFs/Extra PDFs/','PDFs/Camera PDFs/','PDFs/Weighted PDFs/'};
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
 
names{2}='Double Exp (Independent)';
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

for j=search;
      clear filePDFs  filenames
     curSearch=searchDirs{j};
    if isdeployed % Stand-alone mode.
        [status, result] = system('path');
        ProgDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        PDFDir =[ProgDir '\' curSearch];
    else
        ProgDir=which('PDFList.m');
        ProgDir=ProgDir(1:end-9);
        PDFDir=[ProgDir curSearch];
        addpath(PDFDir);
    end

if isdir(PDFDir)
    try
    listing =  dir(PDFDir);
    listing=listing(cellfun(@(x) x==0, {listing.isdir})); %skips . and ..

    k=1;
       for i=1:size(listing,1) 
         % add any new PDF's to the working root directory 
           if strcmp(listing(i).name(end-3:end),'.txt') %read basic PDF from txt files 
               try
                fileID=fopen([PDFDir listing(i).name],'r');
                name=  strtrim(fgetl(fileID)); %read name first 
                if isempty(strfind(name,'template'))&&isempty(strfind(name,'Instructions'))
                    filePDFs(k).name = name; %for consistency
                    fileNames{k}=filePDFs(k).name;
                    filePDFs(k).PDF = strtrim(fgetl(fileID)); %read PDF 
                    filePDFs(k).dataVar = strtrim(fgetl(fileID)); %read datavars
                    filePDFs(k).fitVar = strtrim(fgetl(fileID)); %read fit vars  
                    filePDFs(k).ub = strtrim(fgetl(fileID)); %read upper bounds
                    filePDFs(k).lb = strtrim(fgetl(fileID)); %read name first 
                    filePDFs(k).guess = strtrim(fgetl(fileID)); %read name first
                     k=k+1;
                else
                end
                fclose(fileID);
                
               catch
                 msgbox([listing(i).name(end-3:end) 'is not properly formatted'])
               end
           else  %read other PDFs if they aren't more complicated 
               try %try to use .m file PDFS, but won't work with standalone if they haven't been compiled. 
                    if isempty(strfind(listing(i).name(1:end-2),'Template'))
                        if ~strcmp(listing(i).name(1),'.') % ignore .DStore, etc files
                        filePDFs(k)=eval([listing(i).name(1:end-2) '(' num2str(limtype) ');']);
                        fileNames{k}=filePDFs(k).name; 
                        filePDFs(k)=eval([listing(i).name(1:end-2) '(' num2str(limtype) ');']);
                        k=k+1;
                        end 
                    else
                    end
               catch
                   msgbox(sprintf('Unable to process %s, because it has not been precompiled',listing(i).name));
               end  
        end  
      end
    filePDFs = rmfield(filePDFs,'name');
    builtInPDF=[builtInPDF  filePDFs];
    names=[names  fileNames];
    clear filePDFs fileNames
    catch ME
        msgbox(ME.message)
    end
end
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
% Please Ignore: hack to include Beta Function in Distribution 
       x=beta(random('uniform',0,1,1,1),random('uniform',0,1,1,1));
 end